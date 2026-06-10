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
    String username = (String) session.getAttribute("username");

    DatabaseManager db = new DatabaseManager();
    Connection con = db.getConnection();
    
    // Get User Data
    int totalXP = 0;
    try {
        PreparedStatement ps = con.prepareStatement("SELECT totalXP FROM users WHERE id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) totalXP = rs.getInt("totalXP");
        rs.close();
        ps.close();
    } catch(Exception e) {}
    
    int level = (totalXP / 1000) + 1;
    int progressPercent = (totalXP % 1000) / 10;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StudySpace - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body data-page="dashboard">

    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-graduation-cap"></i> STUDYSPACE
        </div>
        <div class="nav flex-column mt-4">
            <a href="index.jsp" class="nav-link active"><i class="fa-solid fa-border-all"></i> Dashboard</a>
            <a href="task-board.jsp" class="nav-link"><i class="fa-solid fa-columns"></i> Task Board</a>
            <a href="pomodoro.jsp" class="nav-link"><i class="fa-solid fa-clock"></i> Pomodoro</a>
            <a href="progress.jsp" class="nav-link"><i class="fa-solid fa-chart-line"></i> Progress</a>
            <a href="profile.jsp" class="nav-link"><i class="fa-regular fa-user"></i> Profile</a>
        </div>
        <div class="position-absolute bottom-0 w-100 p-3" style="border-top: 1px solid var(--border-color);">
            <div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                <a href="LoginServlet?logout=true" style="color: inherit; text-decoration: none;"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
        <header class="topbar">
            <div class="user-profile">
                <img src="https://ui-avatars.com/api/?name=<%= username %>&background=4F46E5&color=fff" alt="User Profile">
            </div>
        </header>

        <div class="content-wrapper">
            <h1 class="page-title">DASHBOARD</h1>
            <p class="page-subtitle">Halo <%= username %>! Siap untuk belajar hari ini?</p>

            <div class="row g-4 mb-4">
                <!-- Progres Belajar -->
                <div class="col-md-4">
                    <div class="custom-card">
                        <div class="card-title">
                            PROGRES LEVEL <%= level %>
                            <i class="fa-solid fa-chart-line text-muted"></i>
                        </div>
                        <div class="d-flex justify-content-between align-items-end mb-2">
                            <span class="text-muted">XP: <%= totalXP %></span>
                            <span class="progress-percentage"><%= progressPercent %>%</span>
                        </div>
                        <div class="progress">
                            <div class="progress-bar" style="width: <%= progressPercent %>%"></div>
                        </div>
                    </div>
                </div>

                <!-- Tugas Terdekat -->
                <div class="col-md-4">
                    <div class="custom-card">
                        <div class="card-title">
                            TUGAS TERDEKAT
                            <i class="fa-regular fa-calendar text-muted"></i>
                        </div>
                        <ul class="task-mini-list">
                            <%
                                try {
                                    PreparedStatement psT = con.prepareStatement("SELECT title, deadline, status FROM tasks WHERE user_id = ? AND status != 'DONE' ORDER BY deadline ASC LIMIT 3");
                                    psT.setInt(1, userId);
                                    ResultSet rsT = psT.executeQuery();
                                    boolean hasTasks = false;
                                    while(rsT.next()) {
                                        hasTasks = true;
                                        out.print("<li class='task-mini-item'>");
                                        out.print("<span>" + rsT.getString("title") + "</span>");
                                        out.print("<span class='badge bg-warning text-dark'>" + rsT.getString("status") + "</span>");
                                        out.print("</li>");
                                    }
                                    if(!hasTasks) out.print("<li class='task-mini-item text-muted'>Tidak ada tugas terdekat</li>");
                                    rsT.close(); psT.close();
                                } catch(Exception e){}
                            %>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Daftar Semua Tugas -->
            <div class="custom-card">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="m-0" style="font-weight: 700; letter-spacing: 1px;">DAFTAR TUGAS</h5>
                    <a href="task-board.jsp" class="btn btn-primary"><i class="fa-solid fa-arrow-right me-2"></i> Lihat Task Board</a>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-custom table-borderless">
                        <thead>
                            <tr>
                                <th>Nama Tugas</th>
                                <th>Mata Kuliah</th>
                                <th>Deadline</th>
                                <th>Kesulitan</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    PreparedStatement psList = con.prepareStatement("SELECT t.title, s.subjectName, t.deadline, t.difficultyLevel, t.status FROM tasks t LEFT JOIN subjects s ON t.subjectCode = s.subjectCode WHERE t.user_id = ? ORDER BY t.deadline ASC LIMIT 10");
                                    psList.setInt(1, userId);
                                    ResultSet rsList = psList.executeQuery();
                                    while(rsList.next()) {
                                        out.print("<tr>");
                                        out.print("<td>" + rsList.getString("title") + "</td>");
                                        out.print("<td>" + (rsList.getString("subjectName")!=null?rsList.getString("subjectName"):"-") + "</td>");
                                        out.print("<td>" + rsList.getString("deadline") + "</td>");
                                        out.print("<td>Level " + rsList.getInt("difficultyLevel") + "</td>");
                                        String badge = rsList.getString("status").equals("DONE") ? "bg-success" : (rsList.getString("status").equals("IN_PROGRESS") ? "bg-primary" : "bg-secondary");
                                        out.print("<td><span class='badge " + badge + "'>" + rsList.getString("status") + "</span></td>");
                                        out.print("</tr>");
                                    }
                                    rsList.close(); psList.close();
                                } catch(Exception e){}
                                db.disconnect();
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

</body>
</html>
