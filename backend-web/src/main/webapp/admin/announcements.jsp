<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="auth_check.jsp" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Announcements | WSU School of Informatics</title>

    <link rel="stylesheet" href="../assets/css/style.css">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* 1. Global Viewport Reset */
        html, body {
            min-height: 100%;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
            background-color: #f8fafc;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        /* 2. Seamless Flex Layout */
        .app-container {
            display: flex;
            width: 100%;
            min-height: 100vh;
            min-height: 100dvh;
            align-items: stretch;
        }

        /* 3. Sidebar Styling */
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
            display: inline-block !important;
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

        /* 4. Main Content */
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

        /* Announcement UI */
        .announcement-card {
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            background: white;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .announcement-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.05);
            border-color: #3b82f6;
        }

        .attachment-badge {
            display: inline-flex;
            align-items: center;
            padding: 10px 16px;
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            text-decoration: none !important;
            color: #334155;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .dept-tag {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 700;
            padding: 6px 12px;
            border-radius: 8px;
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
            #sidebar-wrapper.active {
                transform: translateX(0);
            }
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
            .sidebar-overlay.active {
                display: block;
            }
            .page-header {
                padding: 15px 20px;
                flex-wrap: wrap;
                gap: 1rem;
            }
        }

        @media (max-width: 768px) {
            .container-fluid { padding-left: 1rem !important; padding-right: 1rem !important; }
            .card-footer {
                flex-wrap: wrap;
            }
            .card-footer .btn {
                flex: 1 1 auto;
            }
        }
    </style>
</head>
<body>

