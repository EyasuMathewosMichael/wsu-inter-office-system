<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Session Debug</title>
    <style>
        body { font-family: monospace; padding: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .info { background-color: #e7f3fe; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Session Debug Information</h1>
    
    <div class="info">
        <strong>Session ID:</strong> <%= session.getId() %><br>
        <strong>Is New:</strong> <%= session.isNew() %><br>
        <strong>Creation Time:</strong> <%= new Date(session.getCreationTime()) %><br>
        <strong>Last Accessed:</strong> <%= new Date(session.getLastAccessedTime()) %><br>
        <strong>Max Inactive Interval:</strong> <%= session.getMaxInactiveInterval() %> seconds<br>
    </div>

    <h2>Session Attributes</h2>
    <table>
        <tr>
            <th>Attribute Name</th>
            <th>Value</th>
            <th>Type</th>
        </tr>
        <%
            Enumeration<String> attributeNames = session.getAttributeNames();
            boolean hasAttributes = false;
            while (attributeNames.hasMoreElements()) {
                hasAttributes = true;
                String name = attributeNames.nextElement();
                Object value = session.getAttribute(name);
                String valueStr = (value != null) ? value.toString() : "null";
                String type = (value != null) ? value.getClass().getName() : "null";
        %>
        <tr>
            <td><%= name %></td>
            <td><%= valueStr %></td>
            <td><%= type %></td>
        </tr>
        <%
            }
            if (!hasAttributes) {
        %>
        <tr>
            <td colspan="3" style="text-align: center; color: red;">No session attributes found!</td>
        </tr>
        <%
            }
        %>
    </table>

    <h2>Request Information</h2>
    <table>
        <tr>
            <th>Property</th>
            <th>Value</th>
        </tr>
        <tr>
            <td>Request URI</td>
            <td><%= request.getRequestURI() %></td>
        </tr>
        <tr>
            <td>Request URL</td>
            <td><%= request.getRequestURL() %></td>
        </tr>
        <tr>
            <td>Context Path</td>
            <td><%= request.getContextPath() %></td>
        </tr>
        <tr>
            <td>Servlet Path</td>
            <td><%= request.getServletPath() %></td>
        </tr>
        <tr>
            <td>Session Cookie</td>
            <td>
                <%
                    Cookie[] cookies = request.getCookies();
                    boolean foundSession = false;
                    if (cookies != null) {
                        for (Cookie cookie : cookies) {
                            if ("JSESSIONID".equals(cookie.getName())) {
                                foundSession = true;
                                out.print(cookie.getValue());
                                break;
                            }
                        }
                    }
                    if (!foundSession) {
                        out.print("<span style='color: red;'>No JSESSIONID cookie found!</span>");
                    }
                %>
            </td>
        </tr>
    </table>

    <div style="margin-top: 20px;">
        <a href="dashboard.jsp">Go to Dashboard</a> | 
        <a href="profile.jsp">Go to Profile</a> |
        <a href="login.jsp">Go to Login</a>
    </div>
</body>
</html>
