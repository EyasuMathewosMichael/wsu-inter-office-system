<%@ page trimDirectiveWhitespaces="true" %><%
    // Verify Admin role with a small recovery path for partially restored sessions.
    Object role = session.getAttribute("admin_role");
    if (role == null || !"Admin".equals(role)) {
        Object adminId = session.getAttribute("admin_id");
        Object userId = session.getAttribute("user_id");
        Object userRole = session.getAttribute("user_role");

        boolean looksLikeAdminSession =
            adminId != null ||
            (
                userId != null &&
                userRole != null &&
                "Admin".equalsIgnoreCase(userRole.toString())
            );

        if (looksLikeAdminSession) {
            session.setAttribute("admin_role", "Admin");
            role = "Admin";
            if (adminId == null && userId != null) {
                session.setAttribute("admin_id", userId);
            }
        }
    }

    if (role == null || !role.equals("Admin")) {
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
            response.sendRedirect(response.encodeRedirectURL("login.jsp?error=unauthorized"));
            return;
        }
    }
%>
