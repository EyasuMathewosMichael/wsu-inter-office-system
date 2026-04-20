<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login | WSU School of Informatics</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
        }
        .login-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            width: 100%;
            max-width: 420px;
            padding: 2.5rem;
        }
        .brand-icon {
            width: 60px;
            height: 60px;
            background: #0d6efd;
            color: white;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 1.5rem;
        }
        .form-control { padding: 12px; border-radius: 8px; border: 1px solid #e2e8f0; }
        .form-control:focus { box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.15); }
        .btn-login { background: #0d6efd; border: none; padding: 12px; border-radius: 8px; font-weight: 600; transition: all 0.2s; }
        .btn-login:hover { background: #0b5ed7; transform: translateY(-1px); }
        .password-toggle {
            border-left: 0;
            background: #f8fafc;
            color: #64748b;
        }
        .password-toggle:hover,
        .password-toggle:focus {
            background: #f1f5f9;
            color: #0d6efd;
            box-shadow: none;
        }
    </style>
</head>
<body>

<div class="login-card">
    <div class="text-center">
        <div class="brand-icon">
            <i class="fas fa-shield-halved"></i>
        </div>
        <h3 class="fw-bold text-dark mb-1">Admin Portal</h3>
        <p class="text-muted small mb-4">Inter-Office Communication System</p>
    </div>

    <%
        String status = request.getParameter("status");
        String error = request.getParameter("error");

        if ("logged_out".equals(status)) {
    %>
        <div class="alert alert-success d-flex align-items-center small py-2 mb-3" role="alert">
            <i class="fas fa-check-circle me-2"></i>
            <div>Successfully signed out!</div>
        </div>
    <%  }

        if (error != null) {
    %>
        <div class="alert alert-danger d-flex align-items-center small py-2 mb-3" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i>
            <div>
                <%
                    if("unauthorized".equals(error)) out.print("Please login to access the dashboard.");
                    else if("db_fail".equals(error)) out.print("Database connection error.");
                    else out.print("Invalid Admin credentials.");
                %>
            </div>
        </div>
    <%  } %>

    <form action="../api/auth_admin.jsp" method="POST">
        <div class="mb-3">
            <label class="form-label small fw-bold text-secondary">Username</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-end-0 text-muted"><i class="fas fa-user"></i></span>
                <input type="text" name="username" class="form-control border-start-0" placeholder="Enter admin username" required>
            </div>
        </div>

        <div class="mb-4">
            <label class="form-label small fw-bold text-secondary">Password</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-end-0 text-muted"><i class="fas fa-lock"></i></span>
                <input type="password" name="password" id="passwordField" class="form-control border-start-0 border-end-0" placeholder="••••••••" required>
                <button type="button" class="input-group-text password-toggle" id="togglePasswordBtn" aria-label="Show password">
                    <i class="fas fa-eye" id="togglePasswordIcon"></i>
                </button>
            </div>
        </div>

        <button type="submit" class="btn btn-primary btn-login w-100 mb-3 text-white">
            Secure Sign In
        </button>

        <div class="text-center">
            <a href="../index.jsp" class="text-decoration-none small text-muted">
                <i class="fas fa-arrow-left me-1"></i> Return to School Site
            </a>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const passwordField = document.getElementById('passwordField');
    const togglePasswordBtn = document.getElementById('togglePasswordBtn');
    const togglePasswordIcon = document.getElementById('togglePasswordIcon');

    if (passwordField && togglePasswordBtn && togglePasswordIcon) {
        togglePasswordBtn.addEventListener('click', function () {
            const showingPassword = passwordField.type === 'text';
            passwordField.type = showingPassword ? 'password' : 'text';
            togglePasswordIcon.className = showingPassword ? 'fas fa-eye' : 'fas fa-eye-slash';
            togglePasswordBtn.setAttribute('aria-label', showingPassword ? 'Show password' : 'Hide password');
        });
    }
</script>
</body>
</html>
