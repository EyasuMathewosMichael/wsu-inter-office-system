<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.File" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>

<%
    // 1. Get the ID of the user to be deleted [cite: 2026-01-21]
    String userIdStr = request.getParameter("id");

    if (userIdStr != null && !userIdStr.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement psSelect = null;
        PreparedStatement psDeleteChats = null;
        PreparedStatement psDeleteUser = null;

        try {
            int userId = Integer.parseInt(userIdStr.trim());

            // 2. Database Connection [cite: 2026-01-21, 2026-01-28]
            conn = getDbConnection(application);

            // Disable auto-commit to treat this as a single transaction
            conn.setAutoCommit(false);

            // 3. File Cleanup: Retrieve and delete the profile picture [cite: 2026-01-26]
            psSelect = conn.prepareStatement("SELECT profile_pic_path FROM users WHERE user_id = ?");
            psSelect.setInt(1, userId);
            ResultSet rs = psSelect.executeQuery();

            if (rs.next()) {
                String fileName = rs.getString("profile_pic_path");
                // Safety: Never delete the default avatar or empty paths
                if (fileName != null && !fileName.isEmpty() && !fileName.equalsIgnoreCase("default-avatar.png")) {
                    String uploadPath = getServletContext().getRealPath("/") + "assets" + File.separator + "img";
                    File file = new File(uploadPath + File.separator + fileName);

                    if (file.exists() && file.isFile()) {
                        file.delete();
                    }
                }
            }

            // 4. Integrity Protection: Delete associated messages first
            // This prevents "Foreign Key Constraint" errors in the inter_office_db [cite: 2026-03-02]
            String sqlDeleteChats = "DELETE FROM chats WHERE sender_id = ? OR receiver_id = ?";
            psDeleteChats = conn.prepareStatement(sqlDeleteChats);
            psDeleteChats.setInt(1, userId);
            psDeleteChats.setInt(2, userId);
            psDeleteChats.executeUpdate();

            // 5. Delete the user record
            String sqlDeleteUser = "DELETE FROM users WHERE user_id = ?";
            psDeleteUser = conn.prepareStatement(sqlDeleteUser);
            psDeleteUser.setInt(1, userId);
            int result = psDeleteUser.executeUpdate();

            // Commit the transaction
            conn.commit();

            if (result > 0) {
                response.sendRedirect("../admin/manage_users.jsp?status=success");
            } else {
                response.sendRedirect("../admin/manage_users.jsp?status=error");
            }

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignore) {}
            e.printStackTrace();
            response.sendRedirect("../admin/manage_users.jsp?status=error&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } finally {
            // 6. SPEED FIX: Close resources in reverse order [cite: 2026-01-21]
            if (psSelect != null) try { psSelect.close(); } catch (SQLException ignore) {}
            if (psDeleteChats != null) try { psDeleteChats.close(); } catch (SQLException ignore) {}
            if (psDeleteUser != null) try { psDeleteUser.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    } else {
        response.sendRedirect("../admin/manage_users.jsp");
    }
%>
