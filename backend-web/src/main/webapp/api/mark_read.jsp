<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, org.json.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    response.setContentType("application/json");

    Object sessionUser = session.getAttribute("user_id");
    String userIdParam = (sessionUser != null) ? sessionUser.toString() : request.getParameter("user_id");
    JSONObject json = new JSONObject();

    if (userIdParam == null || userIdParam.trim().isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        json.put("status", "error");
        json.put("message", "Missing user_id");
        out.print(json.toString());
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

            int directUpdated = 0;
            try (PreparedStatement directPs = con.prepareStatement(
                    "UPDATE chats SET is_read = 1 WHERE receiver_id = ? AND sender_id <> ? AND is_read = 0")) {
                directPs.setInt(1, userId);
                directPs.setInt(2, userId);
                directUpdated = directPs.executeUpdate();
            }

            int groupUpdated = 0;
            if (!department.isEmpty()) {
                try (PreparedStatement groupPs = con.prepareStatement(
                        "UPDATE chats c INNER JOIN users u ON c.sender_id = u.user_id " +
                        "SET c.is_read = 1 " +
                        "WHERE c.receiver_id = 0 AND c.sender_id <> ? AND c.is_read = 0 AND u.department = ?")) {
                    groupPs.setInt(1, userId);
                    groupPs.setString(2, department);
                    groupUpdated = groupPs.executeUpdate();
                }
            }

            json.put("status", "success");
            json.put("updated_direct", directUpdated);
            json.put("updated_group", groupUpdated);
            json.put("updated_total", directUpdated + groupUpdated);
        }
    } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        json.put("status", "error");
        json.put("message", e.getMessage());
    }

    out.print(json.toString());
%>

