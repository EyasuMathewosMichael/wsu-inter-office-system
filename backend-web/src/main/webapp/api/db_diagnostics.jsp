<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*, org.json.JSONObject" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    JSONObject json = new JSONObject();
    Connection conn = null;

    try {
        String url = getDbUrl(application);
        String username = getDbUsername(application);

        json.put("db_driver", getDbDriver(application));
        json.put("db_url", url);
        json.put("db_username", username);
        json.put("db_password_configured", getDbPassword(application) != null && !getDbPassword(application).isEmpty());

        conn = getDbConnection(application);
        json.put("status", "success");

        try (PreparedStatement ps = conn.prepareStatement("SELECT DATABASE() AS db_name, CURRENT_USER() AS db_user");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                json.put("database", rs.getString("db_name"));
                json.put("current_user", rs.getString("db_user"));
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS admin_count FROM users WHERE username = ? AND role = 'Admin'")) {
            ps.setString(1, "admin");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    json.put("admin_user_count", rs.getInt("admin_count"));
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT user_id, username, role, password IS NOT NULL AS has_password FROM users WHERE username = ?")) {
            ps.setString(1, "admin");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    json.put("admin_user_id", rs.getInt("user_id"));
                    json.put("admin_username", rs.getString("username"));
                    json.put("admin_role", rs.getString("role"));
                    json.put("admin_has_password", rs.getBoolean("has_password"));
                }
            }
        }
    } catch (Exception e) {
        json.put("status", "error");
        json.put("error_class", e.getClass().getName());
        json.put("error_message", e.getMessage());
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (Exception ignored) {}
        }
    }

    out.print(json.toString());
%>
