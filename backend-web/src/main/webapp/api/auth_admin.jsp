<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.mindrot.jbcrypt.BCrypt" %>
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
        response.sendRedirect("../admin/login.jsp?error=empty");
        return;
    }

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");

        String sql = "SELECT * FROM users WHERE username = ? AND role = 'Admin'";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, user);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String storedPassword = rs.getString("password");
            boolean validPassword = isBcryptHash(storedPassword) ? BCrypt.checkpw(pass, storedPassword) : pass.equals(storedPassword);
            if (!validPassword) {
                response.sendRedirect("../admin/login.jsp?error=invalid");
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

            session.setAttribute("user_id", userId);
            session.setAttribute("admin_id", userId);
            session.setAttribute("admin_name", rs.getString("full_name"));
            session.setAttribute("admin_role", "Admin");
            session.setAttribute("user_role", rs.getString("role"));
            session.setAttribute("user_department", rs.getString("department"));
            session.setAttribute("user_name", rs.getString("full_name"));

            session.setMaxInactiveInterval(30 * 60);

            response.sendRedirect("../admin/dashboard.jsp");
        } else {
            response.sendRedirect("../admin/login.jsp?error=invalid");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("../admin/login.jsp?error=db_fail");
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
