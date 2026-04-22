<%@ page import="java.io.*, java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private File resolveAnnouncementStreamFile(String storedPath, String appRoot) {
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
    Object sessionUser = session.getAttribute("user_id");
    String sessionRole = (String) session.getAttribute("user_role");
    String sessionDept = (String) session.getAttribute("user_department");

    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.println("Unauthorized");
        return;
    }

    String id = request.getParameter("id");
    if (id == null || id.trim().isEmpty()) {
        out.println("Error: No ID provided.");
        return;
    }

    Connection conn = null;
    try {
        int currentUserId = Integer.parseInt(sessionUser.toString());
        conn = getDbConnection(application);

        PreparedStatement ps = conn.prepareStatement("SELECT poster_id, target_dept, attachment_path FROM announcements WHERE announcement_id = ?");
        ps.setInt(1, Integer.parseInt(id));
        ResultSet rs = ps.executeQuery();

        if (!rs.next()) {
            out.println("Error: File record not found.");
            return;
        }

        int posterId = rs.getInt("poster_id");
        String targetDept = rs.getString("target_dept");
        boolean isAdmin = "Admin".equalsIgnoreCase(sessionRole);
        boolean canAccess = isAdmin || posterId == currentUserId || "Global".equalsIgnoreCase(targetDept) || (targetDept != null && targetDept.equalsIgnoreCase(sessionDept));

        if (!canAccess) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.println("Forbidden");
            return;
        }

        String filePath = rs.getString("attachment_path");
        if (filePath == null || filePath.trim().isEmpty()) {
            out.println("Error: No file was attached to this announcement.");
            return;
        }

        File file = resolveAnnouncementStreamFile(filePath, getServletContext().getRealPath("/"));
        if (file == null || !file.exists() || file.isDirectory()) {
            out.println("Error: File not found.");
            return;
        }

        response.reset();
        String mimeType = getServletContext().getMimeType(file.getName());
        response.setContentType(mimeType != null ? mimeType : "application/octet-stream");
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
        response.setContentLengthLong(file.length());

        try (BufferedInputStream in = new BufferedInputStream(new FileInputStream(file));
             BufferedOutputStream outStream = new BufferedOutputStream(response.getOutputStream())) {
            byte[] buffer = new byte[8192];
            int length;
            while ((length = in.read(buffer)) > 0) {
                outStream.write(buffer, 0, length);
            }
            outStream.flush();
        }
    } catch (Exception e) {
        out.println("System Error");
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

