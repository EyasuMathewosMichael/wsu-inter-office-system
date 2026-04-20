<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, java.io.*, java.nio.file.*, javax.servlet.http.*, org.json.JSONObject" %>
<%!
    private String sanitizeUploadFileName(String submittedFileName) {
        if (submittedFileName == null) return null;

        String fileName = Paths.get(submittedFileName).getFileName().toString().trim();
        if (fileName.isEmpty()) return null;

        return fileName.replaceAll("[^a-zA-Z0-9._-]", "_");
    }

    private String safeStoredImageName(String storedValue) {
        if (storedValue == null) return null;

        String normalized = storedValue.replace("\\", "/").trim();
        if (normalized.isEmpty()) return null;

        String fileName = normalized.substring(normalized.lastIndexOf('/') + 1);
        if (!fileName.matches("[a-zA-Z0-9._-]+")) return null;

        return fileName;
    }
%>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    JSONObject json = new JSONObject();
    File uploadedFile = null;
    String uploadPath = null;

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        json.put("success", false);
        json.put("message", "Only POST is allowed.");
        out.print(json.toString());
        return;
    }

    Object sessionUser = session.getAttribute("user_id");
    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        json.put("success", false);
        json.put("message", "Please login again.");
        out.print(json.toString());
        return;
    }

    try {
        String contentType = request.getContentType();
        if (contentType == null || !contentType.startsWith("multipart/form-data")) {
            json.put("success", false);
            json.put("message", "Invalid request format.");
            out.print(json.toString());
            return;
        }

        Part filePart = request.getPart("profile_pic");
        if (filePart == null || filePart.getSize() <= 0) {
            json.put("success", false);
            json.put("message", "Please choose a profile photo.");
            out.print(json.toString());
            return;
        }

        String originalFileName = sanitizeUploadFileName(filePart.getSubmittedFileName());
        if (originalFileName == null) {
            json.put("success", false);
            json.put("message", "Invalid file name.");
            out.print(json.toString());
            return;
        }

        int userId = Integer.parseInt(sessionUser.toString());
        String fileName = new java.util.Date().getTime() + "_" + originalFileName;

        String baseDir = application.getRealPath("/");
        if (baseDir == null) baseDir = request.getSession().getServletContext().getRealPath("");

        uploadPath = baseDir + File.separator + "assets" + File.separator + "img";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        uploadedFile = new File(uploadDir, fileName);
        filePart.write(uploadedFile.getAbsolutePath());

        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "")) {
            String oldPhotoPath = null;
            try (PreparedStatement psSelect = conn.prepareStatement("SELECT profile_pic_path FROM users WHERE user_id = ?")) {
                psSelect.setInt(1, userId);
                try (ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        oldPhotoPath = rs.getString("profile_pic_path");
                    }
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement("UPDATE users SET profile_pic_path = ? WHERE user_id = ?")) {
                psUpdate.setString(1, fileName);
                psUpdate.setInt(2, userId);

                if (psUpdate.executeUpdate() > 0) {
                    session.setAttribute("user_pic", fileName);

                    String safeOldPhoto = safeStoredImageName(oldPhotoPath);
                    if (safeOldPhoto != null &&
                            !safeOldPhoto.equals(fileName) &&
                            !safeOldPhoto.equals("default.png") &&
                            !safeOldPhoto.equals("default_profile.png") &&
                            !safeOldPhoto.equals("admin-avatar.png")) {
                        File oldFile = new File(uploadPath, safeOldPhoto);
                        if (oldFile.exists()) oldFile.delete();
                    }

                    json.put("success", true);
                    json.put("message", "Profile photo updated successfully.");
                    json.put("profile_pic_path", fileName);
                } else {
                    if (uploadedFile.exists()) uploadedFile.delete();
                    json.put("success", false);
                    json.put("message", "No database changes were made.");
                }
            }
        }
    } catch (Exception e) {
        if (uploadedFile != null && uploadedFile.exists()) uploadedFile.delete();
        json.put("success", false);
        json.put("message", "Server Error: " + e.getMessage().replace("\"", "'"));
    }

    out.print(json.toString());
%>
