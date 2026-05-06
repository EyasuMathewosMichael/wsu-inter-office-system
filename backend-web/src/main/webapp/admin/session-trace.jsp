<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Session Trace</title>
    <style>
        body { font-family: monospace; padding: 20px; background: #f5f5f5; }
        .info { background: white; padding: 15px; margin: 10px 0; border-left: 4px solid #007bff; }
        .error { background: #ffe6e6; border-left-color: #dc3545; }
        .success { background: #e6ffe6; border-left-color: #28a745; }
    </style>
</head>
<body>
    <h1>Session Trace (NO AUTH CHECK)</h1>
    <p>This page shows session state WITHOUT running auth_check.jsp</p>
    
    <%
        String referer = request.getHeader("Referer");
        Cookie[] cookies = request.getCookies();
        String jsessionidFromCookie = null;
        String jsessionidFromUrl = request.getRequestedSessionId();
        boolean sessionFromCookie = request.isRequestedSessionIdFromCookie();
        boolean sessionFromUrl = request.isRequestedSessionIdFromURL();
        
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("JSESSIONID".equals(cookie.getName())) {
                    jsessionidFromCookie = cookie.getValue();
                    break;
                }
            }
        }
    %>
    
    <div class="info">
        <strong>Referer:</strong> <%= referer != null ? referer : "NONE" %><br>
        <strong>Current Session ID:</strong> <%= session.getId() %><br>
        <strong>Is New Session:</strong> <%= session.isNew() ? "YES (NEW SESSION CREATED!)" : "NO (existing session)" %><br>
        <strong>Requested Session ID:</strong> <%= jsessionidFromUrl != null ? jsessionidFromUrl : "NONE" %>
    </div>
    
    <div class="<%= jsessionidFromCookie != null ? "success" : "error" %> info">
        <strong>JSESSIONID Cookie:</strong> <%= jsessionidFromCookie != null ? jsessionidFromCookie : "NOT FOUND!" %><br>
        <strong>Session from Cookie:</strong> <%= sessionFromCookie %><br>
        <strong>Session from URL:</strong> <%= sessionFromUrl %>
    </div>
    
    <div class="<%= session.getAttribute("admin_id") != null ? "success" : "error" %> info">
        <strong>admin_id:</strong> <%= session.getAttribute("admin_id") %><br>
        <strong>user_id:</strong> <%= session.getAttribute("user_id") %><br>
        <strong>admin_role:</strong> <%= session.getAttribute("admin_role") %><br>
        <strong>user_role:</strong> <%= session.getAttribute("user_role") %>
    </div>
    
    <h2>All Cookies</h2>
    <div class="info">
    <%
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                out.println("<strong>" + cookie.getName() + ":</strong> " + cookie.getValue() + "<br>");
                out.println("&nbsp;&nbsp;Domain: " + cookie.getDomain() + ", Path: " + cookie.getPath() + ", MaxAge: " + cookie.getMaxAge() + "<br>");
            }
        } else {
            out.println("NO COOKIES FOUND!");
        }
    %>
    </div>
    
    <h2>Test Navigation</h2>
    <p><a href="profile.jsp">Try Profile (should work if session exists)</a></p>
    <p><a href="dashboard.jsp">Back to Dashboard</a></p>
</body>
</html>
