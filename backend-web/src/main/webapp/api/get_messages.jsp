<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    response.setContentType("application/json");

    Object sessionUser = session.getAttribute("user_id");
    String userIdStr = (sessionUser != null) ? sessionUser.toString() : request.getParameter("user_id");

    String targetIdStr = request.getParameter("target_id");

    if (userIdStr == null || targetIdStr == null) {
        out.print("[]");
        return;
    }

    StringBuilder json = new StringBuilder();
    json.append("[");

    try {
        int userId = Integer.parseInt(userIdStr.trim());
        int targetId = Integer.parseInt(targetIdStr.trim());
        try (Connection con = getDbConnection(application)) {

            String myDept = "";
            try (PreparedStatement psDept = con.prepareStatement("SELECT department FROM users WHERE user_id = ?")) {
                psDept.setInt(1, userId);
                ResultSet rsDept = psDept.executeQuery();
                if (rsDept.next()) {
                    myDept = rsDept.getString("department");
                    if (myDept == null) myDept = "";
                }
            }

            if (targetId > 0) {
                String readSql = "UPDATE chats SET is_read = 1 WHERE sender_id = ? AND receiver_id = ? AND is_read = 0";
                try (PreparedStatement psRead = con.prepareStatement(readSql)) {
                    psRead.setInt(1, targetId);
                    psRead.setInt(2, userId);
                    psRead.executeUpdate();
                }
            }

            String sql;
            if (targetId == 0) {
                sql = "SELECT m.*, r.message AS reply_to_text, u.full_name AS sender_name " +
                      "FROM chats m " +
                      "INNER JOIN users u ON m.sender_id = u.user_id " +
                      "LEFT JOIN chats r ON m.reply_to_id = r.chat_id " +
                      "WHERE m.receiver_id = 0 AND u.department = ? " +
                      "ORDER BY m.sent_at ASC";
            } else {
                sql = "SELECT m.*, r.message AS reply_to_text, u.full_name AS sender_name " +
                      "FROM chats m " +
                      "INNER JOIN users u ON m.sender_id = u.user_id " +
                      "LEFT JOIN chats r ON m.reply_to_id = r.chat_id " +
                      "WHERE (m.sender_id = ? AND m.receiver_id = ?) " +
                      "OR (m.sender_id = ? AND m.receiver_id = ?) " +
                      "ORDER BY m.sent_at ASC";
            }

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                if (targetId == 0) {
                    ps.setString(1, myDept);
                } else {
                    ps.setInt(1, userId); ps.setInt(2, targetId);
                    ps.setInt(3, targetId); ps.setInt(4, userId);
                }

                ResultSet rs = ps.executeQuery();
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(",");

                    String rawMsg = rs.getString("message");
                    String message = (rawMsg != null) ? rawMsg.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "";

                    String rawReply = rs.getString("reply_to_text");
                    String rText = (rawReply != null) ? rawReply.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "";

                    String sName = rs.getString("sender_name");
                    String senderName = (sName != null) ? sName.replace("\"", "\\\"") : "Unknown";

                    // IMPROVED ATTACHMENT PROCESSING
                    String attachment = "";
                    String dbPath = rs.getString("attachment_path");
                    if (dbPath != null && !dbPath.trim().isEmpty()) {
                        // 1. Normalize slashes
                        attachment = dbPath.replace("\\", "/");

                        // 2. Remove context path if the DB stored the full URL path
                        // This prevents the 'double context' issue (e.g., /backend-web/backend-web/...)
                        String contextPath = request.getContextPath(); // Usually "/backend-web"
                        if (!contextPath.isEmpty() && attachment.startsWith(contextPath + "/")) {
                            attachment = attachment.substring(contextPath.length() + 1);
                        } else if (attachment.startsWith("/")) {
                            attachment = attachment.substring(1);
                        }
                    }

                    Timestamp sentAt = rs.getTimestamp("sent_at");

                    json.append("{")
                        .append("\"chat_id\":").append(rs.getInt("chat_id")).append(",")
                        .append("\"sender_id\":").append(rs.getInt("sender_id")).append(",")
                        .append("\"receiver_id\":").append(rs.getInt("receiver_id")).append(",")
                        .append("\"sender_name\":\"").append(senderName).append("\",")
                        .append("\"message\":\"").append(message).append("\",")
                        .append("\"attachment_path\":\"").append(attachment).append("\",")
                        .append("\"sent_at\":\"").append(sentAt != null ? sentAt.toString().substring(0, 19) : "").append("\",")
                        .append("\"is_read\":").append(rs.getInt("is_read"));

                    int rId = rs.getInt("reply_to_id");
                    if (!rs.wasNull()) {
                        json.append(",\"reply_to_id\":").append(rId)
                            .append(",\"reply_to_text\":\"").append(rText).append("\"");
                    }
                    json.append("}");
                    first = false;
                }
            }
        }
    } catch (Exception e) {
        // Log error if needed
    }

    json.append("]");
    out.print(json.toString());
    out.flush();
%>

