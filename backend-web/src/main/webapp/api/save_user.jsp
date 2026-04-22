<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*, org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ page import="java.nio.file.Paths" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>

<%
    request.setCharacterEncoding("UTF-8");
    String contentType = request.getContentType();

    if (contentType != null && contentType.contains("multipart/form-data")) {
        String fullName = "", username = "", password = "", role = "", department = "";
        String fileName = "default-avatar.png";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // 1. Extract Text Fields from Multipart Parts
            // Standard request.getParameter does not work with multipart/form-data
            for (Part part : request.getParts()) {
                String name = part.getName();
                if (part.getSubmittedFileName() == null) {
                    try (Scanner s = new Scanner(part.getInputStream(), "UTF-8")) {
                        String value = s.hasNext() ? s.useDelimiter("\\A").next() : "";
                        if ("full_name".equals(name)) fullName = value;
                        else if ("username".equals(name)) username = value;
                        else if ("password".equals(name)) password = value;
                        else if ("role".equals(name)) role = value;
                        else if ("department".equals(name)) department = value;
                    }
                }
            }

            // 2. Handle File Upload (Profile Picture)
            Part filePart = request.getPart("profile_pic");
            if (filePart != null && filePart.getSize() > 0) {
                String submittedFile = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                // REPLACEMENT FIX: Use java.util.Date to avoid the "System cannot be resolved" bug
                long timestamp = new java.util.Date().getTime();

                // Sanitize filename: alphanumeric, dots, and dashes only
                fileName = timestamp + "_" + submittedFile.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");

                // Target: /assets/img/ [cite: 2026-01-26]
                String uploadPath = getServletContext().getRealPath("/") + "assets" + File.separator + "img";
                File uploadDir = new File(uploadPath);

                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                filePart.write(uploadPath + File.separator + fileName);
            }

            // 3. Database Operation
            conn = getDbConnection(application);

            String sql = "INSERT INTO users (full_name, username, password, role, department, profile_pic_path, created_at) " +
                         "VALUES (?, ?, ?, ?, ?, ?, NOW())";

            ps = conn.prepareStatement(sql);
            ps.setString(1, fullName);
            ps.setString(2, username);
            ps.setString(3, BCrypt.hashpw(password, BCrypt.gensalt(12)));
            ps.setString(4, role);
            ps.setString(5, department);
            ps.setString(6, fileName);

            int row = ps.executeUpdate();

            if (row > 0) {
                response.sendRedirect("../admin/manage_users.jsp?status=success");
            } else {
                response.sendRedirect("../admin/manage_users.jsp?status=error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            // Redirect with error detail for easier debugging in development
            String encodedMsg = java.net.URLEncoder.encode(e.getMessage(), "UTF-8");
            response.sendRedirect("../admin/manage_users.jsp?status=error&msg=" + encodedMsg);
        } finally {
            // Speed Fix: Close resources immediately
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    } else {
        out.println("Error: Invalid Request Type. Please use the form in manage_users.jsp.");
    }
%>

