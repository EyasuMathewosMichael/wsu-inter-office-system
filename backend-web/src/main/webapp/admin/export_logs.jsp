<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Generate unique filename with timestamp
    long timestamp = new java.util.Date().getTime();
    String fileName = "WSU_Audit_Log_" + timestamp + ".csv";
    response.setHeader("Content-Disposition", "attachment; filename=" + fileName);

    String filterType = request.getParameter("filterType") != null ? request.getParameter("filterType") : "";
    String filterDept = request.getParameter("filterDept") != null ? request.getParameter("filterDept") : "";
    String startDate = request.getParameter("startDate") != null ? request.getParameter("startDate") : "";
    String endDate = request.getParameter("endDate") != null ? request.getParameter("endDate") : "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");

        // Refined 2-Way Union: Only tracking Announcements and Tasks
        StringBuilder query = new StringBuilder("SELECT * FROM (");

        // 1. Announcements -> Scope: Departmental/Group
        query.append("SELECT announcement_id AS id, 'Announcement' AS type, title AS content, target_dept AS target, created_at FROM announcements ");
        query.append("UNION ALL ");

        // 2. Tasks -> Scope: Individual Staff Member
        query.append("SELECT t.task_id AS id, 'Task' AS type, t.title AS content, u.username AS target, t.created_at ");
        query.append("FROM tasks t LEFT JOIN users u ON t.assignee_id = u.user_id ");

        query.append(") AS traffic_logs WHERE 1=1 ");

        // Apply filters
        if(!filterType.isEmpty()) query.append("AND type = '").append(filterType).append("' ");
        if(!filterDept.isEmpty()) query.append("AND target = '").append(filterDept).append("' ");
        if(!startDate.isEmpty()) query.append("AND created_at >= '").append(startDate).append(" 00:00:00' ");
        if(!endDate.isEmpty()) query.append("AND created_at <= '").append(endDate).append(" 23:59:59' ");

        query.append("ORDER BY created_at DESC");

        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery(query.toString());

        // CSV Header
        out.println("Log ID,Category,Content,Target (User/Dept),Timestamp");

        while(rs.next()) {
            String content = rs.getString("content") != null ?
                rs.getString("content").replace(",", ";").replace("\r", " ").replace("\n", " ") : "";

            String target = rs.getString("target");

            // Professional Fallback
            if (target == null || target.trim().isEmpty()) {
                target = "General / School of Informatics";
            }

            out.println(
                rs.getInt("id") + "," +
                rs.getString("type") + "," +
                content + "," +
                target + "," +
                rs.getTimestamp("created_at")
            );
        }
        conn.close();
    } catch(Exception e) {
        // Silent catch for stream integrity
    }
%>