<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome | WSU School of Informatics</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">

    <style>
        body { font-family: 'Inter', sans-serif; }
        .hero-section {
            background: linear-gradient(rgba(0,0,0,0.7), rgba(0,0,0,0.7)),
                        url('assets/img/campus-bg.jpg') center/cover;
            height: 100vh;
            display: flex;
            align-items: center;
            color: white;
        }
        .mission-box { border-left: 4px solid #0d6efd; padding-left: 20px; }
        .btn-portal { padding: 12px 35px; font-weight: 600; border-radius: 8px; transition: 0.3s; }
        .feature-card { border: none; border-radius: 15px; transition: transform 0.3s; }
        .feature-card:hover { transform: translateY(-10px); }
        .text-primary-gradient {
            background: linear-gradient(45deg, #0d6efd, #00d4ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
    </style>
</head>
<body>

    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="#">
                <i class="fas fa-microchip me-2 text-primary"></i>WSU-SOI
            </a>
            <div class="d-flex align-items-center">
                <span class="text-white-50 small me-3 d-none d-md-inline">Inter-office Communications Portal</span>
                <a href="admin/login.jsp" class="btn btn-primary btn-sm px-4 rounded-pill">Admin Login</a>
            </div>
        </div>
    </nav>

    <section class="hero-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-8">
                    <h1 class="display-3 fw-bold mb-4">Innovating the Future of <br><span class="text-primary-gradient">Information Systems.</span></h1>
                    <div class="mission-box mb-5">
                        <p class="lead text-white-50">Welcome to the WSU School of Informatics Internal Office Communication System (IOCS). We provide seamless integration for CS, IT, and IS departments to collaborate and thrive.</p>
                    </div>
                    <div class="d-flex gap-3">
                        <a href="admin/login.jsp" class="btn btn-primary btn-portal shadow-lg">
                            <i class="fas fa-door-open me-2"></i>Enter Portal
                        </a>
                        <a href="#departments" class="btn btn-outline-light btn-portal">Explore Depts</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section id="departments" class="py-5 bg-light">
        <div class="container py-5">
            <div class="text-center mb-5">
                <h6 class="text-primary fw-bold text-uppercase">Our Core Pillars</h6>
                <h2 class="fw-bold">Excellence in Informatics</h2>
                <p class="text-muted mx-auto" style="max-width: 600px;">Managing information across all disciplines within the School of Informatics at Wolaita Sodo University.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="card h-100 feature-card shadow-sm p-4">
                        <div class="icon-box mb-3 text-primary">
                            <i class="fas fa-code fa-3x"></i>
                        </div>
                        <h5 class="fw-bold">Computer Science</h5>
                        <p class="small text-muted">Advancing software development, AI, and algorithmic problem solving to drive global innovation.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 feature-card shadow-sm p-4">
                        <div class="icon-box mb-3 text-primary">
                            <i class="fas fa-server fa-3x"></i>
                        </div>
                        <h5 class="fw-bold">Information Technology</h5>
                        <p class="small text-muted">Focusing on infrastructure, cybersecurity, and networking to ensure robust digital environments.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 feature-card shadow-sm p-4">
                        <div class="icon-box mb-3 text-primary">
                            <i class="fas fa-database fa-3x"></i>
                        </div>
                        <h5 class="fw-bold">Information Systems</h5>
                        <p class="small text-muted">Bridging the gap between business processes and technical solutions through data management.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer class="bg-dark text-white-50 py-5 border-top border-secondary">
        <div class="container text-center">
            <p class="mb-2">Wolaita Sodo University | School of Informatics</p>
            <div class="d-flex justify-content-center gap-4 mb-3">
                <a href="https://m.facebook.com/Wolaita-Sodo-University-246568056057804" class="text-white-50" target="_blank" rel="noopener noreferrer" aria-label="Wolaita Sodo University Facebook">
                    <i class="fab fa-facebook-f"></i>
                </a>
                <a href="https://t.me/WolaitaSUniversity" class="text-white-50" target="_blank" rel="noopener noreferrer" aria-label="Wolaita Sodo University Telegram">
                    <i class="fab fa-telegram-plane"></i>
                </a>
            </div>
            <p class="mb-0 x-small">© 2026 Internal Office Communication System | All Rights Reserved</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
