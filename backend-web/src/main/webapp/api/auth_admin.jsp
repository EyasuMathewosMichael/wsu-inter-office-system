<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.mindrot.jbcrypt.BCrypt" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private boolean isBcryptHash(String value) {
        return value != null && value.startsWith("$2");
    }
%>
<%
    String user = request.getParameter("username");
    String pass = request.getParameter("password");

    // 1. Basic validation to prevent empty queries
    if (user == null || pass == null || user.trim().isEmpty()) {
        response.sendRedirect(response.encodeRedirectURL("../admin/login.jsp?error=empty"));
        return;
    }

    Connection conn = null;
    try {
        conn = getDbConnection(application);

        String sql = "SELECT * FROM users WHERE username = ? AND role = 'Admin'";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, user);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String storedPassword = rs.getString("password");
            boolean validPassword = isBcryptHash(storedPassword) ? BCrypt.checkpw(pass, storedPassword) : pass.equals(storedPassword);
            if (!validPassword) {
                response.sendRedirect(response.encodeRedirectURL("../admin/login.jsp?error=invalid"));
                return;
            }

            int userId = rs.getInt("user_id");
            if (!isBcryptHash(storedPassword)) {
                PreparedStatement upgrade = conn.prepareStatement("UPDATE users SET password = ? WHERE user_id = ?");
                upgrade.setString(1, BCrypt.hashpw(pass, BCrypt.gensalt(12)));
                upgrade.setInt(2, userId);
                upgrade.executeUpdate();
                upgrade.close();
            }

            // Always start a fresh session after successful admin login.
            session.invalidate();
            HttpSession adminSession = request.getSession(true);
            adminSession.setAttribute("user_id", userId);
            adminSession.setAttribute("admin_id", userId);
            adminSession.setAttribute("admin_name", rs.getString("full_name"));
            adminSession.setAttribute("admin_role", "Admin");
            adminSession.setAttribute("user_role", rs.getString("role"));
            adminSession.setAttribute("user_department", rs.getString("department"));
            adminSession.setAttribute("user_name", rs.getString("full_name"));
            adminSession.setAttribute("user_pic", rs.getString("profile_pic_path"));
            adminSession.setMaxInactiveInterval(30 * 60);

            response.sendRedirect("../admin/dashboard.jsp;jsessionid=" + adminSession.getId());
        } else {
            response.sendRedirect(response.encodeRedirectURL("../admin/login.jsp?error=invalid"));
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(response.encodeRedirectURL("../admin/login.jsp?error=db_fail"));
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
