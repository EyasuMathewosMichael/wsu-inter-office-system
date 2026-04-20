<%@ page trimDirectiveWhitespaces="true" %><%
    // Verify Admin Role [cite: 2026-01-28]
    Object role = session.getAttribute("admin_role");

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
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }
    }
%>