<%@ page import="java.sql.*, org.json.JSONObject, org.mindrot.jbcrypt.BCrypt" %>
<%@ include file="/WEB-INF/jspf/account_helpers.jspf" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private boolean isBcryptHash(String value) {
        return value != null && value.startsWith("$2");
    }
%>
<%
    String user = request.getParameter("user");
    String pass = request.getParameter("pass");
    JSONObject json = new JSONObject();

    try {
        Connection con = getDbConnection(application);
        ensureUsersPersonalEmailColumn(con);

        String query = "SELECT user_id, username, password, role, department, full_name, profile_pic_path, phone, bio, personal_email FROM users WHERE username=?";
        PreparedStatement ps = con.prepareStatement(query);
        ps.setString(1, user);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String storedPassword = rs.getString("password");
            boolean validPassword = isBcryptHash(storedPassword) ? BCrypt.checkpw(pass, storedPassword) : pass.equals(storedPassword);
            if (!validPassword) {
                response.setStatus(401);
                json.put("success", false);
                json.put("error", "Invalid credentials");
            } else {
                int userId = rs.getInt("user_id");
                String role = rs.getString("role");
                String department = rs.getString("department");
                String fullName = rs.getString("full_name");
                String profilePicPath = rs.getString("profile_pic_path");
                String phone = rs.getString("phone");
                String bio = rs.getString("bio");
                String personalEmail = rs.getString("personal_email");

                if (!isBcryptHash(storedPassword)) {
                    PreparedStatement upgrade = con.prepareStatement("UPDATE users SET password = ? WHERE user_id = ?");
                    upgrade.setString(1, BCrypt.hashpw(pass, BCrypt.gensalt(12)));
                    upgrade.setInt(2, userId);
                    upgrade.executeUpdate();
                    upgrade.close();
                }

                session.setAttribute("user_id", userId);
                session.setAttribute("user_role", role);
                session.setAttribute("user_department", department);
                session.setAttribute("user_name", fullName);
                session.setAttribute("user_pic", profilePicPath);
                session.setAttribute("user_phone", phone);
                session.setAttribute("user_bio", bio);
                session.setAttribute("user_personal_email", personalEmail);
                session.setMaxInactiveInterval(30 * 60);

                if ("Admin".equalsIgnoreCase(role)) {
                    session.setAttribute("admin_id", userId);
                    session.setAttribute("admin_name", fullName);
                    session.setAttribute("admin_role", "Admin");
                }

                json.put("success", true);
                json.put("user_id", rs.getInt("user_id"));
                json.put("username", rs.getString("username"));
                json.put("role", role);
                json.put("department", department);
                json.put("full_name", fullName);
                json.put("profile_pic_path", profilePicPath == null ? "" : profilePicPath);
                json.put("phone", phone == null ? "" : phone);
                json.put("bio", bio == null ? "" : bio);
                json.put("personal_email", personalEmail == null ? "" : personalEmail);
            }
        } else {
            response.setStatus(401);
            json.put("success", false);
            json.put("error", "Invalid credentials");
        }
        con.close();
    } catch (Exception e) {
        response.setStatus(500);
        json.put("success", false);
        json.put("error", e.getMessage());
    }
    out.print(json.toString());
%>

