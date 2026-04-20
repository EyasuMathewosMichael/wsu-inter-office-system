<%@ page import="java.sql.*, com.google.gson.Gson, java.util.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    String headIdParam = request.getParameter("dept_head_id");
    List<Map<String, Object>> staffList = new ArrayList<>();

    if (headIdParam != null) {
        try {
            int deptHeadId = Integer.parseInt(headIdParam);
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");

            // FIXED: Changed 'department_id' to 'department' to match your table screenshot [cite: 2026-02-22]
            String sql = "SELECT user_id, username FROM users WHERE role = 'Staff' AND department = " +
                         "(SELECT department FROM users WHERE user_id = ?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, deptHeadId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> user = new HashMap<>();
                // Matches your Java User model @SerializedName("id") [cite: 2026-01-26]
                user.put("id", rs.getInt("user_id"));
                user.put("username", rs.getString("username"));
                staffList.add(user);
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    // Returns JSON: [{"id": 9, "username": "tame"}] [cite: 2026-01-21]
    out.print(new Gson().toJson(staffList));
    out.flush();
%>