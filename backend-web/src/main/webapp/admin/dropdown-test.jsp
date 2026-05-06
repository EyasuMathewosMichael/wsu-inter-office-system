<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Dropdown Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding: 50px; }
        .test-section { margin: 30px 0; padding: 20px; border: 2px solid #ddd; }
    </style>
</head>
<body>
    <h1>Dropdown Navigation Test</h1>
    
    <div class="test-section">
        <h3>Test 1: Regular Link (No Dropdown)</h3>
        <a href="<%= response.encodeURL("profile.jsp") %>" class="btn btn-primary">Go to Profile (Regular Link)</a>
    </div>
    
    <div class="test-section">
        <h3>Test 2: Bootstrap Dropdown (Like Sidebar)</h3>
        <div class="dropdown">
            <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                Account Menu
            </button>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="<%= response.encodeURL("profile.jsp") %>">My Profile (Dropdown)</a></li>
                <li><a class="dropdown-item" href="<%= response.encodeURL("dashboard.jsp") %>">Dashboard</a></li>
            </ul>
        </div>
    </div>
    
    <div class="test-section">
        <h3>Test 3: Dropdown with href="#" Toggle (Exact Sidebar Pattern)</h3>
        <div class="dropdown">
            <a href="#" class="btn btn-secondary dropdown-toggle" data-bs-toggle="dropdown">
                Account Menu (href="#")
            </a>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="<%= response.encodeURL("profile.jsp") %>">My Profile (Dropdown)</a></li>
                <li><a class="dropdown-item" href="<%= response.encodeURL("dashboard.jsp") %>">Dashboard</a></li>
            </ul>
        </div>
    </div>
    
    <div class="test-section">
        <h3>Test 4: Absolute Path in Dropdown</h3>
        <div class="dropdown">
            <a href="#" class="btn btn-secondary dropdown-toggle" data-bs-toggle="dropdown">
                Account Menu (Absolute Path)
            </a>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="<%= response.encodeURL(request.getContextPath() + "/admin/profile.jsp") %>">My Profile (Absolute)</a></li>
                <li><a class="dropdown-item" href="<%= response.encodeURL(request.getContextPath() + "/admin/dashboard.jsp") %>">Dashboard (Absolute)</a></li>
            </ul>
        </div>
    </div>
    
    <h2>Instructions</h2>
    <p>Click each "My Profile" link and see which ones work:</p>
    <ul>
        <li>✅ = Loads profile page successfully</li>
        <li>❌ = Redirects to login page</li>
    </ul>
    
    <p><strong>Current Session ID:</strong> <%= session.getId() %></p>
    <p><strong>Admin ID:</strong> <%= session.getAttribute("admin_id") %></p>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
