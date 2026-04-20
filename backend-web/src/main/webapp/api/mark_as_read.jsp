<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*" %>
<%
    Object sessionUser = session.getAttribute("user_id");
    String myId = (sessionUser != null) ? sessionUser.toString() : request.getParameter("user_id");
    String targetId = request.getParameter("target_id");
    JSONObject json = new JSONObject();

    if (myId == null || targetId == null) {
        json.put("status", "error");
        out.print(json.toString());
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "")) {
            // Mark all messages SENT TO ME from THIS TARGET as read
            String sql = "UPDATE chats SET is_read = 1 WHERE sender_id = ? AND receiver_id = ? AND is_read = 0";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(targetId));
            ps.setInt(2, Integer.parseInt(myId));

            int rowsUpdated = ps.executeUpdate();
            json.put("status", "success");
            json.put("updated_count", rowsUpdated);
        }
    } catch (Exception e) {
        json.put("status", "error");
        json.put("message", e.getMessage());
    }
    out.print(json.toString());
%>
