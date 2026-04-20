<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, java.io.*, java.util.*, javax.servlet.http.Part, java.nio.file.Paths" %>
<%!
    private String saveChatUpload(Part part, String uploadRoot) throws Exception {
        if (part == null || part.getSize() <= 0 || part.getSubmittedFileName() == null) return "";

        String originalName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        long timestamp = new java.util.Date().getTime();
        String safeName = "chat_" + timestamp + "_" + originalName.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
        File dir = new File(uploadRoot);
        if (!dir.exists()) dir.mkdirs();

        File destination = new File(dir, safeName);
        part.write(destination.getAbsolutePath());
        return "assets/uploads/" + safeName;
    }
%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    Object sessionUser = session.getAttribute("user_id");
    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"status\":\"error\", \"message\":\"Please login again.\"}");
        return;
    }

    int senderId = Integer.parseInt(sessionUser.toString());
    String receiverId = "0";
    String messageText = "";
    String replyToId = null;
    String chatId = null;
    Part attachmentPart = null;

    try {
        String contentType = request.getContentType();
        boolean isMultipart = contentType != null && contentType.contains("multipart/form-data");
        if (isMultipart) {
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                String name = part.getName();
                String fileName = part.getSubmittedFileName();

                if (fileName == null || fileName.isEmpty()) {
                    try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
                        StringBuilder value = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            value.append(line);
                        }
                        String val = value.toString().trim();
                        if ("receiver_id".equals(name)) receiverId = val;
                        else if ("message".equals(name)) messageText = val;
                        else if ("reply_to_id".equals(name)) replyToId = val;
                        else if ("chat_id".equals(name)) chatId = val;
                    }
                } else if ("attachment".equals(name) && part.getSize() > 0) {
                    attachmentPart = part;
                }
            }
        } else {
            receiverId = request.getParameter("receiver_id");
            messageText = request.getParameter("message");
            replyToId = request.getParameter("reply_to_id");
            chatId = request.getParameter("chat_id");
        }

        String absoluteUploadPath = getServletContext().getRealPath("/") + "assets" + File.separator + "uploads";
        String dbSavePath = saveChatUpload(attachmentPart, absoluteUploadPath);

        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "")) {
            if (chatId != null && !chatId.trim().isEmpty()) {
                if (dbSavePath.isEmpty()) {
                    out.print("{\"status\":\"error\", \"message\":\"No attachment uploaded.\"}");
                    return;
                }

                String sql = "UPDATE chats SET attachment_path = ? WHERE chat_id = ? AND sender_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, dbSavePath);
                    ps.setInt(2, Integer.parseInt(chatId));
                    ps.setInt(3, senderId);
                    if (ps.executeUpdate() > 0) out.print("{\"status\":\"success\"}");
                    else out.print("{\"status\":\"error\", \"message\":\"Message not found or access denied.\"}");
                }
                return;
            }

            String sql = "INSERT INTO chats (sender_id, receiver_id, message, reply_to_id, attachment_path, is_read, sent_at) VALUES (?, ?, ?, ?, ?, 0, NOW())";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, senderId);
                ps.setInt(2, (receiverId == null || receiverId.isEmpty()) ? 0 : Integer.parseInt(receiverId));
                ps.setString(3, (messageText == null) ? "" : messageText);

                if (replyToId != null && !replyToId.isEmpty() && !replyToId.equals("null") && !replyToId.equals("-1")) {
                    ps.setInt(4, Integer.parseInt(replyToId));
                } else {
                    ps.setNull(4, java.sql.Types.INTEGER);
                }

                if (dbSavePath == null || dbSavePath.isEmpty()) ps.setNull(5, java.sql.Types.VARCHAR);
                else ps.setString(5, dbSavePath);

                ps.executeUpdate();
                out.print("{\"status\":\"success\"}");
            }
        }
    } catch (Exception e) {
        out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
    }
    out.flush();
%>
