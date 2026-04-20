<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%@ include file="../admin/auth_check.jsp" %>

<%
    // Ensure the request is multipart (contains a file)
    if (!ServletFileUpload.isMultipartContent(request)) {
        response.sendRedirect("../admin/announcements.jsp?status=error&msg=InvalidForm");
        return;
    }

    // Centralized upload directory for web and desktop access [cite: 2026-01-28]
    String uploadPath = "C:/university_uploads/";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdir();

    String title = "", targetDept = "", content = "", attachmentPath = "";
    int adminId = 1; // Explicit Admin ID to fix NULL poster_id issue [cite: 2026-02-25]

    try {
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        List<FileItem> formItems = upload.parseRequest(request);

        for (FileItem item : formItems) {
            if (item.isFormField()) {
                // Process regular text fields
                String fieldName = item.getFieldName();
                String value = item.getString("UTF-8");

                if (fieldName.equals("title")) title = value;
                if (fieldName.equals("target_dept")) targetDept = value;
                if (fieldName.equals("content")) content = value;
            } else {
                // Process the file attachment
                String fileName = new File(item.getName()).getName();
                if (fileName != null && !fileName.isEmpty()) {
                    // FIX: Using Date().getTime() instead of System.currentTimeMillis()
                    // to resolve the 'System cannot be resolved' JSP compiler error.
                    long timestamp = new java.util.Date().getTime();
                    String uniqueName = timestamp + "_" + fileName;

                    File storeFile = new File(uploadPath + uniqueName);
                    item.write(storeFile);

                    // Store normalized absolute path for Desktop app compatibility [cite: 2026-01-21]
                    attachmentPath = storeFile.getAbsolutePath().replace("\\", "/");
                }
            }
        }

        // Database Insertion [cite: 2026-02-25]
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");

        String sql = "INSERT INTO announcements (poster_id, title, target_dept, content, attachment_path) VALUES (?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);

        pstmt.setInt(1, adminId);
        pstmt.setString(2, title);
        pstmt.setString(3, targetDept);
        pstmt.setString(4, content);
        pstmt.setString(5, attachmentPath);

        pstmt.executeUpdate();
        conn.close();

        // Redirect back to dashboard with success message
        response.sendRedirect("../admin/announcements.jsp?status=success");

    } catch (Exception e) {
        // Detailed error reporting for debugging
        String encodedError = java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Unknown Error", "UTF-8");
        response.sendRedirect("../admin/announcements.jsp?status=error&msg=" + encodedError);
    }
%>