<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Error</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; color: #1f2937; }
        .code { color: #b91c1c; font-weight: 700; }
        pre { white-space: pre-wrap; background: #f3f4f6; padding: 16px; border-radius: 8px; }
    </style>
</head>
<body>
    <h1><span class="code">500</span> Server Error</h1>
    <p>The server could not complete this request.</p>
    <% if (exception != null) { %>
        <pre><%= exception.getClass().getName() %>: <%= exception.getMessage() %></pre>
    <% } %>
</body>
</html>
