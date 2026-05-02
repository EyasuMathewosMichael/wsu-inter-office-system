<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="auth_check.jsp" %>
<%@ include file="/WEB-INF/jspf/account_helpers.jspf" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";

        StringBuilder escaped = new StringBuilder();
        for (char c : value.toCharArray()) {
            switch (c) {
                case '&': escaped.append("&amp;"); break;
                case '<': escaped.append("&lt;"); break;
                case '>': escaped.append("&gt;"); break;
                case '"': escaped.append("&quot;"); break;
                case '\'': escaped.append("&#39;"); break;
                default: escaped.append(c);
            }
        }
        return escaped.toString();
    }

    private String safeProfileImage(String value) {
        if (value == null || value.trim().isEmpty()) return "admin-avatar.png";

        String normalized = value.replace("\\", "/").trim();
        String fileName = normalized.substring(normalized.lastIndexOf('/') + 1);
        if (!fileName.matches("[a-zA-Z0-9._-]+")) return "admin-avatar.png";

        return fileName;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | WSU School of Informatics</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        /* Viewport & App Layout */
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

        #sidebar-wrapper .list-group-item:hover { color: white; background: rgba(255, 255, 255, 0.05); }
        #sidebar-wrapper .list-group-item.active { background: #3b82f6 !important; color: white !important; }

        .sidebar-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(2, 6, 23, 0.58);
            backdrop-filter: blur(10px);
            z-index: 1040;
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
        }

        .profile-img-container { position: relative; display: inline-block; }
        #preview-img {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border: 4px solid #fff;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        }

        .card { border-radius: 20px; border: 1px solid #e2e8f0; }
        .loading-spinner { display: none; }
        .main-content::-webkit-scrollbar { width: 6px; }
        .main-content::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }

        #resToast {
            background: #1f2937;
            color: #fff;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.18);
        }

        #resToast.toast-success {
            background: #198754 !important;
        }

        #resToast.toast-error {
            background: #dc3545 !important;
        }

        #resToast .toast-body,
        #resToast .btn-close {
            color: inherit;
        }

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
            .profile-actions {
                flex-direction: column-reverse;
                align-items: stretch !important;
                gap: 0.75rem;
            }
            .profile-actions .btn {
                width: 100%;
            }
            .toast-container {
                left: 0;
                right: 0;
            }
        }
    </style>
</head>
<body>

