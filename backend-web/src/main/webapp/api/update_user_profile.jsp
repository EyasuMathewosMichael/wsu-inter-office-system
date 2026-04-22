<%@ page import="java.sql.*, org.json.JSONObject" %>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/jspf/account_helpers.jspf" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
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

    Object sessionUser = session.getAttribute("user_id");
    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        json.put("success", false);
        json.put("message", "Please login again.");
        out.print(json.toString());
        return;
    }

    String phone = request.getParameter("phone");
    String bio = request.getParameter("bio");
    String personalEmail = request.getParameter("personal_email");

    if (phone == null) phone = "";
    if (bio == null) bio = "";
    if (personalEmail == null) personalEmail = "";

    phone = phone.trim();
    bio = bio.trim();
    personalEmail = normalizeEmail(personalEmail);

    if (phone.length() > 30) {
        json.put("success", false);
        json.put("message", "Phone number is too long.");
        out.print(json.toString());
        return;
    }

    if (!personalEmail.isEmpty() && !isValidEmailFormat(personalEmail)) {
        json.put("success", false);
        json.put("message", "Enter a valid personal email address.");
        out.print(json.toString());
        return;
    }

    if (bio.length() > 1000) {
        json.put("success", false);
        json.put("message", "Bio is too long.");
        out.print(json.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        int userId = Integer.parseInt(sessionUser.toString());
        conn = getDbConnection(application);
        ensureUsersPersonalEmailColumn(conn);

        if (!personalEmail.isEmpty()) {
            try (PreparedStatement checkEmail = conn.prepareStatement("SELECT user_id FROM users WHERE personal_email = ? AND user_id <> ?")) {
                checkEmail.setString(1, personalEmail);
                checkEmail.setInt(2, userId);
                try (ResultSet rs = checkEmail.executeQuery()) {
                    if (rs.next()) {
                        json.put("success", false);
                        json.put("message", "That personal email is already used by another account.");
                        out.print(json.toString());
                        return;
                    }
                }
            }
        }

        ps = conn.prepareStatement("UPDATE users SET phone = ?, bio = ?, personal_email = ? WHERE user_id = ?");
        ps.setString(1, phone);
        ps.setString(2, bio);
        if (personalEmail.isEmpty()) {
            ps.setNull(3, java.sql.Types.VARCHAR);
        } else {
            ps.setString(3, personalEmail);
        }
        ps.setInt(4, userId);

        int rows = ps.executeUpdate();
        session.setAttribute("user_phone", phone);
        session.setAttribute("user_bio", bio);
        session.setAttribute("user_personal_email", personalEmail);

        json.put("success", true);
        json.put("message", rows > 0 ? "Profile details updated successfully." : "Profile details saved.");
        json.put("phone", phone);
        json.put("bio", bio);
        json.put("personal_email", personalEmail);
    } catch (Exception e) {
        json.put("success", false);
        json.put("message", "Server Error: " + e.getMessage().replace("\"", "'"));
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    out.print(json.toString());
%>

