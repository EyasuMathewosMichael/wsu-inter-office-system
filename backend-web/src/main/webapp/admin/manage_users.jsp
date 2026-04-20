<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="auth_check.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management | WSU School of Informatics</title>

    <link rel="stylesheet" href="../assets/css/style.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* Global Viewport Reset */
        html, body {
            height: 100vh;
            margin: 0;
            padding: 0;
            overflow: hidden;
            background-color: #f8fafc;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        .app-container {
            display: flex;
            width: 100vw;
            height: 100vh;
        }

        /* Sidebar Styling - Locked Labels */
        #sidebar-wrapper {
            width: 280px;
            height: 100vh;
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
            width: 100vw;
            height: 100vh;
            background: rgba(0,0,0,0.5);
            backdrop-filter: blur(2px);
            z-index: 1040;
            top: 0;
            left: 0;
        }

        /* Main Content */
        .main-content {
            flex-grow: 1;
            min-width: 0;
            height: 100vh;
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

        /* User Table UI */
        .user-avatar {
            width: 45px;
            height: 45px;
            border-radius: 12px;
            object-fit: cover;
        }

        .custom-input {
            background-color: #f1f5f9 !important;
            border: none !important;
            padding: 12px 15px !important;
            border-radius: 10px !important;
        }

        .photo-upload-container {
            width: 100px;
            height: 100px;
            margin: 0 auto;
            position: relative;
            cursor: pointer;
        }

        .photo-preview {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #3b82f6;
        }

        .photo-overlay {
            position: absolute;
            bottom: 0;
            right: 0;
            background: #3b82f6;
            color: white;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
        }

        .main-content::-webkit-scrollbar { width: 6px; }
        .main-content::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }

        @media (max-width: 992px) {
            #sidebar-wrapper { position: fixed; left: -280px; }
            #sidebar-wrapper.active { left: 0; }
            .sidebar-overlay.active { display: block; }
            .page-header { padding: 15px 20px; }
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
                    <h3 class="fw-bold mb-0 text-dark">User Management</h3>
                    <p class="text-muted small mb-0 d-none d-md-block">Configure staff access and department roles</p>
                </div>
            </div>
            <button class="btn btn-primary rounded-pill shadow-sm px-4 py-2" data-bs-toggle="modal" data-bs-target="#addUserModal">
                <i class="fas fa-plus me-2"></i><span class="d-none d-sm-inline">Add User</span>
            </button>
        </header>

        <div class="container-fluid px-lg-5 px-3 pb-5">
            <% String status = request.getParameter("status");
               if("success".equals(status)) { %>
                <div class="alert alert-success border-0 shadow-sm alert-dismissible fade show mb-4 py-3" style="border-radius: 15px;">
                    <i class="fas fa-check-circle me-2"></i> Action completed successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="card mb-4 p-3 border-0 shadow-sm" style="border-radius: 20px;">
                <div class="row g-3">
                    <div class="col-md-9">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-0"><i class="fas fa-search text-muted"></i></span>
                            <input type="text" id="userSearch" class="form-control bg-light border-0" placeholder="Search staff members...">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select bg-light border-0" id="deptFilter">
                            <option value="">All Departments</option>
                            <option value="Computer Science">Computer Science</option>
                            <option value="Information Technology">Information Technology</option>
                            <option value="Information Systems">Information Systems</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="card border-0 shadow-sm overflow-hidden" style="border-radius: 20px;">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="bg-light text-muted small text-uppercase">
                            <tr>
                                <th class="ps-4 py-3">Full Name & ID</th>
                                <th>Role</th>
                                <th>Department</th>
                                <th>Status</th>
                                <th class="text-end pe-4">Manage</th>
                            </tr>
                        </thead>
                        <tbody id="userTableBody">
                            <%
                                Connection conn = null;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");
                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery("SELECT * FROM users ORDER BY created_at DESC");

                                    while(rs.next()) {
                                        String id = rs.getString("user_id");
                                        String name = rs.getString("full_name");
                                        String user = rs.getString("username");
                                        String userRole = rs.getString("role");
                                        String dept = rs.getString("department");
                                        String pic = rs.getString("profile_pic_path");
                            %>
                            <tr class="user-row" data-dept="<%= dept %>">
                                <td class="ps-4">
                                    <div class="d-flex align-items-center">
                                        <img src="../assets/img/<%= (pic != null && !pic.isEmpty()) ? pic : "default-avatar.png" %>"
                                             class="user-avatar me-3 border"
                                             onerror="this.src='https://ui-avatars.com/api/?name=<%=name%>&background=random'">
                                        <div>
                                            <div class="fw-bold text-dark"><%= name %></div>
                                            <div class="text-muted small">@<%= user %></div>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="badge bg-primary-subtle text-primary border-0 px-3 py-2 fw-semibold"><%= userRole %></span></td>
                                <td><span class="text-muted fw-medium"><%= dept %></span></td>
                                <td><span class="badge bg-success-subtle text-success px-3">Active</span></td>
                                <td class="text-end pe-4">
                                    <div class="btn-group shadow-sm rounded-pill overflow-hidden border">
                                        <button class="btn btn-white btn-sm text-primary px-3"
                                                onclick="openEditModal('<%=id%>', '<%=name%>', '<%=user%>', '<%=userRole%>', '<%=dept%>', '<%=pic%>')">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <a href="../api/delete_user.jsp?id=<%= id %>" class="btn btn-white btn-sm text-danger px-3" onclick="return confirm('Delete this user?')">
                                            <i class="fas fa-trash-alt"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch(Exception e) { out.println("<tr><td colspan='5' class='text-center p-5'>" + e.getMessage() + "</td></tr>"); }
                                finally { if(conn != null) conn.close(); }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="py-5"></div>
        </div>
    </main>
</div>

<div class="modal fade" id="addUserModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 24px;">
            <div class="modal-header border-0 pb-0 px-4 pt-4">
                <h5 class="modal-title fw-bold">Register New Account</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="../api/save_user.jsp" method="POST" enctype="multipart/form-data">
                <div class="modal-body p-4">
                    <div class="photo-upload-container mb-4" onclick="document.getElementById('profile_pic').click();">
                        <img id="previewImg" src="../assets/img/default-avatar.png" class="photo-preview">
                        <div class="photo-overlay"><i class="fas fa-camera"></i></div>
                        <input type="file" id="profile_pic" name="profile_pic" class="d-none" accept="image/*" onchange="previewFile(this, 'previewImg')">
                    </div>
                    <div class="row g-3">
                        <div class="col-12"><input type="text" name="full_name" class="form-control custom-input" placeholder="Full Name" required></div>
                        <div class="col-6"><input type="text" name="username" class="form-control custom-input" placeholder="Username" required></div>
                        <div class="col-6"><input type="password" name="password" class="form-control custom-input" placeholder="Password" required></div>
                        <div class="col-6">
                            <select name="role" class="form-select custom-input" required>
                                <option value="Staff">Staff</option>
                                <option value="Dept Head">Dept Head</option>
                                <option value="Admin">Admin</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <select name="department" class="form-select custom-input" required>
                                <option value="Computer Science">Computer Science</option>
                                <option value="Information Technology">Information Technology</option>
                                <option value="Information Systems">Information Systems</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 p-4 pt-0">
                    <button type="submit" class="btn btn-primary w-100 py-3 fw-bold shadow-sm" style="border-radius: 12px;">Create Account</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editUserModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 24px;">
            <div class="modal-header border-0 pb-0 px-4 pt-4">
                <h5 class="modal-title fw-bold">Update Account</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="../api/update_user.jsp" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="user_id" id="edit_user_id">
                <div class="modal-body p-4">
                    <div class="photo-upload-container mb-4" onclick="document.getElementById('edit_profile_pic').click();">
                        <img id="editPreviewImg" src="../assets/img/default-avatar.png" class="photo-preview">
                        <div class="photo-overlay"><i class="fas fa-camera"></i></div>
                        <input type="file" id="edit_profile_pic" name="profile_pic" class="d-none" accept="image/*" onchange="previewFile(this, 'editPreviewImg')">
                    </div>
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="small fw-bold text-secondary ms-2 mb-1">Full Name</label>
                            <input type="text" name="full_name" id="edit_full_name" class="form-control custom-input" placeholder="Full Name" required>
                        </div>
                        <div class="col-6">
                            <label class="small fw-bold text-secondary ms-2 mb-1">Username</label>
                            <input type="text" name="username" id="edit_username" class="form-control custom-input" placeholder="Username" required>
                        </div>
                        <div class="col-6">
                            <label class="small fw-bold text-secondary ms-2 mb-1">New Password</label>
                            <input type="password" name="password" class="form-control custom-input" placeholder="Leave blank to keep">
                        </div>
                        <div class="col-6">
                            <label class="small fw-bold text-secondary ms-2 mb-1">Role</label>
                            <select name="role" id="edit_role" class="form-select custom-input" required>
                                <option value="Staff">Staff</option>
                                <option value="Dept Head">Dept Head</option>
                                <option value="Admin">Admin</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="small fw-bold text-secondary ms-2 mb-1">Department</label>
                            <select name="department" id="edit_department" class="form-select custom-input" required>
                                <option value="Computer Science">Computer Science</option>
                                <option value="Information Technology">Information Technology</option>
                                <option value="Information Systems">Information Systems</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 p-4 pt-0">
                    <button type="submit" class="btn btn-primary w-100 py-3 fw-bold shadow-sm" style="border-radius: 12px;">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
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

        // Search and Filter Logic
        const searchInput = document.getElementById('userSearch');
        const deptFilter = document.getElementById('deptFilter');
        const rows = document.querySelectorAll('.user-row');

        function filterUsers() {
            const query = searchInput.value.toLowerCase();
            const dept = deptFilter.value;

            rows.forEach(row => {
                const text = row.innerText.toLowerCase();
                const rowDept = row.getAttribute('data-dept');
                const matchesSearch = text.includes(query);
                const matchesDept = dept === "" || rowDept === dept;
                row.style.display = matchesSearch && matchesDept ? "" : "none";
            });
        }

        searchInput.addEventListener('input', filterUsers);
        deptFilter.addEventListener('change', filterUsers);
    });

    function openEditModal(id, name, user, role, dept, pic) {
        document.getElementById('edit_user_id').value = id;
        document.getElementById('edit_full_name').value = name;
        document.getElementById('edit_username').value = user;
        document.getElementById('edit_role').value = role;
        document.getElementById('edit_department').value = dept;

        const preview = document.getElementById('editPreviewImg');
        if (pic && pic !== 'null' && pic !== '') {
            preview.src = '../assets/img/' + pic;
        } else {
            preview.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(name) + '&background=random';
        }

        const editModal = new bootstrap.Modal(document.getElementById('editUserModal'));
        editModal.show();
    }

    function previewFile(input, imgId) {
        const file = input.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) { document.getElementById(imgId).src = e.target.result; }
            reader.readAsDataURL(file);
        }
    }
</script>

</body>
</html>
