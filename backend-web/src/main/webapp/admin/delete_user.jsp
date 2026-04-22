<%@ page import="java.sql.*" %>
<%@ include file="auth_check.jsp" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    String userId = request.getParameter("id");
    if (userId != null) {
        try {
            Connection conn = getDbConnection(application);

            // Delete query
            PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE user_id = ?");
            ps.setInt(1, Integer.parseInt(userId));
            ps.executeUpdate();

            conn.close();
            // Redirect back with a success flag
            response.sendRedirect("manage_users.jsp?msg=deleted");
        } catch (Exception e) {
            out.print("Error: " + e.getMessage());
        }
    }
%>
