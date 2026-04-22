<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private String normalizeAnnouncementPath(String dbPath) {
        if (dbPath == null) return "";
        String normalized = dbPath.replace("\\", "/").trim();
        if (normalized.isEmpty()) return "";

        int assetsIndex = normalized.indexOf("assets/");
        if (assetsIndex >= 0) return normalized.substring(assetsIndex);
        if (normalized.startsWith("/")) return normalized.substring(1);
        return normalized;
    }
%>
<%
    response.setContentType("application/json");

    Object sessionUser = session.getAttribute("user_id");
    String sessionRole = (String) session.getAttribute("user_role");
    String sessionDept = (String) session.getAttribute("user_department");
    String staffDept = request.getParameter("dept");
    JSONArray array = new JSONArray();

    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print(new JSONObject().put("status", "error").put("message", "Please login again.").toString());
        return;
    }

    if (staffDept == null || staffDept.trim().isEmpty()) {
        staffDept = sessionDept;
    }

    try {
        try (Connection con = getDbConnection(application)) {
            String query = "SELECT a.*, u.full_name, u.role FROM announcements a " +
                           "LEFT JOIN users u ON a.poster_id = u.user_id " +
                           "WHERE a.target_dept = ? OR a.target_dept = 'Global' OR ? = 'Admin' " +
                           "ORDER BY a.created_at DESC";

            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, staffDept);
            ps.setString(2, sessionRole != null ? sessionRole : "");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("announcement_id", rs.getInt("announcement_id"));
                obj.put("poster_id", rs.getInt("poster_id"));
                obj.put("title", rs.getString("title"));
                obj.put("content", rs.getString("content"));
                obj.put("attachment_path", normalizeAnnouncementPath(rs.getString("attachment_path")));

                Timestamp ts = rs.getTimestamp("created_at");
                obj.put("created_at", ts != null ? ts.toString() : "");

                String name = rs.getString("full_name");
                String role = rs.getString("role");
                obj.put("sender_name", (name != null) ? name : "University Admin");
                obj.put("sender_role", (role != null) ? role : "Admin");

                array.put(obj);
            }
        }
    } catch (Exception e) {
        JSONObject error = new JSONObject();
        error.put("status", "error");
        error.put("message", e.getMessage());
        out.print(error.toString());
        return;
    }

    out.print(array.toString());
%>

