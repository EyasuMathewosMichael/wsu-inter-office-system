<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*, javax.servlet.http.Part, java.nio.file.Paths, java.net.URLEncoder" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private String saveUpdatedAnnouncementFile(Part part, String uploadRoot) throws Exception {
        if (part == null || part.getSize() <= 0 || part.getSubmittedFileName() == null) return "";

        String originalName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        long timestamp = new java.util.Date().getTime();
        String safeName = "announcement_" + timestamp + "_" + originalName.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
        File dir = new File(uploadRoot);
        if (!dir.exists()) dir.mkdirs();

        File destination = new File(dir, safeName);
        part.write(destination.getAbsolutePath());
        return "assets/uploads/announcements/" + safeName;
    }

    private void redirectWithStatus(HttpServletResponse response, String redirectTo, String status, String message) throws IOException {
        String separator = redirectTo.contains("?") ? "&" : "?";
        response.sendRedirect(
                redirectTo + separator +
                "status=" + URLEncoder.encode(status, "UTF-8") +
                "&msg=" + URLEncoder.encode(message, "UTF-8")
        );
    }
%>
<%
    response.setContentType("application/json");

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        out.print("{\"status\":\"error\", \"message\":\"POST required.\"}");
        return;
    }

    Object sessionUser = session.getAttribute("user_id");
    String sessionRole = (String) session.getAttribute("user_role");
    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"status\":\"error\", \"message\":\"Please login again.\"}");
        return;
    }

    int currentUserId = Integer.parseInt(sessionUser.toString());
    boolean isAdmin = "Admin".equalsIgnoreCase(sessionRole);

    int announcementId = -1;
    String title = "";
    String targetDept = "";
    String content = "";
    String redirectTo = "";
    Part attachmentPart = null;

    try {
        boolean isMultipart = request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/");
        if (isMultipart) {
            for (Part part : request.getParts()) {
                if (part.getSubmittedFileName() == null) {
                    try (Scanner scanner = new Scanner(part.getInputStream(), "UTF-8")) {
                        String value = scanner.hasNext() ? scanner.useDelimiter("\\A").next().trim() : "";
                        if ("id".equals(part.getName())) announcementId = Integer.parseInt(value);
                        else if ("title".equals(part.getName())) title = value;
                        else if ("target_dept".equals(part.getName())) targetDept = value;
                        else if ("content".equals(part.getName())) content = value;
                        else if ("redirect_to".equals(part.getName())) redirectTo = value;
                    }
                } else if ("attachment".equals(part.getName()) && part.getSize() > 0) {
                    attachmentPart = part;
                }
            }
        } else {
            announcementId = Integer.parseInt(request.getParameter("id"));
            title = request.getParameter("title");
            targetDept = request.getParameter("target_dept");
            content = request.getParameter("content");
            redirectTo = request.getParameter("redirect_to");
        }

        boolean wantsRedirect = redirectTo != null && !redirectTo.trim().isEmpty();
        try (Connection conn = getDbConnection(application)) {
            String existingTargetDept = targetDept;
            PreparedStatement checkPs = conn.prepareStatement("SELECT poster_id, target_dept FROM announcements WHERE announcement_id = ?");
            checkPs.setInt(1, announcementId);
            ResultSet checkRs = checkPs.executeQuery();
            if (!checkRs.next()) {
                if (wantsRedirect) {
                    redirectWithStatus(response, redirectTo, "error", "Announcement not found.");
                } else {
                    out.print("{\"status\":\"error\", \"message\":\"Announcement not found.\"}");
                }
                return;
            }

            int ownerId = checkRs.getInt("poster_id");
            if (!isAdmin && ownerId != currentUserId) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                if (wantsRedirect) {
                    redirectWithStatus(response, redirectTo, "error", "You cannot edit this announcement.");
                } else {
                    out.print("{\"status\":\"error\", \"message\":\"You cannot edit this announcement.\"}");
                }
                return;
            }

            if (existingTargetDept == null || existingTargetDept.trim().isEmpty()) {
                existingTargetDept = checkRs.getString("target_dept");
            }

            String uploadRoot = getServletContext().getRealPath("/") + "assets" + File.separator + "uploads" + File.separator + "announcements";
            String newAttachmentPath = saveUpdatedAnnouncementFile(attachmentPart, uploadRoot);

            StringBuilder sql = new StringBuilder("UPDATE announcements SET title = ?, content = ?, target_dept = ?");
            if (!newAttachmentPath.isEmpty()) sql.append(", attachment_path = ?");
            sql.append(" WHERE announcement_id = ?");
            if (!isAdmin) sql.append(" AND poster_id = ?");

            PreparedStatement pstmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            pstmt.setString(idx++, title);
            pstmt.setString(idx++, content);
            pstmt.setString(idx++, existingTargetDept);
            if (!newAttachmentPath.isEmpty()) pstmt.setString(idx++, newAttachmentPath);
            pstmt.setInt(idx++, announcementId);
            if (!isAdmin) pstmt.setInt(idx++, currentUserId);

            int result = pstmt.executeUpdate();
            if (result > 0) {
                if (wantsRedirect) {
                    redirectWithStatus(response, redirectTo, "success", "updated");
                } else {
                    out.print("{\"status\":\"success\"}");
                }
            } else {
                if (wantsRedirect) {
                    redirectWithStatus(response, redirectTo, "error", "Update failed.");
                } else {
                    out.print("{\"status\":\"error\", \"message\":\"Update failed.\"}");
                }
            }
        }
    } catch (Exception e) {
        if (redirectTo != null && !redirectTo.trim().isEmpty()) {
            redirectWithStatus(response, redirectTo, "error", e.getMessage() != null ? e.getMessage() : "Update failed.");
        } else {
            out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
%>

