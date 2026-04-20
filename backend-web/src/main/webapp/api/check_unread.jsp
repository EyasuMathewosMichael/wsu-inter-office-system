<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, org.json.*" %>
<%
    response.setContentType("application/json");

    Object sessionUser = session.getAttribute("user_id");
    String userIdParam = (sessionUser != null) ? sessionUser.toString() : request.getParameter("user_id");
    JSONObject responseJson = new JSONObject();

    if (userIdParam == null || userIdParam.trim().isEmpty()) {
        responseJson.put("unread", false);
        responseJson.put("message", "Missing user_id");
        out.print(responseJson.toString());
        return;
    }

    boolean hasUnread = false;

    try {
        int userId = Integer.parseInt(userIdParam.trim());

        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "")) {
            String department = "";
            try (PreparedStatement deptPs = con.prepareStatement("SELECT department FROM users WHERE user_id = ?")) {
                deptPs.setInt(1, userId);
                ResultSet deptRs = deptPs.executeQuery();
                if (deptRs.next()) {
                    department = deptRs.getString("department");
                    if (department == null) department = "";
                }
            }

            int unreadCount = 0;

            try (PreparedStatement directPs = con.prepareStatement(
                    "SELECT COUNT(*) FROM chats WHERE receiver_id = ? AND sender_id <> ? AND is_read = 0")) {
                directPs.setInt(1, userId);
                directPs.setInt(2, userId);
                ResultSet directRs = directPs.executeQuery();
                if (directRs.next()) unreadCount += directRs.getInt(1);
            }

            if (!department.isEmpty()) {
                try (PreparedStatement groupPs = con.prepareStatement(
                        "SELECT COUNT(*) " +
                        "FROM chats c INNER JOIN users u ON c.sender_id = u.user_id " +
                        "WHERE c.receiver_id = 0 AND c.sender_id <> ? AND c.is_read = 0 AND u.department = ?")) {
                    groupPs.setInt(1, userId);
                    groupPs.setString(2, department);
                    ResultSet groupRs = groupPs.executeQuery();
                    if (groupRs.next()) unreadCount += groupRs.getInt(1);
                }
            }

            hasUnread = unreadCount > 0;
            responseJson.put("unread_count", unreadCount);
        }
    } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        responseJson.put("unread", false);
        responseJson.put("message", e.getMessage());
        out.print(responseJson.toString());
        return;
    }

    responseJson.put("unread", hasUnread);
    out.print(responseJson.toString());
%>
