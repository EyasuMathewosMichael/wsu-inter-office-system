<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, java.io.*, javax.servlet.http.*, java.nio.file.*, java.util.*, org.mindrot.jbcrypt.BCrypt, org.json.JSONObject" %>
<%@ include file="../admin/auth_check.jsp" %>
<%@ include file="/WEB-INF/jspf/account_helpers.jspf" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
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
    out.clear();
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    JSONObject json = new JSONObject();
    String status = "error";
    String message = "";

    Object adminObj = session.getAttribute("admin_id");
    if (adminObj == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        json.put("status", "error");
        json.put("message", "Please login again.");
        out.print(json.toString());
        return;
    }

    int currentAdminId = Integer.parseInt(adminObj.toString());
    String fullName = null;
    String bio = "";
    String phone = "";
    String personalEmail = "";
    String newPassword = "";
    String fileName = null;
    File uploadedFile = null;
    String uploadPath = null;

    try {
        String contentType = request.getContentType();
        if (contentType == null || !contentType.startsWith("multipart/form-data")) {
            message = "Invalid request format.";
        } else {
            Collection<Part> parts = request.getParts();

            for (Part part : parts) {
                String name = part.getName();
                if (part.getSubmittedFileName() == null) {
                    try (Scanner scanner = new Scanner(part.getInputStream(), "UTF-8")) {
                        String value = scanner.hasNext() ? scanner.useDelimiter("\\A").next() : "";
                        if ("full_name".equals(name)) fullName = value.trim();
                        else if ("bio".equals(name)) bio = value.trim();
                        else if ("phone".equals(name)) phone = value.trim();
                        else if ("personal_email".equals(name)) personalEmail = normalizeEmail(value);
                        else if ("new_password".equals(name)) newPassword = value.trim();
                    }
                } else if ("profile_pic".equals(name) && part.getSize() > 0) {
                    String originalFileName = sanitizeUploadFileName(part.getSubmittedFileName());
                    if (originalFileName != null) {
                        long timestamp = new java.util.Date().getTime();
                        fileName = timestamp + "_" + originalFileName;

                        String baseDir = getServletContext().getRealPath("/");
                        if (baseDir == null) baseDir = request.getSession().getServletContext().getRealPath("");

                        uploadPath = baseDir + File.separator + "assets" + File.separator + "img";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdirs();

                        uploadedFile = new File(uploadDir, fileName);
                        part.write(uploadedFile.getAbsolutePath());
                    }
                }
            }

            if (fullName == null || fullName.trim().isEmpty()) {
                message = "Full name is required.";
            } else if (phone != null && phone.length() > 30) {
                message = "Phone number is too long.";
            } else if (personalEmail != null && !personalEmail.isEmpty() && !isValidEmailFormat(personalEmail)) {
                message = "Enter a valid personal email address.";
            } else {
                try (Connection conn = getDbConnection(application)) {
                    ensureUsersPersonalEmailColumn(conn);

                    if (personalEmail != null && !personalEmail.isEmpty()) {
                        try (PreparedStatement psEmail = conn.prepareStatement("SELECT user_id FROM users WHERE personal_email = ? AND user_id <> ?")) {
                            psEmail.setString(1, personalEmail);
                            psEmail.setInt(2, currentAdminId);
                            try (ResultSet rsEmail = psEmail.executeQuery()) {
                                if (rsEmail.next()) {
                                    message = "That personal email is already used by another account.";
                                }
                            }
                        }
                    }

                    if (!message.isEmpty()) {
                        if (uploadedFile != null && uploadedFile.exists()) uploadedFile.delete();
                        json.put("status", status);
                        json.put("message", message);
                        out.clear();
                        out.print(json.toString());
                        out.flush();
                        return;
                    }

                    String oldPhotoPath = null;
                    try (PreparedStatement psOld = conn.prepareStatement("SELECT profile_pic_path FROM users WHERE user_id = ?")) {
                        psOld.setInt(1, currentAdminId);
                        try (ResultSet rs = psOld.executeQuery()) {
                            if (rs.next()) oldPhotoPath = rs.getString("profile_pic_path");
                        }
                    }

                    StringBuilder sql = new StringBuilder("UPDATE users SET full_name = ?, bio = ?, phone = ?, personal_email = ?");
                    if (newPassword != null && !newPassword.isEmpty()) sql.append(", password = ?");
                    if (fileName != null) sql.append(", profile_pic_path = ?");
                    sql.append(" WHERE user_id = ?");

                    try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                        int idx = 1;
                        ps.setString(idx++, fullName.trim());
                        ps.setString(idx++, bio != null ? bio : "");
                        ps.setString(idx++, phone != null ? phone : "");
                        if (personalEmail != null && !personalEmail.isEmpty()) {
                            ps.setString(idx++, personalEmail);
                        } else {
                            ps.setNull(idx++, java.sql.Types.VARCHAR);
                        }

                        if (newPassword != null && !newPassword.isEmpty()) {
                            ps.setString(idx++, BCrypt.hashpw(newPassword, BCrypt.gensalt(12)));
                        }
                        if (fileName != null) ps.setString(idx++, fileName);
                        ps.setInt(idx, currentAdminId);

                        if (ps.executeUpdate() > 0) {
                            status = "success";
                            message = "Profile updated successfully!";

                            session.setAttribute("admin_name", fullName.trim());
                            session.setAttribute("user_name", fullName.trim());
                            session.setAttribute("user_phone", phone != null ? phone : "");
                            session.setAttribute("user_personal_email", personalEmail != null ? personalEmail : "");
                            if (fileName != null) session.setAttribute("user_pic", fileName);

                            if (fileName != null) {
                                String safeOldPhoto = safeStoredImageName(oldPhotoPath);
                                if (safeOldPhoto != null &&
                                        !safeOldPhoto.equals("admin-avatar.png") &&
                                        !safeOldPhoto.equals("default.png") &&
                                        !safeOldPhoto.equals("default_profile.png")) {
                                    File oldFile = new File(uploadPath, safeOldPhoto);
                                    if (oldFile.exists()) oldFile.delete();
                                }
                            }
                        } else {
                            message = "No database changes were made.";
                            if (uploadedFile != null && uploadedFile.exists()) uploadedFile.delete();
                        }
                    }
                }
            }
        }
    } catch (Exception e) {
        if (uploadedFile != null && uploadedFile.exists()) uploadedFile.delete();
        message = "Server Error: " + e.getMessage().replace("\"", "'");
    }

    json.put("status", status);
    json.put("message", message);
    out.clear();
    out.print(json.toString());
    out.flush();
%>

