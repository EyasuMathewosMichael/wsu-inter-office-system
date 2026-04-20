<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. Clear all session attributes [cite: 2026-01-21]
    session.removeAttribute("admin_id");
    session.removeAttribute("admin_name");
    session.removeAttribute("admin_role");

    // 2. Completely invalidate the session
    session.invalidate();

    // 3. Redirect back to the login page with a success message [cite: 2026-01-26, 2026-01-28]
    response.sendRedirect("admin/login.jsp?status=logged_out");
%>