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
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Progress - StudySpace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body data-page="progress">

    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-graduation-cap"></i> STUDYSPACE
        </div>
        <div class="nav flex-column mt-4">
            <a href="index.jsp" class="nav-link"><i class="fa-solid fa-border-all"></i> Dashboard</a>
            <a href="task-board.jsp" class="nav-link"><i class="fa-solid fa-columns"></i> Task Board</a>
            <a href="pomodoro.jsp" class="nav-link"><i class="fa-solid fa-clock"></i> Pomodoro</a>
            <a href="progress.jsp" class="nav-link active"><i class="fa-solid fa-chart-line"></i> Progress</a>
            <a href="profile.jsp" class="nav-link"><i class="fa-regular fa-user"></i> Profile</a>
        </div>
        <div class="position-absolute bottom-0 w-100 p-3" style="border-top: 1px solid var(--border-color);">
            <div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                <a href="LoginServlet?logout=true" style="color: inherit; text-decoration: none;"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a>
            </div>
        </div>
    </nav>

    <main class="main-content">
        <header class="topbar">
            <div class="user-profile">
                <img src="https://ui-avatars.com/api/?name=<%= session.getAttribute("username") %>&background=4F46E5&color=fff" alt="User Profile">
            </div>
        </header>

        <div class="content-wrapper">
            <h1 class="page-title mb-4">PROGRES BELAJAR</h1>

            <div class="row g-4 mb-4">
                <%
                    try {
                        String sql = "SELECT s.subjectCode, s.subjectName, " +
                                     "COUNT(t.activityId) as totalTasks, " +
                                     "SUM(CASE WHEN t.status = 'DONE' THEN 1 ELSE 0 END) as completedTasks " +
                                     "FROM subjects s LEFT JOIN tasks t ON s.subjectCode = t.subjectCode " +
                                     "WHERE s.user_id = ? GROUP BY s.subjectCode, s.subjectName";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ps.setInt(1, userId);
                        ResultSet rs = ps.executeQuery();
                        while(rs.next()) {
                            int total = rs.getInt("totalTasks");
                            int comp = rs.getInt("completedTasks");
                            int pct = total > 0 ? (comp * 100 / total) : 0;
                            
                            out.print("<div class='col-md-4'>");
                            out.print("<div class='custom-card'>");
                            out.print("<div class='card-title'>" + rs.getString("subjectName") + "</div>");
                            out.print("<div class='d-flex justify-content-between align-items-end mb-2'>");
                            out.print("<span class='text-muted'>" + comp + " / " + total + " Tugas Selesai</span>");
                            out.print("<span class='progress-percentage'>" + pct + "%</span>");
                            out.print("</div>");
                            out.print("<div class='progress'>");
                            out.print("<div class='progress-bar bg-" + (pct==100?"success":"primary") + "' style='width: " + pct + "%'></div>");
                            out.print("</div></div></div>");
                        }
                        rs.close(); ps.close();
                    } catch(Exception e){}
                    db.disconnect();
                %>
            </div>
        </div>
    </main>

</body>
</html>
