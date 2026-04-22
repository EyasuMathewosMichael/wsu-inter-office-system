<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, org.json.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private File resolveChatFile(String storedPath, String appRoot) {
        if (storedPath == null || storedPath.trim().isEmpty()) return null;

        String normalized = storedPath.replace("\\", "/");
        int assetsIndex = normalized.indexOf("assets/");
        if (assetsIndex >= 0) {
            return new File(appRoot, normalized.substring(assetsIndex).replace("/", File.separator));
        }

        return new File(storedPath);
    }
%>
<%
    response.setContentType("application/json");
    Object sessionUser = session.getAttribute("user_id");
    JSONObject json = new JSONObject();

    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        json.put("status", "error");
        json.put("message", "Please login again.");
        out.print(json.toString());
        return;
    }

    String chatId = request.getParameter("chat_id");
    String action = request.getParameter("action");
    String newMessage = request.getParameter("message");

    if (chatId == null || action == null) {
        json.put("status", "error");
        json.put("message", "Missing parameters");
        out.print(json.toString());
        return;
    }

    int currentUserId = Integer.parseInt(sessionUser.toString());

    try {
        try (Connection con = getDbConnection(application)) {
            if ("edit".equals(action)) {
                PreparedStatement ps = con.prepareStatement("UPDATE chats SET message = ? WHERE chat_id = ? AND sender_id = ?");
                ps.setString(1, newMessage);
                ps.setInt(2, Integer.parseInt(chatId));
                ps.setInt(3, currentUserId);
                int updated = ps.executeUpdate();
                json.put("status", updated > 0 ? "success" : "error");
                if (updated == 0) json.put("message", "Message not found or access denied.");
            } else {
                PreparedStatement getPath = con.prepareStatement("SELECT attachment_path FROM chats WHERE chat_id = ? AND sender_id = ?");
                getPath.setInt(1, Integer.parseInt(chatId));
                getPath.setInt(2, currentUserId);
                ResultSet rs = getPath.executeQuery();
                if (!rs.next()) {
                    json.put("status", "error");
                    json.put("message", "Message not found or access denied.");
                    out.print(json.toString());
                    return;
                }

                String oldPath = rs.getString("attachment_path");
                if ("delete".equals(action)) {
                    PreparedStatement ps = con.prepareStatement("DELETE FROM chats WHERE chat_id = ? AND sender_id = ?");
                    ps.setInt(1, Integer.parseInt(chatId));
                    ps.setInt(2, currentUserId);
                    ps.executeUpdate();
                    json.put("status", "success");
                } else if ("delete_file".equals(action)) {
                    PreparedStatement ps = con.prepareStatement("UPDATE chats SET attachment_path = '' WHERE chat_id = ? AND sender_id = ?");
                    ps.setInt(1, Integer.parseInt(chatId));
                    ps.setInt(2, currentUserId);
                    ps.executeUpdate();
                    json.put("status", "success");
                } else {
                    json.put("status", "error");
                    json.put("message", "Unknown action.");
                }

                if ("delete".equals(action) || "delete_file".equals(action)) {
                    File file = resolveChatFile(oldPath, getServletContext().getRealPath("/"));
                    if (file != null && file.exists()) file.delete();
                }
            }
        }
    } catch (Exception e) {
        json.put("status", "error");
        json.put("message", e.getMessage());
    }
    out.print(json.toString());
%>

