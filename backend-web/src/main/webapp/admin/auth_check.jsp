<%@ page trimDirectiveWhitespaces="true" %><%
    // Verify Admin role with a recovery path for partially restored sessions.
    Object adminId = session.getAttribute("admin_id");
    Object userId = session.getAttribute("user_id");
    Object role = session.getAttribute("admin_role");
    Object userRole = session.getAttribute("user_role");

    boolean hasAdminId = adminId != null;
    boolean hasAdminRole = role != null && "Admin".equalsIgnoreCase(role.toString().trim());
    boolean hasAdminUserRole = userRole != null && "Admin".equalsIgnoreCase(userRole.toString().trim());

    if (!hasAdminId && userId != null && hasAdminUserRole) {
        session.setAttribute("admin_id", userId);
        adminId = userId;
        hasAdminId = true;
    }

    if (hasAdminId || hasAdminRole || hasAdminUserRole) {
        session.setAttribute("admin_role", "Admin");
        session.setAttribute("user_role", "Admin");
        role = "Admin";
    }

    if (role == null || !"Admin".equalsIgnoreCase(role.toString().trim())) {
        // Detect if the request is coming from an API call (AJAX)
        String xRequestedWith = request.getHeader("X-Requested-With");
        String uri = request.getRequestURI();

        if ("XMLHttpRequest".equals(xRequestedWith) || uri.contains("/api/")) {
            // Prevent HTML redirects from breaking JSON parsers
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            out.print("{\"error\":\"session_expired\", \"message\":\"Please login again.\"}");
            out.flush();
            return;
        } else {
            // Standard page redirect for direct browser access
            String debugFlags =
                "&has_admin_id=" + (adminId != null) +
                "&has_admin_role=" + (session.getAttribute("admin_role") != null) +
                "&has_user_id=" + (userId != null) +
                "&has_user_role=" + (userRole != null);
            response.sendRedirect(response.encodeRedirectURL("login.jsp?error=unauthorized&reason=auth_check" + debugFlags));
            return;
        }
    }
%>