<%
    Object adminObj = session.getAttribute("admin_id");
    if (adminObj == null) {
        adminObj = session.getAttribute("user_id");
    }
    if (adminObj == null) {
        response.sendRedirect(response.encodeRedirectURL("login.jsp?error=unauthorized&reason=profile_admin_id"));
        return;
    }
    session.setAttribute("admin_id", adminObj);
    int adminId = Integer.parseInt(adminObj.toString());

    String fullName = "", username = "", bio = "", phone = "", personalEmail = "", profilePic = "admin-avatar.png";

    try {
        Connection conn = getDbConnection(application);
        ensureUsersPersonalEmailColumn(conn);
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE user_id = ?");
        ps.setInt(1, adminId);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            fullName = rs.getString("full_name");
            username = rs.getString("username");
            bio = rs.getString("bio");
            phone = rs.getString("phone");
            personalEmail = rs.getString("personal_email");
            if(rs.getString("profile_pic_path") != null && !rs.getString("profile_pic_path").isEmpty()) {
                profilePic = rs.getString("profile_pic_path");
            }
        }
        conn.close();
    } catch(Exception e) { e.printStackTrace(); }

    String escapedFullName = escapeHtml(fullName);
    String escapedUsername = escapeHtml(username);
    String escapedBio = escapeHtml(bio);
    String escapedPhone = escapeHtml(phone);
    String escapedPersonalEmail = escapeHtml(personalEmail);
    String safeProfilePic = safeProfileImage(profilePic);
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
               <a href="<%= response.encodeURL("dashboard.jsp") %>" class="list-group-item list-group-item-action <%= currentUri.endsWith("dashboard.jsp") ? "active" : "" %>">
                   <i class="fa-solid fa-house-chimney-window me-3"></i><span>Dashboard</span>
               </a>
               <a href="<%= response.encodeURL("manage_users.jsp") %>" class="list-group-item list-group-item-action <%= currentUri.endsWith("manage_users.jsp") ? "active" : "" %>">
                   <i class="fa-solid fa-user-gear me-3"></i><span>Manage Users</span>
               </a>
               <a href="<%= response.encodeURL("chat.jsp") %>" class="list-group-item list-group-item-action <%= currentUri.endsWith("chat.jsp") ? "active" : "" %>">
                  <i class="fa-solid fa-comment-dots me-3"></i><span>Communication Hub</span>
               </a>
           </div>

           <div class="nav-label mt-3">Administration</div>
           <div class="list-group list-group-flush px-2">
               <a href="<%= response.encodeURL("announcements.jsp") %>" class="list-group-item list-group-item-action <%= currentUri.endsWith("announcements.jsp") ? "active" : "" %>">
                   <i class="fa-solid fa-tower-broadcast me-3"></i><span>Announcements</span>
               </a>
               <a href="<%= response.encodeURL("traffic_logs.jsp") %>" class="list-group-item list-group-item-action <%= currentUri.endsWith("traffic_logs.jsp") ? "active" : "" %>">
                   <i class="fa-solid fa-chart-bar me-3"></i><span>Traffic Logs</span>
               </a>
           </div>

           <div class="nav-label mt-3 d-lg-none">Account</div>
           <div class="list-group list-group-flush px-2 d-lg-none">
               <a href="<%= response.encodeURL("profile.jsp") %>" class="list-group-item list-group-item-action <%= currentUri.endsWith("profile.jsp") ? "active" : "" %>">
                   <i class="fas fa-id-card me-3"></i><span>My Profile</span>
               </a>
               <a href="<%= response.encodeURL("../logout.jsp") %>" class="list-group-item list-group-item-action">
                   <i class="fas fa-sign-out-alt me-3"></i><span>Sign out</span>
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
                       <li><a class="dropdown-item rounded-2 py-2" href="<%= response.encodeURL("profile.jsp") %>"><i class="fas fa-id-card me-2 opacity-50"></i>My Profile</a></li>
                       <li><hr class="dropdown-divider opacity-10"></li>
                       <li><a class="dropdown-item rounded-2 text-danger" href="<%= response.encodeURL("../logout.jsp") %>"><i class="fas fa-sign-out-alt me-2"></i>Sign out</a></li>
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
                    <h3 class="fw-bold mb-0 text-dark">My Profile</h3>
                    <p class="text-muted small mb-0 d-none d-md-block">Update your administrator details and account security</p>
                </div>
            </div>
        </header>

        <div class="container py-4 py-lg-5">
            <div class="row justify-content-center">
                <div class="col-md-10 col-lg-8">
                    <div class="card shadow-sm overflow-hidden border-0">
                        <div class="card-header bg-dark border-0 pt-5 pb-4 text-center">
                            <div class="profile-img-container">
                                <img src="../assets/img/<%= safeProfilePic %>" id="preview-img" class="rounded-circle mb-3" onerror="this.src='https://ui-avatars.com/api/?name=Admin'">
                            </div>
                            <h4 class="fw-bold text-white mb-1" id="display-name"><%= escapedFullName %></h4>
                            <span class="text-primary small fw-bold text-uppercase">System Administrator</span>
                        </div>

                        <div class="card-body p-4 p-lg-5">
                            <form id="profileForm" enctype="multipart/form-data">
                                <div class="row g-4">
                                    <div class="col-12"><h6 class="text-muted text-uppercase small fw-bold border-bottom pb-2">Profile Information</h6></div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Full Name</label>
                                        <input type="text" name="full_name" id="full_name" class="form-control border-0 bg-light rounded-3" value="<%= escapedFullName %>" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Username</label>
                                        <input type="text" class="form-control border-0 bg-light rounded-3 text-muted" value="<%= escapedUsername %>" readonly disabled>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label small fw-bold">Bio</label>
                                        <textarea name="bio" class="form-control border-0 bg-light rounded-3" rows="3" placeholder="Tell us about yourself..."><%= escapedBio %></textarea>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Phone</label>
                                        <input type="text" name="phone" class="form-control border-0 bg-light rounded-3" value="<%= escapedPhone %>" placeholder="Enter phone number">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Personal Email</label>
                                        <input type="email" name="personal_email" class="form-control border-0 bg-light rounded-3" value="<%= escapedPersonalEmail %>" placeholder="Enter personal email for password reset">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">New Password</label>
                                        <input type="password" name="new_password" class="form-control border-0 bg-light rounded-3" placeholder="Leave empty to keep current">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-bold">Profile Photo</label>
                                        <input type="file" name="profile_pic" id="profile_pic_input" class="form-control border-0 bg-light rounded-3" accept="image/*">
                                    </div>
                                </div>

                                <div class="mt-5 d-flex justify-content-between align-items-center profile-actions">
                                    <a href="<%= response.encodeURL("dashboard.jsp") %>" class="text-decoration-none text-muted small"><i class="fas fa-chevron-left me-1"></i> Back to Dashboard</a>
                                    <button type="submit" class="btn btn-primary px-5 py-2 rounded-pill fw-bold shadow-sm" id="saveBtn">
                                        <span class="spinner-border spinner-border-sm loading-spinner me-2"></span> Save Changes
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="resToast" class="toast align-items-center border-0" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex"><div class="toast-body" id="toastMsg"></div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>
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
    });

    // Local Image Preview
    document.getElementById('profile_pic_input').onchange = function () {
        const [file] = this.files;
        if (file) {
            document.getElementById('preview-img').src = URL.createObjectURL(file);
        }
    };

    const profileForm = document.getElementById('profileForm');
    const saveBtn = document.getElementById('saveBtn');
    const spinner = document.querySelector('.loading-spinner');
    const toastEl = document.getElementById('resToast');
    const toast = new bootstrap.Toast(toastEl);

    profileForm.addEventListener('submit', function(e) {
        e.preventDefault();
        saveBtn.disabled = true;
        spinner.style.display = 'inline-block';

        const formData = new FormData(this);

        fetch('../api/update_profile.jsp', {
            method: 'POST',
            body: formData
        })
        .then(async res => {
            const text = await res.text();
            try {
                return JSON.parse(text);
            } catch (e) {
                // Detailed error for 500 errors or malformed JSON
                if (text.includes("HTTP Status 500")) {
                    throw new Error("Server Error (500): Check your context.xml or database connection.");
                }
                throw new Error("Malformed Response: " + text.substring(0, 50));
            }
        })
        .then(data => {
            if (data.status === "success") {
                showToast(data.message, "bg-success");
                document.getElementById('display-name').innerText = document.getElementById('full_name').value;
            } else {
                showToast(data.message, "bg-danger");
            }
        })
        .catch(err => {
            console.error('AJAX Error:', err);
            showToast(err.message || "Connection error", "bg-danger");
        })
        .finally(() => {
            saveBtn.disabled = false;
            spinner.style.display = 'none';
        });
    });

    function showToast(msg, color) {
        document.getElementById('toastMsg').innerText = msg;
        const tone = color === "bg-success" ? "toast-success" : "toast-error";
        toastEl.className = `toast align-items-center border-0 ${tone}`;
        toast.show();
    }
</script>
<%@ include file="navigation_prefetch.jspf" %>
</body>
</html>

