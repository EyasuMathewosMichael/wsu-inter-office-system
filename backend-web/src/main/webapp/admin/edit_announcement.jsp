<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*" %>
<%@ include file="../admin/auth_check.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Announcement | WSU-SoI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<%
    int id = 0;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch(Exception e) {
        response.sendRedirect("announcements.jsp");
        return;
    }

    String title = "", content = "", dept = "", attachment = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM announcements WHERE announcement_id = ?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            title = rs.getString("title");
            content = rs.getString("content");
            dept = rs.getString("target_dept");
            attachment = rs.getString("attachment_path");
        }
        conn.close();
    } catch(Exception e) { e.printStackTrace(); }
%>

<div class="container py-5">
    <div class="card shadow-sm border-0 mx-auto" style="max-width: 600px;">
        <div class="card-header bg-white py-3">
            <h5 class="mb-0 fw-bold text-primary"><i class="fas fa-edit me-2"></i>Edit Announcement</h5>
        </div>
        <div class="card-body p-4">
            <form action="../api/update_announcement.jsp" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="id" value="<%= id %>">
                <input type="hidden" name="redirect_to" value="<%= request.getContextPath() %>/admin/announcements.jsp">

                <div class="mb-3">
                    <label class="form-label small fw-bold">Target Department</label>
                    <select name="target_dept" class="form-select">
                        <option value="Global" <%= "Global".equals(dept) ? "selected" : "" %>>Global (All)</option>
                        <option value="Computer Science" <%= "Computer Science".equals(dept) ? "selected" : "" %>>Computer Science</option>
                        <option value="Information Technology" <%= "Information Technology".equals(dept) ? "selected" : "" %>>Information Technology</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-bold">Title</label>
                    <input type="text" name="title" class="form-control" value="<%= title %>" required>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-bold">Content</label>
                    <textarea name="content" class="form-control" rows="5" required><%= content %></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">Current Attachment</label>
                    <div class="p-2 border rounded bg-light mb-2">
                        <i class="fas fa-file-alt me-2 text-primary"></i>
                        <%
                            if (attachment != null && !attachment.trim().isEmpty()) {
                                // Logic to extract just the filename from a potentially long path
                                String fileName = attachment;
                                int lastSlash = Math.max(attachment.lastIndexOf('/'), attachment.lastIndexOf('\\'));
                                if (lastSlash != -1) {
                                    fileName = attachment.substring(lastSlash + 1);
                                }
                                out.print("<span class='text-dark'>" + fileName + "</span>");
                            } else {
                                out.print("<span class='text-muted'>No file attached</span>");
                            }
                        %>
                    </div>
                    <label class="form-label small fw-bold">Replace File (Optional)</label>
                    <input type="file" name="attachment" class="form-control">
                    <div class="form-text text-muted" style="font-size: 0.75rem;">Uploading a new file will replace the existing one.</div>
                </div>

                <div class="d-flex justify-content-between mt-4">
                    <a href="announcements.jsp" class="btn btn-light">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
