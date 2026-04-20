<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ include file="../admin/auth_check.jsp" %>
<%
    response.setContentType("application/json");

    // 1. Get parameters
    String action = request.getParameter("action");
    String chatIdStr = request.getParameter("chat_id");
    String newMessage = request.getParameter("message");
    Object sessionUser = session.getAttribute("user_id");

    // 2. Initial Validation
    if (chatIdStr == null || sessionUser == null || action == null) {
        out.print("{\"status\":\"error\", \"message\":\"Invalid session or missing ID.\"}");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;

    try {
        int chatId = Integer.parseInt(chatIdStr);
        int currentUserId = Integer.parseInt(sessionUser.toString());

        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");

        if ("delete".equals(action)) {
            // Only delete if the logged-in user is the sender
            String sql = "DELETE FROM chats WHERE chat_id = ? AND sender_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, chatId);
            ps.setInt(2, currentUserId);
        }
        else if ("edit".equals(action)) {
            if (newMessage == null || newMessage.trim().isEmpty()) {
                out.print("{\"status\":\"error\", \"message\":\"Message content is empty.\"}");
                return;
            }
            // Only update if the logged-in user is the sender
            String sql = "UPDATE chats SET message = ? WHERE chat_id = ? AND sender_id = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, newMessage.trim());
            ps.setInt(2, chatId);
            ps.setInt(3, currentUserId);
        }

        if (ps != null) {
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                out.print("{\"status\":\"success\"}");
            } else {
                // This happens if the chat_id exists but the sender_id doesn't match
                out.print("{\"status\":\"error\", \"message\":\"Permission denied or record moved.\"}");
            }
        } else {
            out.print("{\"status\":\"error\", \"message\":\"Unknown action.\"}");
        }

    } catch (NumberFormatException e) {
        out.print("{\"status\":\"error\", \"message\":\"ID formatting error.\"}");
    } catch (Exception e) {
        out.print("{\"status\":\"error\", \"message\":\"System error: " + e.getMessage().replace("\"", "'") + "\"}");
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>