<div class="app-container">
    <div class="sidebar-overlay" id="sidebar-overlay"></div>

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
                    <h3 class="fw-bold mb-0 text-dark">Announcements</h3>
                    <p class="text-muted small mb-0 d-none d-md-block">Management portal for campus-wide broadcasts</p>
                </div>
            </div>
            <button class="btn btn-primary rounded-pill shadow-sm px-4 py-2" data-bs-toggle="modal" data-bs-target="#postModal">
                <i class="fas fa-plus me-2"></i><span class="d-none d-sm-inline">Create New</span>
            </button>
        </div>

        <div class="container-fluid px-lg-5 px-3 pb-5">
            <%
                String status = request.getParameter("status");
                String msg = request.getParameter("msg");
                if("success".equals(status)) {
                    String alertText = "deleted".equals(msg) ? "Announcement removed." : ("updated".equals(msg) ? "Announcement updated successfully." : "Broadcast published successfully!");
            %>
                <div class="alert alert-success border-0 shadow-sm alert-dismissible fade show mb-4 py-3" role="alert" style="border-radius: 15px;">
                    <i class="fas fa-check-circle me-2"></i> <%= alertText %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="row g-4">
                <%
                    Connection conn = null;
                    Statement st = null;
                    ResultSet rs = null;
                    boolean hasData = false;
                    try {
                        conn = getDbConnection(application);
                        st = conn.createStatement();
                        rs = st.executeQuery("SELECT * FROM announcements ORDER BY created_at DESC");

                        while(rs.next()) {
                            hasData = true;
                            int announcementId = rs.getInt("announcement_id");
                            String title = rs.getString("title");
                            String content = rs.getString("content");
                            String targetDept = rs.getString("target_dept");
                            String filePath = rs.getString("attachment_path");
                            boolean hasAttachment = (filePath != null && !filePath.trim().isEmpty());
                %>
                <div class="col-xl-6">
                    <div class="card announcement-card h-100">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="dept-tag bg-primary-subtle text-primary">
                                    <%= targetDept %>
                                </span>
                                <div class="text-muted small fw-medium">
                                    <i class="far fa-clock me-1"></i> <%= rs.getTimestamp("created_at") %>
                                </div>
                            </div>

                            <h5 class="fw-bold text-dark mb-3"><%= title %></h5>

                            <p class="text-secondary mb-4 leading-relaxed">
                                <%= content %>
                            </p>

                            <% if(hasAttachment) { %>
                                <div class="mt-auto">
                                    <a href="../api/view_file.jsp?id=<%= announcementId %>" target="_blank" class="attachment-badge w-100 justify-content-between">
                                        <span><i class="fas fa-file-lines me-2"></i><%= new java.io.File(filePath).getName() %></span>
                                        <i class="fas fa-chevron-right opacity-50" style="font-size: 0.7rem;"></i>
                                    </a>
                                </div>
                            <% } %>
                        </div>
                        <div class="card-footer bg-light bg-opacity-50 border-0 p-3 px-4 d-flex justify-content-end gap-2">
                                <button type="button"
                                        class="btn btn-white shadow-sm btn-sm border text-primary px-3 rounded-pill"
                                        onclick="populateEditModal('<%= announcementId %>', '<%= title.replace("'", "\\'") %>', '<%= targetDept %>', `<%= content.replace("`", "\\`") %>`, '<%= hasAttachment ? new java.io.File(filePath).getName() : "" %>')"
                                        title="Edit">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button type="button"
                                   class="btn btn-white shadow-sm btn-sm border text-danger px-3 rounded-pill"
                                   onclick="deleteAnnouncement('<%= announcementId %>')" title="Delete">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                        </div>
                    </div>
                </div>
                <%
                        }
                        if (!hasData) {
                %>
                    <div class="col-12 text-center py-5">
                        <div class="opacity-25 mb-3">
                            <i class="fas fa-bullhorn fa-4x"></i>
                        </div>
                        <h5 class="text-muted">No announcements posted yet</h5>
                    </div>
                <%
                        }
                    } catch(Exception e) {
                        out.println("<div class='alert alert-danger'>Connection Error: " + e.getMessage() + "</div>");
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                        if (st != null) try { st.close(); } catch (SQLException ignore) {}
                        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                    }
                %>
            </div>
            <div class="py-5"></div>
        </div>
    </main>
</div>

<%-- Create Broadcast Modal --%>
<div class="modal fade" id="postModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-2xl" style="border-radius: 24px;">
            <div class="modal-header border-0 pb-0 px-4 pt-4">
                <h5 class="modal-title fw-bold">New Announcement</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="../api/save_announcement.jsp" method="POST" enctype="multipart/form-data">
                <div class="modal-body p-4">
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-secondary">Visibility Scope</label>
                        <select name="target_dept" class="form-select bg-light border-0 p-3" style="border-radius: 12px;" required>
                            <option value="Global">Global (All Departments)</option>
                            <option value="Computer Science">Computer Science</option>
                            <option value="Information Technology">Information Technology</option>
                            <option value="Information Systems">Information Systems</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-secondary">Headline</label>
                        <input type="text" name="title" class="form-control bg-light border-0 p-3" style="border-radius: 12px;" placeholder="Announcement Title" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-secondary">Message Content</label>
                        <textarea name="content" rows="4" class="form-control bg-light border-0 p-3" style="border-radius: 12px;" placeholder="Type your announcement here..." required></textarea>
                    </div>
                    <div class="mb-2">
                        <label class="form-label small fw-bold text-secondary">File Attachment</label>
                        <div class="bg-light p-3 rounded-4 border-dashed">
                             <input type="file" name="attachment" class="form-control bg-transparent border-0 p-0">
                             <div class="small text-muted mt-1"><i class="fas fa-info-circle me-1"></i>PDF, Images, or Documents</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 p-4 pt-0">
                    <button type="button" class="btn btn-light px-4 py-2" data-bs-dismiss="modal" style="border-radius: 12px;">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4 py-2 shadow" style="border-radius: 12px; font-weight: 600;">
                        Publish Broadcast
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Edit Broadcast Modal --%>
<div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-2xl" style="border-radius: 24px;">
            <div class="modal-header border-0 pb-0 px-4 pt-4">
                <h5 class="modal-title fw-bold">Edit Announcement</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="../api/update_announcement.jsp" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="id" id="edit_id">
                <input type="hidden" name="redirect_to" value="<%= request.getContextPath() %>/admin/announcements.jsp">
                <div class="modal-body p-4">
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-secondary">Visibility Scope</label>
                        <select name="target_dept" id="edit_dept" class="form-select bg-light border-0 p-3" style="border-radius: 12px;" required>
                            <option value="Global">Global (All Departments)</option>
                            <option value="Computer Science">Computer Science</option>
                            <option value="Information Technology">Information Technology</option>
                            <option value="Information Systems">Information Systems</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-secondary">Headline</label>
                        <input type="text" name="title" id="edit_title" class="form-control bg-light border-0 p-3" style="border-radius: 12px;" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small fw-bold text-secondary">Message Content</label>
                        <textarea name="content" id="edit_content" rows="4" class="form-control bg-light border-0 p-3" style="border-radius: 12px;" required></textarea>
                    </div>
                    <div class="mb-2">
                        <label class="form-label small fw-bold text-secondary">Attachment</label>
                        <div class="bg-light p-3 rounded-4 mb-2">
                            <small class="text-muted d-block mb-1">Current file:</small>
                            <span id="edit_file_name" class="fw-bold small text-dark">No attachment</span>
                        </div>
                        <div class="bg-light p-3 rounded-4 border-dashed">
                             <input type="file" name="attachment" class="form-control bg-transparent border-0 p-0">
                             <div class="small text-muted mt-1"><i class="fas fa-info-circle me-1"></i>Uploading new file replaces the old one</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 p-4 pt-0">
                    <button type="button" class="btn btn-light px-4 py-2" data-bs-dismiss="modal" style="border-radius: 12px;">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4 py-2 shadow" style="border-radius: 12px; font-weight: 600;">
                        Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function populateEditModal(id, title, dept, content, fileName) {
        document.getElementById('edit_id').value = id;
        document.getElementById('edit_title').value = title;
        document.getElementById('edit_dept').value = dept;
        document.getElementById('edit_content').value = content;
        document.getElementById('edit_file_name').innerText = fileName || "No attachment";

        var editModal = new bootstrap.Modal(document.getElementById('editModal'));
        editModal.show();
    }

    async function deleteAnnouncement(id) {
        if (!confirm('Permanently delete this announcement?')) return;

        try {
            const response = await fetch('../api/delete_announcement.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'id=' + encodeURIComponent(id)
            });

            const data = await response.json();
            if (data.status === 'success') {
                window.location.reload();
            } else {
                alert(data.message || 'Delete failed.');
            }
        } catch (error) {
            console.error('Delete failed:', error);
            alert('Delete failed. Please try again.');
        }
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

