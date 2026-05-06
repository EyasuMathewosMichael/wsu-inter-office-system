<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Link Test</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .test-link { display: block; margin: 10px 0; padding: 10px; background: #f0f0f0; }
        code { background: #ffffcc; padding: 2px 5px; }
    </style>
</head>
<body>
    <h1>Link Encoding Test</h1>
    
    <h2>Session Info</h2>
    <p>Session ID: <code><%= session.getId() %></code></p>
    <p>Cookies Enabled: <code><%= request.isRequestedSessionIdFromCookie() %></code></p>
    <p>URL Encoded: <code><%= request.isRequestedSessionIdFromURL() %></code></p>
    
    <h2>Test Links</h2>
    
    <div class="test-link">
        <strong>1. Plain relative link:</strong><br>
        <code>profile.jsp</code><br>
        <a href="profile.jsp">Click here</a>
    </div>
    
    <div class="test-link">
        <strong>2. response.encodeURL (like sidebar):</strong><br>
        <code><%= response.encodeURL("profile.jsp") %></code><br>
        <a href="<%= response.encodeURL("profile.jsp") %>">Click here</a>
    </div>
    
    <div class="test-link">
        <strong>3. response.encodeRedirectURL:</strong><br>
        <code><%= response.encodeRedirectURL("profile.jsp") %></code><br>
        <a href="<%= response.encodeRedirectURL("profile.jsp") %>">Click here</a>
    </div>
    
    <div class="test-link">
        <strong>4. Absolute path with encodeURL:</strong><br>
        <code><%= response.encodeURL(request.getContextPath() + "/admin/profile.jsp") %></code><br>
        <a href="<%= response.encodeURL(request.getContextPath() + "/admin/profile.jsp") %>">Click here</a>
    </div>
    
    <h2>Instructions</h2>
    <p>Click each link above and see which ones work. This will help identify the issue.</p>
    
    <p><a href="dashboard.jsp">Back to Dashboard</a></p>
</body>
</html>
