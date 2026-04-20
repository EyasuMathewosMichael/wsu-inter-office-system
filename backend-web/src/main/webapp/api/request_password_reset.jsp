<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, org.json.JSONObject" %>
<%@ include file="/WEB-INF/jspf/account_helpers.jspf" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    JSONObject json = new JSONObject();

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        json.put("success", false);
        json.put("message", "Only POST is allowed.");
        out.print(json.toString());
        return;
    }

    String username = request.getParameter("username");
    String personalEmail = normalizeEmail(request.getParameter("personal_email"));

    if (username == null) username = "";
    username = username.trim();

    if (username.isEmpty() || personalEmail.isEmpty()) {
        json.put("success", false);
        json.put("message", "Username and personal email are required.");
        out.print(json.toString());
        return;
    }

    if (!isValidEmailFormat(personalEmail)) {
        json.put("success", false);
        json.put("message", "Enter a valid personal email address.");
        out.print(json.toString());
        return;
    }

    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");
        ensureUsersPersonalEmailColumn(conn);
        ensurePasswordResetTable(conn);

        Integer userId = null;
        String fullName = null;

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT user_id, full_name FROM users WHERE username = ? AND personal_email = ?")) {
            ps.setString(1, username);
            ps.setString(2, personalEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("user_id");
                    fullName = rs.getString("full_name");
                }
            }
        }

        if (userId != null) {
            String token = generateResetToken();
            String tokenHash = sha256Hex(token);

            try (PreparedStatement deleteOld = conn.prepareStatement(
                    "DELETE FROM password_reset_tokens WHERE user_id = ? OR expires_at < NOW()")) {
                deleteOld.setInt(1, userId);
                deleteOld.executeUpdate();
            }

            try (PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 30 MINUTE))")) {
                insert.setInt(1, userId);
                insert.setString(2, tokenHash);
                insert.executeUpdate();
            }

            String mailError = sendPasswordResetEmail(getServletContext(), request, personalEmail, fullName, token);
            if (mailError != null) {
                try (PreparedStatement cleanup = conn.prepareStatement("DELETE FROM password_reset_tokens WHERE user_id = ?")) {
                    cleanup.setInt(1, userId);
                    cleanup.executeUpdate();
                }
                json.put("success", false);
                json.put("message", mailError);
                out.print(json.toString());
                return;
            }
        }

        json.put("success", true);
        json.put("message", "If the username and personal email match an account, a reset link has been sent.");
    } catch (Exception e) {
        json.put("success", false);
        json.put("message", "Server Error: " + e.getMessage().replace("\"", "'"));
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    out.print(json.toString());
%>
