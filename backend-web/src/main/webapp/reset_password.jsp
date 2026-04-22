<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, org.mindrot.jbcrypt.BCrypt" %>
<%@ include file="/WEB-INF/jspf/account_helpers.jspf" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    String token = request.getParameter("token");
    if (token == null) token = "";
    token = token.trim();

    boolean tokenValid = false;
    boolean resetSuccessful = false;
    String feedbackClass = "danger";
    String feedbackMessage = "";
    String resolvedFullName = "";

    Connection conn = null;

    try {
        conn = getDbConnection(application);
        ensureUsersPersonalEmailColumn(conn);
        ensurePasswordResetTable(conn);

        if (!token.isEmpty()) {
            String tokenHash = sha256Hex(token);

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT t.user_id, t.expires_at, t.used_at, u.full_name " +
                    "FROM password_reset_tokens t " +
                    "INNER JOIN users u ON u.user_id = t.user_id " +
                    "WHERE t.token_hash = ?")) {
                ps.setString(1, tokenHash);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Timestamp expiresAt = rs.getTimestamp("expires_at");
                        Timestamp usedAt = rs.getTimestamp("used_at");
                        resolvedFullName = rs.getString("full_name") == null ? "" : rs.getString("full_name");
                        tokenValid = usedAt == null && expiresAt != null && expiresAt.after(new java.util.Date());
                    }
                }
            }
        }

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String newPassword = request.getParameter("new_password");
            String confirmPassword = request.getParameter("confirm_password");

            if (!tokenValid) {
                feedbackMessage = "This reset link is invalid or has expired.";
            } else if (newPassword == null || newPassword.trim().length() < 8) {
                feedbackMessage = "New password must be at least 8 characters long.";
            } else if (!newPassword.equals(confirmPassword)) {
                feedbackMessage = "The new passwords do not match.";
            } else {
                String tokenHash = sha256Hex(token);
                Integer userId = null;

                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT user_id FROM password_reset_tokens WHERE token_hash = ? AND used_at IS NULL AND expires_at > NOW()")) {
                    ps.setString(1, tokenHash);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            userId = rs.getInt("user_id");
                        }
                    }
                }

                if (userId == null) {
                    feedbackMessage = "This reset link is invalid or has expired.";
                    tokenValid = false;
                } else {
                    try (PreparedStatement updateUser = conn.prepareStatement("UPDATE users SET password = ? WHERE user_id = ?")) {
                        updateUser.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt(12)));
                        updateUser.setInt(2, userId);
                        updateUser.executeUpdate();
                    }

                    try (PreparedStatement markUsed = conn.prepareStatement(
                            "UPDATE password_reset_tokens SET used_at = NOW() WHERE token_hash = ?")) {
                        markUsed.setString(1, tokenHash);
                        markUsed.executeUpdate();
                    }

                    try (PreparedStatement cleanup = conn.prepareStatement(
                            "DELETE FROM password_reset_tokens WHERE user_id = ? AND token_hash <> ?")) {
                        cleanup.setInt(1, userId);
                        cleanup.setString(2, tokenHash);
                        cleanup.executeUpdate();
                    }

                    resetSuccessful = true;
                    tokenValid = false;
                    feedbackClass = "success";
                    feedbackMessage = "Your password has been reset successfully. You can now return to the desktop app and sign in.";
                }
            }
        }
    } catch (Exception e) {
        feedbackMessage = "Server Error: " + e.getMessage().replace("\"", "'");
        tokenValid = false;
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    if (!token.isEmpty() && !tokenValid && feedbackMessage.isEmpty() && !resetSuccessful) {
        feedbackMessage = "This reset link is invalid or has expired.";
    }

    if (token.isEmpty() && feedbackMessage.isEmpty()) {
        feedbackMessage = "A valid password reset link is required.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password | WSU IOCS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0f172a, #1d4ed8);
            font-family: "Segoe UI", sans-serif;
            padding: 24px;
        }

        .reset-card {
            width: 100%;
            max-width: 520px;
            border: none;
            border-radius: 24px;
            box-shadow: 0 30px 80px rgba(15, 23, 42, 0.28);
        }

        .form-control {
            border-radius: 14px;
            min-height: 48px;
        }

        .btn-primary {
            border-radius: 999px;
            min-height: 48px;
            font-weight: 700;
        }
    </style>
</head>
<body>
    <div class="card reset-card">
        <div class="card-body p-4 p-md-5">
            <div class="text-center mb-4">
                <img src="assets/img/wsu_logo.png" alt="WSU Logo" style="width: 72px; height: 72px; object-fit: contain;">
                <h2 class="fw-bold mt-3 mb-1">Password Reset</h2>
                <p class="text-muted mb-0">WSU Inter-Office Communication System</p>
            </div>

            <% if (!feedbackMessage.isEmpty()) { %>
                <div class="alert alert-<%= feedbackClass %> mb-4"><%= feedbackMessage %></div>
            <% } %>

            <% if (tokenValid) { %>
                <p class="text-muted">Reset password for <strong><%= resolvedFullName == null || resolvedFullName.isEmpty() ? "your account" : resolvedFullName %></strong>.</p>
                <form method="post">
                    <input type="hidden" name="token" value="<%= token %>">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">New Password</label>
                        <input type="password" class="form-control" name="new_password" placeholder="Enter a new password" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Confirm New Password</label>
                        <input type="password" class="form-control" name="confirm_password" placeholder="Repeat the new password" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Save New Password</button>
                </form>
            <% } else if (resetSuccessful) { %>
                <div class="d-grid gap-2">
                    <a href="index.jsp" class="btn btn-outline-primary">Go to Web Home</a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>

