<%@ page import="java.sql.*, org.json.JSONObject" %>
<%
    response.setContentType("application/json");
    JSONObject res = new JSONObject();

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        out.print(res.put("status", "error").put("message", "POST required.").toString());
        return;
    }

    Object sessionUser = session.getAttribute("user_id");
    String sessionRole = (String) session.getAttribute("user_role");
    String taskId = request.getParameter("task_id");

    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print(res.put("status", "error").put("message", "Please login again.").toString());
        return;
    }

    if (taskId == null || taskId.trim().isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print(res.put("status", "error").put("message", "Task ID is required.").toString());
        return;
    }

    boolean isAdmin = "Admin".equalsIgnoreCase(sessionRole);
    boolean isDeptHead = "Dept Head".equalsIgnoreCase(sessionRole);
    if (!isAdmin && !isDeptHead) {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        out.print(res.put("status", "error").put("message", "Only department heads can acknowledge tasks.").toString());
        return;
    }

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");

        String sql = isAdmin
                ? "UPDATE tasks SET acknowledged = 1 WHERE task_id = ?"
                : "UPDATE tasks SET acknowledged = 1 WHERE task_id = ? AND creator_id = ?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(taskId));
        if (!isAdmin) {
            ps.setInt(2, Integer.parseInt(sessionUser.toString()));
        }

        int rows = ps.executeUpdate();
        if (rows > 0) {
            res.put("status", "success");
        } else {
            res.put("status", "error");
            res.put("message", "Task not found or access denied.");
        }
    } catch (Exception e) {
        res.put("status", "error");
        res.put("message", e.getMessage());
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }

    out.print(res.toString());
%>
