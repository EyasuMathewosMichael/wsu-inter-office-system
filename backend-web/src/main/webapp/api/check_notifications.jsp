<%@ page import="java.sql.*, org.json.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    String deptHeadId = request.getParameter("dept_head_id");
    JSONArray notifications = new JSONArray();

    try {
        Connection conn = getDbConnection(application);

        // Find tasks that were completed but not yet "acknowledged" by the Dept Head
        String sql = "SELECT task_id, title FROM tasks WHERE creator_id = ? AND status = 'Completed' AND acknowledged = 0";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(deptHeadId));

        ResultSet rs = ps.executeQuery();
        while(rs.next()) {
            JSONObject obj = new JSONObject();
            obj.put("task_id", rs.getInt("task_id"));
            obj.put("title", rs.getString("title"));
            notifications.put(obj);
        }
        conn.close();
    } catch (Exception e) { e.printStackTrace(); }
    out.print(notifications.toString());
%>
