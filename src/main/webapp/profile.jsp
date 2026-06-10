<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.studyspace.data.DatabaseManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("LoginServlet");
        return;
    }
    int userId = (int) session.getAttribute("userId");
    DatabaseManager db = new DatabaseManager();
    Connection con = db.getConnection();
    
    String email = "";
    int totalXP = 0;
    int pomoCount = 0;
    int focusMin = 0;
    String joined = "";
    
    try {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            email = rs.getString("email");
            totalXP = rs.getInt("totalXP");
            pomoCount = rs.getInt("pomodoroSessionsCount");
            focusMin = rs.getInt("totalFocusMinutes");
            joined = rs.getString("joinedDate");
        }
        rs.close(); ps.close();
    } catch(Exception e){}
    db.disconnect();
    
    int level = (totalXP / 1000) + 1;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - StudySpace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body data-page="profile">

    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-graduation-cap"></i> STUDYSPACE
        </div>
        <div class="nav flex-column mt-4">
            <a href="index.jsp" class="nav-link"><i class="fa-solid fa-border-all"></i> Dashboard</a>
            <a href="task-board.jsp" class="nav-link"><i class="fa-solid fa-columns"></i> Task Board</a>
            <a href="pomodoro.jsp" class="nav-link"><i class="fa-solid fa-clock"></i> Pomodoro</a>
            <a href="progress.jsp" class="nav-link"><i class="fa-solid fa-chart-line"></i> Progress</a>
            <a href="profile.jsp" class="nav-link active"><i class="fa-regular fa-user"></i> Profile</a>
        </div>
        <div class="position-absolute bottom-0 w-100 p-3" style="border-top: 1px solid var(--border-color);">
            <div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                <a href="LoginServlet?logout=true" style="color: inherit; text-decoration: none;"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </nav>

    <main class="main-content">
        <div class="content-wrapper mt-5">
            <div class="row">
                <div class="col-md-4">
                    <div class="custom-card text-center pb-5">
                        <img src="https://ui-avatars.com/api/?name=<%= session.getAttribute("username") %>&background=4F46E5&color=fff&size=120" class="rounded-circle mb-3 border border-4 border-white shadow-sm" alt="Profile">
                        <h4 class="fw-bold mb-1"><%= session.getAttribute("username") %></h4>
                        <p class="text-muted mb-3"><%= email %></p>
                        <div class="badge bg-warning text-dark px-3 py-2 fs-6 rounded-pill shadow-sm">Level <%= level %></div>
                        <p class="text-muted small mt-3">Bergabung sejak <%= joined %></p>
                    </div>
                </div>
                
                <div class="col-md-8">
                    <div class="custom-card">
                        <h5 class="fw-bold mb-4">STATISTIK AKUN</h5>
                        <div class="row g-4">
                            <div class="col-sm-6">
                                <div class="border rounded p-3 text-center" style="background: var(--bg-body);">
                                    <i class="fa-solid fa-star text-warning fs-1 mb-2"></i>
                                    <h3 class="fw-bold m-0"><%= totalXP %></h3>
                                    <span class="text-muted small">Total XP</span>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="border rounded p-3 text-center" style="background: var(--bg-body);">
                                    <i class="fa-solid fa-clock text-primary fs-1 mb-2"></i>
                                    <h3 class="fw-bold m-0"><%= focusMin %></h3>
                                    <span class="text-muted small">Menit Fokus</span>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="border rounded p-3 text-center" style="background: var(--bg-body);">
                                    <i class="fa-solid fa-stopwatch text-success fs-1 mb-2"></i>
                                    <h3 class="fw-bold m-0"><%= pomoCount %></h3>
                                    <span class="text-muted small">Sesi Pomodoro</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

</body>
</html>
