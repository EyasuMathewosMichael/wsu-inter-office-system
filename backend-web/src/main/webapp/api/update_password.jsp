<%@ page import="java.sql.*, org.json.JSONObject, org.mindrot.jbcrypt.BCrypt" %>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%!
    private boolean isBcryptHash(String value) {
        return value != null && value.startsWith("$2");
    }
%>
<%
    String oldPass = request.getParameter("old_pass");
    String newPass = request.getParameter("new_pass");
    Object sessionUser = session.getAttribute("user_id");

    JSONObject responseJson = new JSONObject();

    if (sessionUser == null || oldPass == null || newPass == null) {
        responseJson.put("success", false);
        responseJson.put("message", "Please login again before changing your password.");
        out.print(responseJson.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        int userId = Integer.parseInt(sessionUser.toString());
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");

        String sql = "SELECT password FROM users WHERE user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String storedHashedPass = rs.getString("password");

            boolean validPassword = isBcryptHash(storedHashedPass) ? BCrypt.checkpw(oldPass, storedHashedPass) : oldPass.equals(storedHashedPass);
            if (validPassword) {
                String newHashedPass = BCrypt.hashpw(newPass, BCrypt.gensalt(12));

                String updateSql = "UPDATE users SET password = ? WHERE user_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, newHashedPass);
                pstmt.setInt(2, userId);

                if (pstmt.executeUpdate() > 0) {
                    responseJson.put("success", true);
                    responseJson.put("message", "Password securely updated.");
                } else {
                    responseJson.put("success", false);
                    responseJson.put("message", "Update failed in database.");
                }
            } else {
                responseJson.put("success", false);
                responseJson.put("message", "The current password you entered is incorrect.");
            }
        } else {
            responseJson.put("success", false);
            responseJson.put("message", "User not found.");
        }
    } catch (Exception e) {
        responseJson.put("success", false);
        responseJson.put("message", "Security Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }

    out.print(responseJson.toString());
%>
