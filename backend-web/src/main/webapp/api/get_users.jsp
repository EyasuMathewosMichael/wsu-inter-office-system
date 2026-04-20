<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*" %>

<%
    JSONArray userArray = new JSONArray();
    Object sessionUser = session.getAttribute("user_id");
    String myId = (sessionUser != null) ? sessionUser.toString() : request.getParameter("my_id");

    if (myId == null || myId.trim().isEmpty()) {
        out.print(userArray.toString());
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "")) {

            int currentUserId = Integer.parseInt(myId.trim());

            // 1. Get current user's department [cite: 2026-02-27]
            String myDept = "";
            PreparedStatement psDept = con.prepareStatement("SELECT department FROM users WHERE user_id = ?");
            psDept.setInt(1, currentUserId);
            ResultSet rsDept = psDept.executeQuery();
            if (rsDept.next()) {
                myDept = rsDept.getString("department");
            }

            // 2. Updated Query: Department filtering + Admin access [cite: 2026-01-28, 2026-02-27]
            String query = "SELECT u.user_id, u.full_name, u.role, u.department, " +
                           "(SELECT message FROM chats " +
                           " WHERE (sender_id = u.user_id AND receiver_id = ?) " +
                           "    OR (sender_id = ? AND receiver_id = u.user_id) " +
                           " ORDER BY sent_at DESC LIMIT 1) as last_msg, " +
                           "(SELECT COUNT(*) FROM chats " +
                           " WHERE sender_id = u.user_id AND receiver_id = ? AND is_read = 0) as unread_count " +
                           "FROM users u " +
                           "WHERE u.user_id != ? " +
                           "AND (u.department = ? OR u.role = 'admin')";

            PreparedStatement ps = con.prepareStatement(query);
            ps.setInt(1, currentUserId);
            ps.setInt(2, currentUserId);
            ps.setInt(3, currentUserId);
            ps.setInt(4, currentUserId);
            ps.setString(5, myDept); // Filter by same department [cite: 2026-02-27]

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject userJson = new JSONObject();
                userJson.put("user_id", rs.getInt("user_id"));

                String role = rs.getString("role");
                String fullName = rs.getString("full_name");

                // Add visual indicator for Admin [cite: 2026-02-27]
                if ("admin".equalsIgnoreCase(role)) {
                    fullName += " (Admin)";
                }

                userJson.put("full_name", fullName);
                userJson.put("role", role);
                userJson.put("department", rs.getString("department"));
                userJson.put("unread_count", rs.getInt("unread_count"));

                String lastMsg = rs.getString("last_msg");
                userJson.put("last_msg", (lastMsg != null) ? lastMsg : "No messages yet");
                userJson.put("is_online", true);

                userArray.put(userJson);
            }
        }
    } catch (Exception e) {
        response.setStatus(500);
        JSONObject error = new JSONObject();
        error.put("error", e.getMessage());
        out.print(error.toString());
        return;
    }

    out.print(userArray.toString());
%>
