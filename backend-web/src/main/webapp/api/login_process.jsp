<%@ page import="java.sql.*, org.json.JSONObject, org.mindrot.jbcrypt.BCrypt" %>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private boolean isBcryptHash(String value) {
        return value != null && value.startsWith("$2");
    }
%>
<%
    String userParam = request.getParameter("username");
    String passParam = request.getParameter("password");

    JSONObject responseJson = new JSONObject();

    // 1. Basic validation [cite: 2026-01-21]
    if (userParam == null || passParam == null) {
        responseJson.put("success", false);
        responseJson.put("message", "Credentials required.");
        out.print(responseJson.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Using your specific database name [cite: 2026-01-28]
        conn = getDbConnection(application);

        // 2. Fetch user data by username only [cite: 2026-01-21]
        String sql = "SELECT user_id, username, password, role, department, full_name FROM users WHERE username = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userParam);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String storedPassword = rs.getString("password");
            boolean validPassword = isBcryptHash(storedPassword) ? BCrypt.checkpw(passParam, storedPassword) : passParam.equals(storedPassword);
            if (validPassword) {
                if (!isBcryptHash(storedPassword)) {
                    PreparedStatement upgrade = conn.prepareStatement("UPDATE users SET password = ? WHERE user_id = ?");
                    upgrade.setString(1, BCrypt.hashpw(passParam, BCrypt.gensalt(12)));
                    upgrade.setInt(2, rs.getInt("user_id"));
                    upgrade.executeUpdate();
                    upgrade.close();
                }

                // Success: Populate the response for UserSession.init() [cite: 2026-03-05]
                responseJson.put("success", true);
                responseJson.put("user_id", rs.getInt("user_id"));
                responseJson.put("username", rs.getString("username"));
                responseJson.put("role", rs.getString("role"));
                responseJson.put("department", rs.getString("department"));
                responseJson.put("full_name", rs.getString("full_name"));
            } else {
                // Password mismatch
                responseJson.put("success", false);
                responseJson.put("message", "Invalid username or password.");
            }
        } else {
            // User not found
            responseJson.put("success", false);
            responseJson.put("message", "Invalid username or password.");
        }
    } catch (Exception e) {
        responseJson.put("success", false);
        responseJson.put("message", "Database Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }

    out.print(responseJson.toString());
%>

