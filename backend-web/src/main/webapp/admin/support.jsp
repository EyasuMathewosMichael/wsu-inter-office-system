<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="auth_check.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Support | WSU-SoI</title>
    <%@ include file="header.jspf" %>
</head>
<body>
<div id="wrapper" class="d-flex">
    <%@ include file="sidebar.jspf" %>
    <div class="main-content flex-grow-1">
        <nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom p-3">
            <span class="navbar-brand mb-0 h1 fw-bold">System Support</span>
        </nav>
        <div class="container-fluid p-4">
            <div class="card shadow-sm border-0 p-5 text-center rounded-4">
                <i class="fas fa-headset fa-3x text-primary mb-3"></i>
                <h2>Need Assistance?</h2>
                <p class="text-muted">Contact the School of Informatics IT department at <strong>support@wsu.edu</strong></p>
            </div>
        </div>
        <%@ include file="footer.jspf" %>
    </div>
</div>
</body>
</html>