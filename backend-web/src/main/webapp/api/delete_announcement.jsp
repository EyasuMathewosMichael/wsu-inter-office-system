<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.File, org.json.*" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private File resolveAnnouncementFile(String storedPath, String appRoot) {
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

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        out.print(new JSONObject().put("status", "error").put("message", "POST required.").toString());
        return;
    }

    Object sessionUser = session.getAttribute("user_id");
    String sessionRole = (String) session.getAttribute("user_role");
    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print(new JSONObject().put("status", "error").put("message", "Please login again.").toString());
        return;
    }

    String announcementId = request.getParameter("id");
    if (announcementId == null || announcementId.trim().isEmpty()) {
        out.print(new JSONObject().put("status", "error").put("message", "Announcement ID required.").toString());
        return;
    }

    int currentUserId = Integer.parseInt(sessionUser.toString());
    boolean isAdmin = "Admin".equalsIgnoreCase(sessionRole);

    Connection conn = null;
    PreparedStatement pstmtFetch = null;
    PreparedStatement pstmtDelete = null;

    try {
        conn = getDbConnection(application);

        pstmtFetch = conn.prepareStatement("SELECT poster_id, attachment_path FROM announcements WHERE announcement_id = ?");
        pstmtFetch.setInt(1, Integer.parseInt(announcementId));
        ResultSet rs = pstmtFetch.executeQuery();

        if (!rs.next()) {
            out.print(new JSONObject().put("status", "error").put("message", "Announcement not found.").toString());
            return;
        }

        int ownerId = rs.getInt("poster_id");
        String filePath = rs.getString("attachment_path");
        if (!isAdmin && ownerId != currentUserId) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print(new JSONObject().put("status", "error").put("message", "You cannot delete this announcement.").toString());
            return;
        }

        pstmtDelete = conn.prepareStatement("DELETE FROM announcements WHERE announcement_id = ?");
        pstmtDelete.setInt(1, Integer.parseInt(announcementId));
        int result = pstmtDelete.executeUpdate();

        if (result > 0) {
            File fileToDelete = resolveAnnouncementFile(filePath, getServletContext().getRealPath("/"));
            if (fileToDelete != null && fileToDelete.exists()) {
                fileToDelete.delete();
            }
        }

        JSONObject json = new JSONObject();
        json.put("status", result > 0 ? "success" : "error");
        out.print(json.toString());
    } catch (Exception e) {
        out.print(new JSONObject().put("status", "error").put("message", e.getMessage()).toString());
    } finally {
        if (pstmtFetch != null) try { pstmtFetch.close(); } catch (SQLException ignore) {}
        if (pstmtDelete != null) try { pstmtDelete.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

