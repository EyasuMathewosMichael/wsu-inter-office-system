<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="auth_check.jsp" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | WSU School of Informatics</title>

    <link rel="stylesheet" href="../assets/css/style.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* Global Viewport Reset */
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

        /* Sidebar Styling - Exactly as Announcements */
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

        .sidebar-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(2, 6, 23, 0.58);
            backdrop-filter: blur(10px);
            z-index: 1040;
        }

        /* Main Content Area */
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

        /* Dashboard Specific Cards */
        .stat-card {
            border: none;
            border-radius: 20px;
            transition: transform 0.3s ease;
        }
        .stat-card:hover { transform: translateY(-5px); }

        .mobile-stack-table { table-layout: fixed; }

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
            .card-header {
                flex-wrap: wrap;
                gap: 0.75rem;
            }
            .card-header .btn {
                width: 100%;
            }
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
        }
    </style>
</head>
<body>

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
        <header class="page-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center">
                <button class="btn btn-link text-dark d-lg-none me-3 p-0" id="hamburger-menu">
                    <i class="fas fa-bars fa-lg"></i>
                </button>
                <div>
                    <h3 class="fw-bold mb-0 text-dark">System Overview</h3>
                    <p class="text-muted small mb-0 d-none d-md-block">Real-time administrative metrics</p>
                </div>
            </div>
        </header>

        <div class="container-fluid px-lg-5 px-3 pb-5">
            <%
                int totalUsers = 0, totalAnnouncements = 0, totalTasks = 0;
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    conn = getDbConnection(application);
                    stmt = conn.createStatement();

                    rs = stmt.executeQuery("SELECT COUNT(*) FROM users");
                    if(rs.next()) totalUsers = rs.getInt(1);

                    rs = stmt.executeQuery("SELECT COUNT(*) FROM announcements");
                    if(rs.next()) totalAnnouncements = rs.getInt(1);

                    rs = stmt.executeQuery("SELECT COUNT(*) FROM tasks");
                    if(rs.next()) totalTasks = rs.getInt(1);
            %>

            <div class="row g-4 mb-5">
                <div class="col-12 col-md-4">
                    <a href="manage_users.jsp" class="text-decoration-none">
                        <div class="card stat-card shadow-sm p-4 bg-primary text-white h-100">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <p class="opacity-75 mb-0 small text-uppercase fw-bold">Staff Base</p>
                                    <h2 class="mb-0 fw-bold mt-1"><%= totalUsers %></h2>
                                </div>
                                <div class="bg-white bg-opacity-25 rounded-circle p-3"><i class="fas fa-users-cog fa-2x"></i></div>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-12 col-md-4">
                    <a href="traffic_logs.jsp?type=Task" class="text-decoration-none">
                        <div class="card stat-card shadow-sm p-4 bg-warning text-dark h-100">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <p class="opacity-75 mb-0 small text-uppercase fw-bold">Live Tasks</p>
                                    <h2 class="mb-0 fw-bold mt-1"><%= totalTasks %></h2>
                                </div>
                                <div class="bg-dark bg-opacity-10 rounded-circle p-3"><i class="fas fa-project-diagram fa-2x"></i></div>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-12 col-md-4">
                    <a href="announcements.jsp" class="text-decoration-none">
                        <div class="card stat-card shadow-sm p-4 bg-success text-white h-100">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <p class="opacity-75 mb-0 small text-uppercase fw-bold">Broadcasts</p>
                                    <h2 class="mb-0 fw-bold mt-1"><%= totalAnnouncements %></h2>
                                </div>
                                <div class="bg-white bg-opacity-25 rounded-circle p-3"><i class="fas fa-satellite-dish fa-2x"></i></div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>

            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="card-header bg-white py-4 px-4 d-flex justify-content-between align-items-center border-bottom">
                    <h5 class="mb-0 fw-bold text-dark">Recent Activity</h5>
                    <a href="traffic_logs.jsp" class="btn btn-sm btn-outline-primary rounded-pill px-4 fw-bold">Explore Logs</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 mobile-stack-table">
                            <thead class="bg-light text-muted small text-uppercase">
                                <tr>
                                    <th class="ps-4 py-3">Event Type</th>
                                    <th>Target Point</th>
                                    <th>Subject</th>
                                    <th>Timestamp</th>
                                    <th class="text-end pe-4">System State</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    String trafficSql = "SELECT 'Announcement' as type, title as content, target_dept as target, created_at FROM announcements " +
                                                       "UNION ALL " +
                                                       "SELECT 'Task' as type, t.title as content, COALESCE(u.username, 'Unassigned') as target, t.created_at FROM tasks t LEFT JOIN users u ON t.assignee_id = u.user_id " +
                                                       "ORDER BY created_at DESC LIMIT 5";

                                    rs = stmt.executeQuery(trafficSql);
                                    while(rs.next()) {
                                        String type = rs.getString("type");
                                        String badgeClass = type.equals("Announcement") ? "text-primary bg-primary-subtle" : "text-warning bg-warning-subtle";
                                %>
                                <tr>
                                    <td class="ps-4" data-label="Event Type">
                                        <span class="badge <%= badgeClass %> rounded-pill px-3 py-2 fw-semibold">
                                            <i class="fas <%= type.equals("Announcement") ? "fa-bullhorn" : "fa-tasks" %> me-2"></i><%= type %>
                                        </span>
                                    </td>
                                    <td data-label="Target Point"><span class="fw-semibold text-dark"><%= rs.getString("target") %></span></td>
                                    <td data-label="Subject"><div class="text-muted small text-truncate" style="max-width: 200px;"><%= rs.getString("content") %></div></td>
                                    <td class="text-muted small" data-label="Timestamp"><%= rs.getTimestamp("created_at") %></td>
                                    <td class="text-end pe-4" data-label="System State"><span class="small text-success"><i class="fas fa-check-circle me-1"></i>Synchronized</span></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <%
                } catch(Exception e) {
                    out.println("<div class='alert alert-danger'>Database Error: " + e.getMessage() + "</div>");
                } finally {
                    if(rs != null) rs.close();
                    if(stmt != null) stmt.close();
                    if(conn != null) conn.close();
                }
            %>
            <div class="py-5"></div>
        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
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
</body>
</html>

