<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, org.json.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    response.setContentType("application/json");

    Object sessionUser = session.getAttribute("user_id");
    String userIdParam = (sessionUser != null) ? sessionUser.toString() : request.getParameter("user_id");
    JSONArray array = new JSONArray();

    if (userIdParam == null || userIdParam.trim().isEmpty()) {
        out.print(array.toString());
        return;
    }

    try {
        int userId = Integer.parseInt(userIdParam.trim());
        try (Connection con = getDbConnection(application)) {
            String department = "";
            try (PreparedStatement deptPs = con.prepareStatement("SELECT department FROM users WHERE user_id = ?")) {
                deptPs.setInt(1, userId);
                ResultSet deptRs = deptPs.executeQuery();
                if (deptRs.next()) {
                    department = deptRs.getString("department");
                    if (department == null) department = "";
                }
            }

            String query =
                    "SELECT c.chat_id, c.sender_id, c.receiver_id, c.message, c.sent_at, c.attachment_path, u.full_name AS sender_name " +
                    "FROM chats c INNER JOIN users u ON c.sender_id = u.user_id " +
                    "WHERE c.sender_id = ? OR c.receiver_id = ? OR (c.receiver_id = 0 AND u.department = ?) " +
                    "ORDER BY c.sent_at ASC";

            try (PreparedStatement ps = con.prepareStatement(query)) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                ps.setString(3, department);

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    JSONObject obj = new JSONObject();
                    obj.put("chat_id", rs.getInt("chat_id"));
                    obj.put("sender_id", rs.getInt("sender_id"));
                    obj.put("receiver_id", rs.getInt("receiver_id"));
                    obj.put("sender_name", rs.getString("sender_name"));
                    obj.put("message", rs.getString("message"));
                    obj.put("attachment_path", rs.getString("attachment_path"));
                    Timestamp sentAt = rs.getTimestamp("sent_at");
                    obj.put("sent_at", sentAt != null ? sentAt.toString() : "");
                    array.put(obj);
                }
            }
        }
    } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }

    out.print(array.toString());
%>

