<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Profile Test</title>
</head>
<body>
    <h1>Profile Page Test (No Auth Check)</h1>
    
    <h2>Session Info</h2>
    <p>Session ID: <%= session.getId() %></p>
    <p>Is New: <%= session.isNew() %></p>
    
    <h2>Checking admin_id</h2>
    <%
        Object adminObj = session.getAttribute("admin_id");
        out.println("<p>adminObj from session.getAttribute('admin_id'): " + adminObj + "</p>");
        
        if (adminObj == null) {
            out.println("<p style='color: red;'>adminObj is NULL - checking user_id</p>");
            adminObj = session.getAttribute("user_id");
            out.println("<p>adminObj from session.getAttribute('user_id'): " + adminObj + "</p>");
        }
        
        if (adminObj == null) {
            out.println("<p style='color: red; font-weight: bold;'>BOTH admin_id and user_id are NULL!</p>");
            out.println("<p>This would cause redirect to login</p>");
        } else {
            out.println("<p style='color: green; font-weight: bold;'>SUCCESS: adminObj = " + adminObj + "</p>");
            out.println("<p>Would proceed to load profile page</p>");
        }
    %>
    
    <h2>All Session Attributes</h2>
    <ul>
    <%
        java.util.Enumeration<String> attrs = session.getAttributeNames();
        while (attrs.hasMoreElements()) {
            String name = attrs.nextElement();
            Object value = session.getAttribute(name);
            out.println("<li><strong>" + name + "</strong>: " + value + "</li>");
        }
    %>
    </ul>
    
    <p><a href="profile.jsp">Try Real Profile Page</a></p>
    <p><a href="dashboard.jsp">Go to Dashboard</a></p>
</body>
</html>
