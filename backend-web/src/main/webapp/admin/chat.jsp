<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="auth_check.jsp" %>
<%
    Object adminSessionId = session.getAttribute("user_id");
    String finalAdminId = (adminSessionId != null) ? adminSessionId.toString() : "-1";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Communication Hub | WSU-SoI Admin</title>

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

        /* Sidebar Styling */
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

        /* Main Content & Chat Layout */
        .main-content {
            flex-grow: 1;
            min-width: 0;
            min-height: 100vh;
            min-height: 100dvh;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .page-header-sticky {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(12px);
            padding: 1.2rem 2.5rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .admin-chat-layout {
            display: flex;
            flex-grow: 1;
            margin: 1.5rem;
            background: #fff;
            border-radius: 24px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.06);
            border: 1px solid #e2e8f0;
            overflow: hidden;
        }

        .chat-mobile-overlay {
            display: none;
            position: absolute;
            inset: 0;
            background: rgba(15, 23, 42, 0.35);
            z-index: 110;
        }

        .chat-mobile-overlay.active {
            display: block;
        }

        .staff-sidebar {
            width: 320px;
            border-right: 1px solid #f1f5f9;
            display: flex;
            flex-direction: column;
            background: #fff;
        }

        .chat-main {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background: #ffffff;
            position: relative;
        }

        /* Chat Display & Bubbles */
        #chatDisplay {
            flex-grow: 1;
            overflow-y: auto;
            padding: 2rem;
            background-color: #f8fafc;
            background-image: radial-gradient(#e2e8f0 0.8px, transparent 0.8px);
            background-size: 20px 20px;
            display: flex;
            flex-direction: column;
        }

        .msg-bubble-web {
            max-width: 75%;
            padding: 12px 16px;
            margin-bottom: 12px;
            border-radius: 18px;
            position: relative;
            font-size: 0.9rem;
            line-height: 1.5;
            animation: fadeIn 0.3s ease forwards;
            transition: all 0.3s ease;
        }

        /* Highlight animation for when a message is navigated to */
        .highlight-msg {
            animation: pulse-highlight 2s ease;
        }

        @keyframes pulse-highlight {
            0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.4); }
            30% { transform: scale(1.02); box-shadow: 0 0 0 10px rgba(59, 130, 246, 0); }
            100% { transform: scale(1); }
        }

        .msg-sent {
            align-self: flex-end;
            background: #3b82f6;
            color: white;
            border-bottom-right-radius: 4px;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
        }

        .msg-received {
            align-self: flex-start;
            background: white;
            color: #1e293b;
            border-bottom-left-radius: 4px;
            border: 1px solid #e2e8f0;
        }

        /* Reply UI */
        .reply-box-web {
            background: rgba(0, 0, 0, 0.05);
            border-left: 3px solid #3b82f6;
            padding: 8px;
            border-radius: 8px;
            margin-bottom: 8px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .reply-box-web:hover {
            background: rgba(0, 0, 0, 0.1);
        }

        .msg-sent .reply-box-web {
            background: rgba(255, 255, 255, 0.15);
            border-left-color: #fff;
        }

        #replyPreview {
            position: absolute;
            bottom: 90px;
            left: 20px;
            right: 20px;
            z-index: 10;
        }

        .reply-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-left: 4px solid #3b82f6;
            border-radius: 12px;
            padding: 12px 16px;
        }

        /* Input Bar */
        .chat-input-wrapper {
            padding: 1.2rem 2rem;
            background: white;
            border-top: 1px solid #f1f5f9;
        }

        .custom-msg-input {
            background: #f1f5f9 !important;
            border: 2px solid transparent !important;
            border-radius: 15px !important;
            padding: 12px 20px !important;
        }

        .custom-msg-input:focus {
            background: #fff !important;
            border-color: #3b82f6 !important;
        }

        /* Staff Items */
        .staff-item {
            padding: 14px 20px;
            border: none;
            background: transparent;
            width: 100%;
            text-align: left;
            transition: 0.2s;
        }

        .staff-item:hover { background: #f8fafc; }
        .staff-item.active { background: #f0f7ff; border-right: 3px solid #3b82f6; }

       /* Improved Message Actions Styling */
       .msg-actions {
           position: absolute;
           top: -25px;
           right: 10px;
           display: none;
           gap: 8px;
           background: white;
           padding: 6px 12px;
           border-radius: 20px;
           box-shadow: 0 4px 15px rgba(0,0,0,0.12);
           border: 1px solid #e2e8f0;
           z-index: 100;
           align-items: center;
       }

       .msg-bubble-web:hover .msg-actions {
           display: flex;
       }

       .msg-actions i {
           cursor: pointer;
           padding: 4px;
           font-size: 0.9rem;
           transition: all 0.2s ease;
       }

       .fa-pen-to-square { color: #3b82f6 !important; }
       .fa-trash-can { color: #ef4444 !important; }

       .msg-actions i:hover {
           transform: scale(1.2);
           opacity: 0.8;
       }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
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
            .page-header-sticky { padding: 1rem 1.25rem; }
            .admin-chat-layout {
                margin: 0.75rem;
                min-height: calc(100dvh - 110px);
            }
            .staff-sidebar {
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: min(88vw, 320px);
                max-width: 88vw;
                z-index: 120;
                background: white;
                box-shadow: 0 18px 40px rgba(15, 23, 42, 0.18);
                transition: transform 0.25s ease;
            }
            .staff-sidebar.hidden-mobile { transform: translateX(-110%); }
            #chatDisplay { padding: 1rem; }
            .chat-input-wrapper { padding: 1rem; }
            .msg-bubble-web { max-width: 92%; }
            #replyPreview { left: 12px; right: 12px; bottom: 82px; }
        }

        @media (max-width: 768px) {
            .admin-chat-layout { margin: 0.5rem; border-radius: 18px; }
            .page-header-sticky { padding: 0.9rem 1rem; }
            .chat-input-wrapper form { gap: 0.75rem !important; }
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
        <div class="page-header-sticky d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center">
                <button class="btn btn-light d-lg-none me-3" id="hamburger-menu"><i class="fas fa-bars"></i></button>
                <div>
                    <h3 class="fw-bold text-dark mb-0">Communication Hub</h3>
                    <p class="text-muted small mb-0">Secure portal for staff & administration</p>
                </div>
            </div>
        </div>

        <div class="admin-chat-layout">
            <div class="chat-mobile-overlay d-lg-none" id="chat-mobile-overlay"></div>
            <div class="staff-sidebar hidden-mobile" id="staffSidebar">
                <div class="p-4 border-bottom">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="fw-bold mb-0">Direct Messages</h6>
                        <button class="btn btn-sm btn-light d-lg-none" onclick="toggleStaffList()"><i class="fas fa-times"></i></button>
                    </div>
                    <div class="search-container position-relative">
                        <i class="fas fa-search position-absolute" style="left: 15px; top: 12px; color: #94a3b8;"></i>
                        <input type="text" id="searchStaff" class="form-control ps-5 rounded-3 bg-light border-0" placeholder="Search staff..." onkeyup="filterStaff()">
                    </div>
                </div>
                <div class="staff-list-container flex-grow-1 overflow-auto" id="staffList">
                   <%
                       try {
                           Class.forName("com.mysql.cj.jdbc.Driver");
                           Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/inter_office_db", "root", "");
                           String sql = "SELECT user_id, username, full_name, department FROM users WHERE user_id != ? ORDER BY department, full_name";
                           PreparedStatement ps = conn.prepareStatement(sql);
                           ps.setString(1, finalAdminId);
                           ResultSet rs = ps.executeQuery();
                           while(rs.next()) {
                               String fName = rs.getString("full_name");
                               if(fName == null || fName.isEmpty()) fName = rs.getString("username");
                   %>
                   <button class="staff-item" onclick="selectStaff('<%= rs.getString("user_id") %>', '<%= fName %>', '<%= rs.getString("department") %>', this)">
                       <div class="d-flex align-items-center">
                           <img src="https://ui-avatars.com/api/?name=<%= fName %>&background=random&size=128" class="rounded-circle me-3" width="42">
                           <div class="flex-grow-1 overflow-hidden">
                               <div class="fw-bold text-dark text-truncate small"><%= fName %></div>
                               <div class="text-muted small" style="font-size: 0.7rem;"><%= rs.getString("department") %></div>
                           </div>
                       </div>
                   </button>
                   <% } conn.close(); } catch(Exception e) { out.println("Error loading list."); } %>
                </div>
            </div>

            <div class="chat-main">
                <div class="p-3 bg-white border-bottom d-flex align-items-center justify-content-between shadow-sm">
                    <div class="d-flex align-items-center">
                        <button class="btn btn-primary btn-sm me-3 d-lg-none" onclick="toggleStaffList()"><i class="fas fa-users"></i></button>
                        <div id="activeUserInfo" class="d-none d-flex align-items-center">
                            <div class="bg-primary text-white rounded-circle me-3 d-flex align-items-center justify-content-center fw-bold" style="width: 40px; height: 40px; font-size: 0.8rem;">
                                <i class="fas fa-user-tie"></i>
                            </div>
                            <div>
                                <h6 class="mb-0 fw-bold" id="activeStaffName">Staff Name</h6>
                                <span class="text-primary small fw-semibold" id="activeStaffDept" style="font-size: 0.65rem;">Department</span>
                            </div>
                        </div>
                        <div id="noSelection" class="text-muted small fw-medium"><i class="fas fa-info-circle me-2"></i>Select a contact to start messaging</div>
                    </div>
                </div>

                <div id="chatDisplay">
                    <div class="text-center my-auto text-muted opacity-25">
                        <i class="fas fa-comments fa-5x mb-3"></i>
                        <h5>Your Conversation History</h5>
                        <p>All messages are logged and secured.</p>
                    </div>
                </div>

                <div id="replyPreview" class="d-none">
                    <div class="reply-container d-flex justify-content-between align-items-center border shadow-sm">
                        <div class="text-truncate me-3">
                            <div class="text-primary fw-bold small mb-1"><i class="fas fa-reply me-1"></i> Replying to message</div>
                            <div id="replyText" class="text-muted small text-truncate" style="max-width: 400px;">...</div>
                        </div>
                        <button class="btn-close btn-sm p-2 bg-light rounded-circle" onclick="cancelReply()"></button>
                    </div>
                </div>

                <div class="chat-input-wrapper">
                    <form id="sendForm" class="d-flex gap-3 align-items-center">
                        <input type="file" id="fileAttach" class="d-none" name="attachment" onchange="updateFileLabel()">
                        <button type="button" class="btn btn-light rounded-circle border shadow-sm" style="width: 48px; height: 48px;" onclick="document.getElementById('fileAttach').click()">
                            <i class="fas fa-paperclip text-muted"></i>
                        </button>

                        <div class="flex-grow-1 position-relative">
                            <input type="text" id="msgInput" class="form-control custom-msg-input" placeholder="Write something..." autocomplete="off">
                            <div id="fileNameLabel" class="position-absolute small text-primary fw-bold" style="top: -22px; left: 10px;"></div>
                        </div>

                        <button type="submit" class="btn btn-primary rounded-circle shadow" style="width: 50px; height: 50px;">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>

<div class="modal fade" id="editMsgModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header border-0 pb-0 pt-4 px-4">
                <h6 class="modal-title fw-bold">Edit message</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <input type="hidden" id="editChatId">
                <textarea id="editMsgText" class="form-control bg-light border-0 p-3" rows="4" style="border-radius: 16px;"></textarea>
            </div>
            <div class="modal-footer border-0 p-4 pt-0">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary rounded-pill px-4" onclick="saveEdit()">Update</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const ADMIN_ID = "<%= finalAdminId %>";
    let targetId = -1;
    let replyId = null;
    let lastMessageCount = 0;
    let editModal;

    document.addEventListener('DOMContentLoaded', () => {
        const modalEl = document.getElementById('editMsgModal');
        if (modalEl) editModal = new bootstrap.Modal(modalEl);
        const appSidebar = document.getElementById('sidebar-wrapper');
        const appOverlay = document.getElementById('sidebar-overlay');
        const closeSidebar = document.getElementById('close-sidebar');
        const chatOverlay = document.getElementById('chat-mobile-overlay');

        appOverlay?.addEventListener('click', () => {
            appSidebar.classList.remove('active');
            appOverlay.classList.remove('active');
        });
        closeSidebar?.addEventListener('click', () => {
            appSidebar.classList.remove('active');
            appOverlay.classList.remove('active');
        });
        chatOverlay?.addEventListener('click', () => setStaffListOpen(false));

        const hamburgerMenu = document.getElementById('hamburger-menu');
        if (hamburgerMenu) {
            hamburgerMenu.addEventListener('click', () => {
                appSidebar.classList.add('active');
                appOverlay.classList.add('active');
            });
        }

        const sendForm = document.getElementById('sendForm');
        if (sendForm) {
            sendForm.onsubmit = async (e) => {
                e.preventDefault();
                const msgInput = document.getElementById('msgInput');
                const text = msgInput.value.trim();
                const fileInput = document.getElementById('fileAttach');
                const file = fileInput.files[0];

                if ((!text && !file) || targetId === -1) return;

                const formData = new FormData();
                formData.append('sender_id', ADMIN_ID);
                formData.append('receiver_id', targetId);
                formData.append('message', text);
                if (replyId) formData.append('reply_to_id', replyId);
                if (file) formData.append('attachment', file);

                msgInput.value = '';
                fileInput.value = '';
                document.getElementById('fileNameLabel').innerText = '';
                cancelReply();

                try {
                    await fetch('../api/send_message.jsp', { method: 'POST', body: formData });
                    setTimeout(() => loadMessages(true), 300);
                } catch (err) { console.error("Send error", err); }
            };
        }

        window.addEventListener('resize', () => {
            if (window.innerWidth > 992) {
                document.getElementById('staffSidebar').classList.remove('hidden-mobile');
                chatOverlay?.classList.remove('active');
            }
        });
    });

    function setStaffListOpen(open) {
        const staffSidebar = document.getElementById('staffSidebar');
        const chatOverlay = document.getElementById('chat-mobile-overlay');
        const shouldOpen = typeof open === 'boolean' ? open : staffSidebar.classList.contains('hidden-mobile');
        staffSidebar.classList.toggle('hidden-mobile', !shouldOpen);
        if (window.innerWidth <= 992 && chatOverlay) {
            chatOverlay.classList.toggle('active', shouldOpen);
        } else if (chatOverlay) {
            chatOverlay.classList.remove('active');
        }
    }

    function toggleStaffList() {
        setStaffListOpen();
    }

    function filterStaff() {
        let input = document.getElementById('searchStaff').value.toLowerCase();
        let items = document.getElementsByClassName('staff-item');
        for (let item of items) {
            let name = item.innerText.toLowerCase();
            item.style.display = name.includes(input) ? "" : "none";
        }
    }

    function selectStaff(id, name, dept, element) {
        targetId = id;
        lastMessageCount = 0;
        document.querySelectorAll('.staff-item').forEach(el => el.classList.remove('active'));
        element.classList.add('active');
        document.getElementById('noSelection').classList.add('d-none');
        document.getElementById('activeUserInfo').classList.remove('d-none');
        document.getElementById('activeStaffName').innerText = name;
        document.getElementById('activeStaffDept').innerText = dept;
        loadMessages(true);
        if (window.innerWidth <= 992) setStaffListOpen(false);
    }

    async function loadMessages(forceScroll = false) {
        if (targetId === -1) return;
        try {
            const url = "../api/get_messages.jsp?target_id=" + targetId + "&user_id=" + ADMIN_ID + "&t=" + Date.now();
            const res = await fetch(url);
            const messages = await res.json();
            const display = document.getElementById('chatDisplay');

            if (messages.length === lastMessageCount && !forceScroll) return;

            display.innerHTML = '';
            lastMessageCount = messages.length;

            messages.forEach(m => {
                const isMine = String(m.sender_id) === String(ADMIN_ID);
                const bubble = document.createElement('div');
                bubble.id = 'msg-' + m.chat_id;
                bubble.className = "msg-bubble-web " + (isMine ? "msg-sent" : "msg-received");

                let cleanMsg = (m.message || '').replace(/\\n/g, '<br>').replace(/\\"/g, '"');
                let cleanReply = (m.reply_to_text || '').replace(/\\"/g, '"');

                // UPDATED: Added click handler to reply box to scroll to original
                let replyHtml = m.reply_to_id ?
                    '<div class="reply-box-web" onclick="scrollToMsg(' + m.reply_to_id + ')">' +
                        '<div style="font-size: 0.65rem; font-weight: bold; opacity: 0.8;">Reply to:</div>' +
                        '<div class="text-truncate small opacity-75">' + cleanReply + '</div>' +
                    '</div>' : '';

                let actionsHtml = isMine ?
                    '<div class="msg-actions">' +
                        '<i class="fas fa-pen-to-square fa-fw" title="Edit" onclick="openEditModal(' + m.chat_id + ', \'' + (m.message || '').replace(/'/g, "\\'").replace(/\n/g, "\\n") + '\')"></i>' +
                        '<i class="fas fa-trash-can fa-fw" title="Delete" onclick="deleteMsg(' + m.chat_id + ')"></i>' +
                    '</div>' : '';

                let attachHtml = '';
                if (m.attachment_path) {
                    const path = m.attachment_path.startsWith("/") ? ".." + m.attachment_path : "../" + m.attachment_path;
                    attachHtml = /\.(jpg|jpeg|png|gif|webp)$/i.test(path) ?
                        '<div class="mt-2"><img src="' + path + '" class="rounded shadow-sm" style="max-width:100%"></div>' :
                        '<div class="mt-2 small"><a href="' + path + '" class="text-decoration-none" target="_blank"><i class="fas fa-file"></i> Attachment</a></div>';
                }

                bubble.innerHTML = actionsHtml + replyHtml +
                    '<div>' + cleanMsg + '</div>' + attachHtml +
                    '<div class="text-end opacity-50 mt-1" style="font-size: 0.6rem;">' + m.sent_at + '</div>';

                bubble.ondblclick = () => startReply(m.chat_id, cleanMsg);
                display.appendChild(bubble);
            });
            display.scrollTo({ top: display.scrollHeight, behavior: forceScroll ? 'auto' : 'smooth' });
        } catch(e) { console.error("Error loading messages:", e); }
    }

    function openEditModal(id, text) {
        document.getElementById('editChatId').value = id;
        document.getElementById('editMsgText').value = text;
        editModal.show();
    }

    async function saveEdit() {
        const id = document.getElementById('editChatId').value;
        const text = document.getElementById('editMsgText').value.trim();
        try {
            const res = await fetch("../api/update_message.jsp?action=edit&chat_id=" + id + "&message=" + encodeURIComponent(text));
            const data = await res.json();
            if (data.status === "success") { editModal.hide(); loadMessages(true); }
        } catch(e) { console.error("Update error:", e); }
    }

    async function deleteMsg(id) {
        if (confirm("Delete this message?")) {
            try {
                const res = await fetch("../api/update_message.jsp?action=delete&chat_id=" + id);
                const data = await res.json();
                if (data.status === "success") loadMessages(true);
            } catch(e) { console.error("Delete error:", e); }
        }
    }

    // UPDATED: Added a brief highlight effect when scrolling to a message
    function scrollToMsg(id) {
        const el = document.getElementById('msg-' + id);
        if (el) {
            el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            el.classList.add('highlight-msg');
            setTimeout(() => el.classList.remove('highlight-msg'), 2000);
        }
    }

    function startReply(id, text) {
        replyId = id;
        document.getElementById('replyPreview').classList.remove('d-none');
        document.getElementById('replyText').innerText = text.substring(0, 50);
    }

    function cancelReply() {
        replyId = null;
        document.getElementById('replyPreview').classList.add('d-none');
    }

    function updateFileLabel() {
        const file = document.getElementById('fileAttach').files[0];
        document.getElementById('fileNameLabel').innerText = file ? "📎 " + file.name : "";
    }

    setInterval(() => loadMessages(false), 4000);
</script>

</body>
</html>
