<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.JSONObject, org.json.JSONArray, java.util.*, java.io.*, javax.servlet.http.Part, java.nio.file.Paths" %>
<%!
    private String normalizeTaskPath(String dbPath) {
        if (dbPath == null) return "";
        String normalized = dbPath.replace("\\", "/").trim();
        if (normalized.isEmpty()) return "";

        int assetsIndex = normalized.indexOf("assets/");
        if (assetsIndex >= 0) return normalized.substring(assetsIndex);
        if (normalized.startsWith("/")) return normalized.substring(1);
        return normalized;
    }

    private String saveTaskUpload(Part part, String uploadRoot) throws Exception {
        if (part == null || part.getSize() <= 0 || part.getSubmittedFileName() == null) return "";

        String originalName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        long timestamp = new java.util.Date().getTime();
        String safeName = "task_" + timestamp + "_" + originalName.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
        File dir = new File(uploadRoot);
        if (!dir.exists()) dir.mkdirs();

        File destination = new File(dir, safeName);
        part.write(destination.getAbsolutePath());
        return "assets/uploads/tasks/" + safeName;
    }
%>
<%
    response.setContentType("application/json");
    Object sessionUser = session.getAttribute("user_id");
    String sessionRole = (String) session.getAttribute("user_role");

    if (sessionUser == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print(new JSONObject().put("status", "error").put("message", "Please login again.").toString());
        return;
    }

    int currentUserId = Integer.parseInt(sessionUser.toString());
    boolean isAdmin = "Admin".equalsIgnoreCase(sessionRole);
    boolean isDeptHead = "Dept Head".equalsIgnoreCase(sessionRole);

    String dbUrl = "jdbc:mysql://localhost:3306/inter_office_db";
    String dbUser = "root";
    String dbPass = "";

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            String sql = isAdmin
                    ? "SELECT * FROM tasks ORDER BY due_date ASC"
                    : "SELECT * FROM tasks WHERE assignee_id = ? OR creator_id = ? ORDER BY due_date ASC";

            PreparedStatement pstmt = conn.prepareStatement(sql);
            if (!isAdmin) {
                pstmt.setInt(1, currentUserId);
                pstmt.setInt(2, currentUserId);
            }

            ResultSet rs = pstmt.executeQuery();
            JSONArray taskList = new JSONArray();
            while (rs.next()) {
                JSONObject task = new JSONObject();
                task.put("task_id", rs.getInt("task_id"));
                task.put("creator_id", rs.getInt("creator_id"));
                task.put("assignee_id", rs.getInt("assignee_id"));
                task.put("title", rs.getString("title"));
                task.put("description", rs.getString("description"));
                task.put("priority", rs.getString("priority"));
                task.put("status", rs.getString("status"));
                task.put("due_date", rs.getString("due_date"));
                task.put("initial_attachment_path", normalizeTaskPath(rs.getString("initial_attachment_path")));
                task.put("staff_reply_text", rs.getString("staff_reply_text"));
                task.put("completion_attachment_path", normalizeTaskPath(rs.getString("completion_attachment_path")));
                task.put("acknowledged", rs.getInt("acknowledged"));
                taskList.put(task);
            }

            out.print(taskList.toString());
            return;
        }

        Map<String, String> fields = new HashMap<>();
        Part attachmentPart = null;
        boolean isMultipart = request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/");

        if (isMultipart) {
            for (Part part : request.getParts()) {
                if (part.getSubmittedFileName() == null) {
                    try (Scanner scanner = new Scanner(part.getInputStream(), "UTF-8")) {
                        fields.put(part.getName(), scanner.hasNext() ? scanner.useDelimiter("\\A").next().trim() : "");
                    }
                } else if ("attachment".equals(part.getName()) && part.getSize() > 0) {
                    attachmentPart = part;
                }
            }
        } else {
            Enumeration<String> names = request.getParameterNames();
            while (names.hasMoreElements()) {
                String name = names.nextElement();
                fields.put(name, request.getParameter(name));
            }
        }

        String action = fields.get("action");
        if (action == null || action.trim().isEmpty()) action = "create_task";

        String uploadRoot = getServletContext().getRealPath("/") + "assets" + File.separator + "uploads" + File.separator + "tasks";
        String uploadedPath = saveTaskUpload(attachmentPart, uploadRoot);
        JSONObject res = new JSONObject();

        if ("delete_task".equalsIgnoreCase(action)) {
            if (!isDeptHead && !isAdmin) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print(res.put("status", "error").put("message", "Only department heads can delete tasks.").toString());
                return;
            }

            String sql = isAdmin
                    ? "DELETE FROM tasks WHERE task_id = ?"
                    : "DELETE FROM tasks WHERE task_id = ? AND creator_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(fields.get("task_id")));
            if (!isAdmin) pstmt.setInt(2, currentUserId);

            if (pstmt.executeUpdate() > 0) res.put("status", "success");
            else res.put("status", "error").put("message", "Task not found or access denied.");
        } else if ("acknowledge".equalsIgnoreCase(action)) {
            if (!isDeptHead && !isAdmin) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print(res.put("status", "error").put("message", "Only department heads can acknowledge tasks.").toString());
                return;
            }

            String sql = isAdmin
                    ? "UPDATE tasks SET acknowledged = 1 WHERE task_id = ?"
                    : "UPDATE tasks SET acknowledged = 1 WHERE task_id = ? AND creator_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(fields.get("task_id")));
            if (!isAdmin) pstmt.setInt(2, currentUserId);

            if (pstmt.executeUpdate() > 0) res.put("status", "success");
            else res.put("status", "error").put("message", "Acknowledgment failed.");
        } else if ("edit_task".equalsIgnoreCase(action)) {
            if (!isDeptHead && !isAdmin) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print(res.put("status", "error").put("message", "Only department heads can edit tasks.").toString());
                return;
            }

            StringBuilder sql = new StringBuilder("UPDATE tasks SET title = ?, description = ?, priority = ?, due_date = ?, assignee_id = ?");
            if (!uploadedPath.isEmpty()) sql.append(", initial_attachment_path = ?");
            sql.append(" WHERE task_id = ?");
            if (!isAdmin) sql.append(" AND creator_id = ?");

            PreparedStatement pstmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            pstmt.setString(idx++, fields.get("title"));
            pstmt.setString(idx++, fields.get("description"));
            pstmt.setString(idx++, fields.get("priority"));
            pstmt.setString(idx++, fields.get("due_date"));
            pstmt.setInt(idx++, Integer.parseInt(fields.get("assignee_id")));
            if (!uploadedPath.isEmpty()) pstmt.setString(idx++, uploadedPath);
            pstmt.setInt(idx++, Integer.parseInt(fields.get("task_id")));
            if (!isAdmin) pstmt.setInt(idx++, currentUserId);

            if (pstmt.executeUpdate() > 0) res.put("status", "success");
            else res.put("status", "error").put("message", "Task not found or access denied.");
        } else if ("staff_reply".equalsIgnoreCase(action)) {
            StringBuilder sql = new StringBuilder("UPDATE tasks SET staff_reply_text = ?, status = ?");
            if (!uploadedPath.isEmpty()) sql.append(", completion_attachment_path = ?");
            sql.append(" WHERE task_id = ?");
            if (!isAdmin) sql.append(" AND assignee_id = ?");

            PreparedStatement pstmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            pstmt.setString(idx++, fields.get("staff_reply_text"));
            pstmt.setString(idx++, fields.get("status"));
            if (!uploadedPath.isEmpty()) pstmt.setString(idx++, uploadedPath);
            pstmt.setInt(idx++, Integer.parseInt(fields.get("task_id")));
            if (!isAdmin) pstmt.setInt(idx++, currentUserId);

            if (pstmt.executeUpdate() > 0) res.put("status", "success");
            else res.put("status", "error").put("message", "Task not found or access denied.");
        } else if ("update_status".equalsIgnoreCase(action)) {
            String sql = isAdmin
                    ? "UPDATE tasks SET status = ? WHERE task_id = ?"
                    : "UPDATE tasks SET status = ? WHERE task_id = ? AND assignee_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, fields.get("status"));
            pstmt.setInt(2, Integer.parseInt(fields.get("task_id")));
            if (!isAdmin) pstmt.setInt(3, currentUserId);

            if (pstmt.executeUpdate() > 0) res.put("status", "success");
            else res.put("status", "error").put("message", "Status update failed.");
        } else if ("create_task".equalsIgnoreCase(action)) {
            if (!isDeptHead && !isAdmin) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print(res.put("status", "error").put("message", "Only department heads can create tasks.").toString());
                return;
            }

            String sql = "INSERT INTO tasks (title, description, priority, due_date, assignee_id, creator_id, status, initial_attachment_path, acknowledged) VALUES (?, ?, ?, ?, ?, ?, 'Pending', ?, 0)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, fields.get("title"));
            pstmt.setString(2, fields.get("description"));
            pstmt.setString(3, fields.get("priority"));
            pstmt.setString(4, fields.get("due_date"));
            pstmt.setInt(5, Integer.parseInt(fields.get("assignee_id")));
            pstmt.setInt(6, currentUserId);
            pstmt.setString(7, uploadedPath);

            if (pstmt.executeUpdate() > 0) res.put("status", "success");
            else res.put("status", "error").put("message", "Task creation failed.");
        } else {
            res.put("status", "error").put("message", "Unknown action.");
        }

        out.print(res.toString());
    } catch (Exception e) {
        JSONObject err = new JSONObject();
        err.put("status", "error");
        err.put("message", e.getMessage());
        out.print(err.toString());
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
