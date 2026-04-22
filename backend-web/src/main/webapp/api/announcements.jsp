<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*, java.util.*, java.io.*, javax.servlet.http.Part, java.nio.file.Paths" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private String saveAnnouncementUpload(Part part, String uploadRoot) throws Exception {
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
%>
<%
    response.setContentType("application/json");

    Object sessionUser = session.getAttribute("user_id");
    String sessionRole = (String) session.getAttribute("user_role");
    String sessionDept = (String) session.getAttribute("user_department");

    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print(new JSONObject().put("status", "error").put("message", "Please login again.").toString());
        return;
    }

    boolean canPost = "Admin".equalsIgnoreCase(sessionRole) || "Dept Head".equalsIgnoreCase(sessionRole);
    if (!canPost) {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        out.print(new JSONObject().put("status", "error").put("message", "Only administrators and department heads can post announcements.").toString());
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        out.print(new JSONObject().put("status", "error").put("message", "POST required.").toString());
        return;
    }

    Map<String, String> fields = new HashMap<>();
    Part attachmentPart = null;
    boolean isMultipart = request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/");

    try {
        if (isMultipart) {
            for (Part part : request.getParts()) {
                if (part.getSubmittedFileName() == null) {
                    try (Scanner scanner = new Scanner(part.getInputStream(), "UTF-8")) {
                        fields.put(part.getName(), scanner.hasNext() ? scanner.useDelimiter("\\A").next().trim() : "");
                    }
                } else if ("attachment".equals(part.getName()) && part.getSize() > 0) {
                    attachmentPart = part;
                }
            }
        } else {
            Enumeration<String> names = request.getParameterNames();
            while (names.hasMoreElements()) {
                String name = names.nextElement();
                fields.put(name, request.getParameter(name));
            }
        }

        String targetDept = fields.get("target_dept");
        if (targetDept == null || targetDept.trim().isEmpty()) {
            targetDept = sessionDept;
        }

        String uploadRoot = getServletContext().getRealPath("/") + "assets" + File.separator + "uploads" + File.separator + "announcements";
        String attachmentPath = saveAnnouncementUpload(attachmentPart, uploadRoot);
        try (Connection conn = getDbConnection(application)) {
            String sql = "INSERT INTO announcements (poster_id, title, content, attachment_path, target_dept, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(sessionUser.toString()));
            ps.setString(2, fields.get("title"));
            ps.setString(3, fields.get("content"));
            if (attachmentPath.isEmpty()) ps.setNull(4, Types.VARCHAR);
            else ps.setString(4, attachmentPath);
            ps.setString(5, targetDept);

            int rows = ps.executeUpdate();
            JSONObject res = new JSONObject();
            if (rows > 0) res.put("status", "success");
            else res.put("status", "error").put("message", "No rows inserted");
            out.print(res.toString());
        }
    } catch (Exception e) {
        out.print(new JSONObject().put("status", "error").put("message", e.getMessage()).toString());
    }
%>

