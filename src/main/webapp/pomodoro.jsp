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
    
    int todaySessions = 0;
    int totalFocus = 0;
    
    try {
        // Simple query to count sessions and duration for the current user
        PreparedStatement ps = con.prepareStatement("SELECT COUNT(sessionId) as sCount, COALESCE(SUM(durationMinutes),0) as sDur FROM pomodoro_sessions WHERE user_id = ? AND completed = TRUE");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            todaySessions = rs.getInt("sCount");
            totalFocus = rs.getInt("sDur");
        }
        rs.close(); ps.close();
    } catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pomodoro - StudySpace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body data-page="pomodoro">

    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-graduation-cap"></i> STUDYSPACE
        </div>
        <div class="nav flex-column mt-4">
            <a href="index.jsp" class="nav-link"><i class="fa-solid fa-border-all"></i> Dashboard</a>
            <a href="task-board.jsp" class="nav-link"><i class="fa-solid fa-columns"></i> Task Board</a>
            <a href="pomodoro.jsp" class="nav-link active"><i class="fa-solid fa-clock"></i> Pomodoro</a>
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
                <img src="https://ui-avatars.com/api/?name=<%= session.getAttribute("username") %>&background=4F46E5&color=fff" alt="User Profile">
            </div>
        </header>

        <div class="content-wrapper">
            <h1 class="page-title mb-4">POMODORO TIMER</h1>

            <div class="row g-4">
                <!-- Stat Card -->
                <div class="col-md-4">
                    <div class="custom-card h-100">
                        <div class="card-title">STATISTIK BELAJAR</div>
                        <ul class="list-unstyled mb-0">
                            <li class="d-flex justify-content-between mb-3 border-bottom pb-2">
                                <span class="text-muted">Total Sesi Fokus:</span>
                                <span class="fw-bold fs-5"><%= todaySessions %></span>
                            </li>
                            <li class="d-flex justify-content-between">
                                <span class="text-muted">Total Menit Fokus:</span>
                                <span class="fw-bold fs-5"><%= totalFocus %> Menit</span>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- Timer Main -->
                <div class="col-md-4">
                    <div class="custom-card text-center d-flex flex-column justify-content-center align-items-center h-100">
                        <div class="badge bg-primary bg-opacity-10 text-primary mb-3 px-3 py-2 rounded-pill">
                            <i class="fa-solid fa-fire me-2"></i>FOKUS (Sesi <%= todaySessions + 1 %>)
                        </div>
                        
                        <div class="pomodoro-circle-large mb-4">
                            25:00
                        </div>

                        <div class="d-flex justify-content-center gap-3">
                            <form action="PomodoroServlet" method="POST" id="pomoForm">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="duration" value="25">
                                <button type="button" class="btn btn-primary px-4 py-2" onclick="startMockTimer(this)">
                                    <i class="fa-solid fa-play me-2"></i>Mulai Sesi Fokus
                                </button>
                                <button type="submit" class="btn btn-outline-success px-4 py-2 d-none" id="btn-save-session">
                                    <i class="fa-solid fa-check me-2"></i>Simpan Sesi
                                </button>
                            </form>
                        </div>
                        <p class="text-muted small mt-3 mb-0">Klik Mulai untuk simulasi timer. Setelah selesai, tombol Simpan Sesi akan muncul.</p>
                    </div>
                </div>

                <!-- Settings -->
                <div class="col-md-4">
                    <div class="custom-card h-100">
                        <div class="card-title">RIWAYAT SESI</div>
                        <ul class="task-mini-list mt-3">
                            <%
                                try {
                                    PreparedStatement psHist = con.prepareStatement("SELECT startTime, durationMinutes FROM pomodoro_sessions WHERE user_id = ? AND completed = TRUE ORDER BY startTime DESC LIMIT 5");
                                    psHist.setInt(1, userId);
                                    ResultSet rsHist = psHist.executeQuery();
                                    boolean hasHist = false;
                                    while(rsHist.next()) {
                                        hasHist = true;
                                        out.print("<li class='task-mini-item d-flex justify-content-between'>");
                                        out.print("<span><i class='fa-solid fa-check-circle text-success me-2'></i>Fokus " + rsHist.getInt("durationMinutes") + " Menit</span>");
                                        out.print("<span class='text-muted small'>" + rsHist.getString("startTime").substring(0, 16) + "</span>");
                                        out.print("</li>");
                                    }
                                    if(!hasHist) out.print("<li class='task-mini-item text-muted'>Belum ada riwayat sesi.</li>");
                                    rsHist.close(); psHist.close();
                                } catch(Exception e){}
                                db.disconnect();
                            %>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function startMockTimer(btn) {
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i>Sedang Fokus...';
            btn.disabled = true;
            // Simulate 3 seconds focus for testing
            setTimeout(() => {
                btn.classList.add('d-none');
                document.getElementById('btn-save-session').classList.remove('d-none');
                document.querySelector('.pomodoro-circle-large').innerHTML = '00:00';
            }, 3000);
        }
    </script>
</body>
</html>
