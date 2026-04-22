<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="auth_check.jsp" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Traffic Logs | WSU School of Informatics</title>

    <link rel="stylesheet" href="../assets/css/style.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* Shared Layout Styles */
        html, body {
            min-height: 100%;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
            background-color: #f8fafc;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        .app-container {
            display: flex;
            width: 100%;
            min-height: 100vh;
            min-height: 100dvh;
            align-items: stretch;
        }

        #sidebar-wrapper {
            width: 280px;
            min-height: 100vh;
            min-height: 100dvh;
            background: #1e293b;
            flex-shrink: 0;
            z-index: 1050;
            display: flex;
            flex-direction: column;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .nav-label {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 700;
            color: #64748b;
            padding: 20px 25px 10px;
            display: block !important;
        }

        #sidebar-wrapper .list-group-item {
            background: transparent;
            color: #94a3b8;
            border: none;
            padding: 12px 25px;
            transition: all 0.2s;
            font-weight: 500;
            display: flex;
            align-items: center;
        }

        #sidebar-wrapper .list-group-item span {
            display: inline !important;
        }

        #sidebar-wrapper .list-group-item:hover {
            color: white;
            background: rgba(255, 255, 255, 0.05);
        }

        #sidebar-wrapper .list-group-item.active {
            background: #3b82f6 !important;
            color: white !important;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
        }

        .main-content {
            flex-grow: 1;
            min-width: 0;
            min-height: 100vh;
            min-height: 100dvh;
            overflow-y: auto;
            position: relative;
        }

        .page-header {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 20px 40px;
            border-bottom: 1px solid #e2e8f0;
            margin-bottom: 30px;
        }

        /* Traffic Log Specific Styles */
        .log-table-card {
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            background: white;
            overflow: hidden;
        }

        .sidebar-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(2, 6, 23, 0.58);
            backdrop-filter: blur(10px);
            z-index: 1040;
        }

        .main-content::-webkit-scrollbar { width: 6px; }
        .main-content::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }

        @media (max-width: 992px) {
            #sidebar-wrapper {
                position: fixed;
                left: 0;
                top: 0;
                bottom: 0;
                width: min(86vw, 320px);
                max-width: 320px;
                padding: max(0px, env(safe-area-inset-top)) 12px 12px;
                background: linear-gradient(180deg, #0f172a 0%, #162338 55%, #1e293b 100%);
                border-right: 1px solid rgba(148, 163, 184, 0.16);
                border-top-right-radius: 28px;
                border-bottom-right-radius: 28px;
                box-shadow: 0 24px 60px rgba(15, 23, 42, 0.32);
                transform: translateX(-108%);
                overflow-y: auto;
            }
            #sidebar-wrapper.active { transform: translateX(0); }
            #sidebar-wrapper .list-group {
                gap: 6px;
            }
            #sidebar-wrapper .list-group-item {
                margin: 0 6px;
                padding: 14px 16px;
                border-radius: 16px;
            }
            #sidebar-wrapper .list-group-item:hover {
                transform: translateX(2px);
                background: rgba(255, 255, 255, 0.08);
            }
            #sidebar-wrapper .list-group-item.active {
                background: linear-gradient(135deg, #2563eb, #3b82f6) !important;
                box-shadow: 0 14px 28px rgba(37, 99, 235, 0.35);
            }
            #sidebar-wrapper .dropdown > a {
                background: rgba(255, 255, 255, 0.05);
                border: 1px solid rgba(148, 163, 184, 0.14);
            }
            .nav-label {
                padding: 18px 18px 10px;
                color: #94a3b8;
                font-size: 0.68rem;
            }
            .sidebar-overlay.active { display: block; }
            .page-header { padding: 15px 20px; flex-wrap: wrap; gap: 1rem; }
        }

        @media (max-width: 768px) {
            .container-fluid { padding-left: 1rem !important; padding-right: 1rem !important; }
            .mobile-stack-table thead {
                display: none;
            }
            .mobile-stack-table,
            .mobile-stack-table tbody,
            .mobile-stack-table tr,
            .mobile-stack-table td {
                display: block;
                width: 100%;
            }
            .mobile-stack-table tr {
                padding: 1rem 1.25rem;
                border-bottom: 1px solid #e2e8f0;
            }
            .mobile-stack-table td {
                border: 0 !important;
                padding: 0.35rem 0 !important;
                text-align: left !important;
            }
            .mobile-stack-table td::before {
                content: attr(data-label);
                display: block;
                margin-bottom: 0.2rem;
                color: #64748b;
                font-size: 0.72rem;
                font-weight: 700;
                letter-spacing: 0.03em;
                text-transform: uppercase;
            }
            .mobile-stack-table td:last-child {
                padding-bottom: 0 !important;
            }
            .mobile-stack-table .text-truncate {
                max-width: none !important;
                white-space: normal;
            }
            .page-header .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>

<%
    String filterType = request.getParameter("filterType") != null ? request.getParameter("filterType") : "";
    String filterDept = request.getParameter("filterDept") != null ? request.getParameter("filterDept") : "";
    String startDate = request.getParameter("startDate") != null ? request.getParameter("startDate") : "";
    String endDate = request.getParameter("endDate") != null ? request.getParameter("endDate") : "";
%>

<div class="app-container">
    <div class="sidebar-overlay" id="sidebar-overlay"></div>

    <%-- Sidebar Fragment --%>
    <% String currentUri = request.getRequestURI(); %>
    <%@ include file="sidebar_profile.jspf" %>
    <div class="text-white shadow-lg" id="sidebar-wrapper">
        <div class="p-4">
            <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center">
                    <div class="me-3 d-flex align-items-center justify-content-center" style="width: 45px; height: 45px;">
                        <img src="../assets/img/wsu_logo.png" alt="WSU Logo" class="img-fluid" style="max-height: 100%;" onerror="this.src='https://ui-avatars.com/api/?name=WSU&background=0d6efd&color=fff'">
                    </div>
                    <span class="fs-5 fw-bold text-white tracking-tight">WSU-SoI</span>
                </div>
                <button class="btn btn-link text-white d-lg-none p-0 border-0" id="close-sidebar">
                    <i class="fas fa-times fa-lg"></i>
                </button>
            </div>
        </div>

        <div class="nav-label">Main Menu</div>
        <div class="list-group list-group-flush px-2">
            <a href="dashboard.jsp" class="list-group-item list-group-item-action <%= currentUri.endsWith("dashboard.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-house-chimney-window me-3"></i><span>Dashboard</span>
            </a>
            <a href="manage_users.jsp" class="list-group-item list-group-item-action <%= currentUri.endsWith("manage_users.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-user-gear me-3"></i><span>Manage Users</span>
            </a>
            <a href="chat.jsp" class="list-group-item list-group-item-action <%= currentUri.endsWith("chat.jsp") ? "active" : "" %>">
               <i class="fa-solid fa-comment-dots me-3"></i><span>Communication Hub</span>
            </a>
        </div>

        <div class="nav-label mt-3">Administration</div>
        <div class="list-group list-group-flush px-2">
            <a href="announcements.jsp" class="list-group-item list-group-item-action <%= currentUri.endsWith("announcements.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-tower-broadcast me-3"></i><span>Announcements</span>
            </a>
            <a href="traffic_logs.jsp" class="list-group-item list-group-item-action <%= currentUri.endsWith("traffic_logs.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-chart-bar me-3"></i><span>Traffic Logs</span>
            </a>
        </div>

        <div class="mt-auto p-3 border-top border-secondary border-opacity-25">
            <div class="dropdown">
                <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle p-2 rounded-3" data-bs-toggle="dropdown" aria-expanded="false">
                    <img src="../assets/img/<%= sidebarAdminPhoto %>" alt="Admin Profile" class="rounded-circle me-2" style="width: 32px; height: 32px; object-fit: cover;" onerror="this.src='../assets/img/admin-avatar.png'">
                    <div class="small">
                        <div class="fw-bold" style="font-size: 0.8rem;"><%= sidebarAdminNameHtml %></div>
                        <div class="text-white-50 text-capitalize" style="font-size: 0.7rem;"><%= sidebarAdminRoleHtml %></div>
                    </div>
                </a>
                <ul class="dropdown-menu dropdown-menu-dark shadow-lg border-0 p-2 mb-2 rounded-3">
                    <li><a class="dropdown-item rounded-2 py-2" href="profile.jsp"><i class="fas fa-id-card me-2 opacity-50"></i>My Profile</a></li>
                    <li><hr class="dropdown-divider opacity-10"></li>
                    <li><a class="dropdown-item rounded-2 text-danger" href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Sign out</a></li>
                </ul>
            </div>
        </div>
    </div>

    <main class="main-content">
        <div class="page-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center">
                <button class="btn btn-link text-dark d-lg-none me-3 p-0" id="hamburger-menu">
                    <i class="fas fa-bars fa-lg"></i>
                </button>
                <div>
                    <h3 class="fw-bold mb-0 text-dark">Traffic Logs</h3>
                    <p class="text-muted small mb-0 d-none d-md-block">System audit trail and activity monitoring</p>
                </div>
            </div>
            <div class="d-flex gap-2">
                <button onclick="exportToCSV()" class="btn btn-outline-success rounded-pill px-3 py-2 shadow-sm">
                    <i class="fas fa-file-csv me-1"></i> Export
                </button>
            </div>
        </div>

        <div class="container-fluid px-lg-5 px-3 pb-5">
            <div class="card border-0 shadow-sm rounded-4 mb-4 p-2">
                <div class="card-body">
                    <form id="filterForm" method="GET" class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-muted">Category</label>
                            <select name="filterType" class="form-select border-0 bg-light p-2 rounded-3">
                                <option value="">All Traffic</option>
                                <option value="Announcement" <%= filterType.equals("Announcement") ? "selected" : "" %>>Announcements</option>
                                <option value="Task" <%= filterType.equals("Task") ? "selected" : "" %>>Tasks</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small fw-bold text-muted">Scope</label>
                            <select name="filterDept" class="form-select border-0 bg-light p-2 rounded-3">
                                <option value="">All Departments</option>
                                <option value="Computer Science" <%= filterDept.equals("Computer Science") ? "selected" : "" %>>Computer Science</option>
                                <option value="Information Technology" <%= filterDept.equals("Information Technology") ? "selected" : "" %>>Information Technology</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-muted">Date Range</label>
                            <div class="input-group">
                                <input type="date" name="startDate" value="<%= startDate %>" class="form-control border-0 bg-light p-2 rounded-3 me-1">
                                <input type="date" name="endDate" value="<%= endDate %>" class="form-control border-0 bg-light p-2 rounded-3">
                            </div>
                        </div>
                        <div class="col-md-2 d-flex gap-2">
                            <button type="submit" class="btn btn-primary w-100 rounded-3 fw-bold shadow-sm">Apply</button>
                            <a href="traffic_logs.jsp" class="btn btn-light rounded-3 border"><i class="fas fa-sync-alt"></i></a>
                        </div>
                    </form>
                </div>
            </div>

            <div class="log-table-card shadow-sm">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 mobile-stack-table">
                        <thead class="bg-light text-muted small text-uppercase">
                            <tr>
                                <th class="ps-4 py-3">ID</th>
                                <th>Type</th>
                                <th>Content</th>
                                <th>Target</th>
                                <th>Timestamp</th>
                                <th class="text-end pe-4">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection conn = getDbConnection(application);

                                    StringBuilder query = new StringBuilder("SELECT * FROM (");
                                    query.append("SELECT announcement_id AS id, 'Announcement' AS type, title AS content, target_dept AS target, created_at FROM announcements ");
                                    query.append("UNION ALL ");
                                    query.append("SELECT t.task_id AS id, 'Task' AS type, t.title AS content, u.username AS target, t.created_at ");
                                    query.append("FROM tasks t LEFT JOIN users u ON t.assignee_id = u.user_id ");
                                    query.append(") AS traffic_logs WHERE 1=1 ");

                                    if(!filterType.isEmpty()) query.append("AND type = '").append(filterType).append("' ");
                                    if(!filterDept.isEmpty()) query.append("AND target = '").append(filterDept).append("' ");
                                    if(!startDate.isEmpty()) query.append("AND created_at >= '").append(startDate).append(" 00:00:00' ");
                                    if(!endDate.isEmpty()) query.append("AND created_at <= '").append(endDate).append(" 23:59:59' ");

                                    query.append("ORDER BY created_at DESC LIMIT 100");

                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery(query.toString());

                                    while(rs.next()) {
                                        String type = rs.getString("type");
                                        String badgeClass = type.equals("Announcement") ? "bg-info-subtle text-info" : "bg-warning-subtle text-dark";
                            %>
                            <tr>
                                <td class="ps-4 text-muted small" data-label="ID">#<%= rs.getInt("id") %></td>
                                <td data-label="Type"><span class="badge <%= badgeClass %> rounded-pill px-3 py-1"><%= type %></span></td>
                                <td data-label="Content"><div class="text-dark fw-medium text-truncate" style="max-width: 300px;"><%= rs.getString("content") %></div></td>
                                <td data-label="Target"><span class="text-muted small"><i class="fas fa-location-arrow me-1"></i> <%= rs.getString("target") %></span></td>
                                <td class="text-muted small" data-label="Timestamp"><%= rs.getTimestamp("created_at") %></td>
                                <td class="text-end pe-4" data-label="Status"><span class="text-success fw-bold small"><i class="fas fa-check-circle me-1"></i> Logged</span></td>
                            </tr>
                            <%
                                    }
                                    conn.close();
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='6' class='p-4 text-center text-danger'>Error: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function exportToCSV() {
        const form = document.getElementById('filterForm');
        const params = new URLSearchParams(new FormData(form)).toString();
        window.location.href = 'export_logs.jsp?' + params;
    }

    document.addEventListener('DOMContentLoaded', function() {
        const hamburgerMenu = document.getElementById('hamburger-menu');
        const closeSidebar = document.getElementById('close-sidebar');
        const sidebar = document.getElementById('sidebar-wrapper');
        const overlay = document.getElementById('sidebar-overlay');

        function toggleSidebar() {
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        if (hamburgerMenu) hamburgerMenu.addEventListener('click', toggleSidebar);
        if (closeSidebar) closeSidebar.addEventListener('click', toggleSidebar);
        if (overlay) overlay.addEventListener('click', toggleSidebar);
    });
</script>
<%@ include file="navigation_prefetch.jspf" %>
</body>
</html>

