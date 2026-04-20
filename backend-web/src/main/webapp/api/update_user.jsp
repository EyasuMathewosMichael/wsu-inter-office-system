<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*, org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ include file="../admin/auth_check.jsp" %>

<%
    // Ensure consistent encoding for university data
    request.setCharacterEncoding("UTF-8");

    String dbUrl = "jdbc:mysql://localhost:3306/inter_office_db";
    String dbUser = "root";
    String dbPass = "";

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        // 1. Extract Multipart Text Fields
        // request.getParameter() returns null in multipart forms; we must read the parts manually.
        Map<String, String> fields = new HashMap<>();
        for (Part part : request.getParts()) {
            if (part.getSubmittedFileName() == null) {
                try (Scanner s = new Scanner(part.getInputStream(), "UTF-8")) {
                    fields.put(part.getName(), s.hasNext() ? s.useDelimiter("\\A").next() : "");
                }
            }
        }

        String userId = fields.get("user_id");
        String fullName = fields.get("full_name");
        String username = fields.get("username");
        String password = fields.get("password");

        // RENAMED to updatedRole to avoid conflict with 'role' defined in auth_check.jsp
        String updatedRole = fields.get("role");

        String department = fields.get("department");

        if (userId == null || userId.isEmpty()) throw new Exception("User ID missing from request");

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 2. Handle Photo Upload & Storage Hygiene
        Part filePart = request.getPart("profile_pic");
        String newFileName = null;
        boolean isPhotoUploaded = (filePart != null && filePart.getSize() > 0);
        boolean hasPassword = (password != null && !password.trim().isEmpty());

        if (isPhotoUploaded) {
            // Cleanup: Retrieve and delete the old photo file to save university server space
            try (PreparedStatement psOld = conn.prepareStatement("SELECT profile_pic_path FROM users WHERE user_id=?")) {
                psOld.setInt(1, Integer.parseInt(userId));
                ResultSet rs = psOld.executeQuery();
                if (rs.next()) {
                    String oldFile = rs.getString("profile_pic_path");
                    if (oldFile != null && !oldFile.equalsIgnoreCase("default-avatar.png")) {
                        File f = new File(getServletContext().getRealPath("/") + "assets/img/" + oldFile);
                        if (f.exists()) f.delete();
                    }
                }
            }

            // Save New Photo with timestamp to prevent naming collisions
            long timestamp = new java.util.Date().getTime();
            newFileName = timestamp + "_" + filePart.getSubmittedFileName().replaceAll("[^a-zA-Z0-9\\.\\-]", "_");

            String path = getServletContext().getRealPath("/") + "assets" + File.separator + "img";
            File uploadDir = new File(path);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            filePart.write(path + File.separator + newFileName);
        }

        // 3. Dynamic SQL Construction based on optional fields
        StringBuilder sql = new StringBuilder("UPDATE users SET full_name=?, username=?, role=?, department=?");
        if (isPhotoUploaded) sql.append(", profile_pic_path=?");
        if (hasPassword) sql.append(", password=?");
        sql.append(" WHERE user_id=?");

        ps = conn.prepareStatement(sql.toString());

        int i = 1;
        ps.setString(i++, fullName);
        ps.setString(i++, username);
        ps.setString(i++, updatedRole); // Using the renamed variable
        ps.setString(i++, department);

        if (isPhotoUploaded) ps.setString(i++, newFileName);
        if (hasPassword) ps.setString(i++, BCrypt.hashpw(password, BCrypt.gensalt(12)));
        ps.setInt(i++, Integer.parseInt(userId));

        ps.executeUpdate();
        response.sendRedirect("../admin/manage_users.jsp?status=success");

    } catch (Exception e) {
        e.printStackTrace();
        String errorMsg = (e.getMessage() != null) ? e.getMessage() : "Unknown Update Error";
        response.sendRedirect("../admin/manage_users.jsp?status=error&msg=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
