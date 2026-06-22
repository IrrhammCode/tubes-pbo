<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.studyspace.data.DatabaseManager"%>
<%@page import="com.studyspace.model.*"%>
<%@page import="com.studyspace.controller.ProgressTracker"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("LoginServlet");
        return;
    }
    int userId = (int) session.getAttribute("userId");
    DatabaseManager db = new DatabaseManager();
    Connection con = db.getConnection();
    
    // === OOP: Build Subject objects with Task lists, then use ProgressTracker ===
    ProgressTracker tracker = new ProgressTracker();
    List<Subject> subjectList = new ArrayList<>();
    
    try {
        // Load subjects
        PreparedStatement psSub = con.prepareStatement("SELECT subjectCode, subjectName FROM subjects WHERE user_id = ?");
        psSub.setInt(1, userId);
        ResultSet rsSub = psSub.executeQuery();
        while (rsSub.next()) {
            Subject subj = new Subject(rsSub.getString("subjectCode"), rsSub.getString("subjectName"));
            subjectList.add(subj);
        }
        rsSub.close(); psSub.close();
        
        // Load tasks and assign to subjects (Aggregation)
        for (Subject subj : subjectList) {
            PreparedStatement psTask = con.prepareStatement(
                "SELECT activityId, title, taskType, deadline, difficultyLevel, isCompleted, status FROM tasks WHERE subjectCode = ? AND user_id = ?");
            psTask.setString(1, subj.getSubjectCode());
            psTask.setInt(2, userId);
            ResultSet rsTask = psTask.executeQuery();
            while (rsTask.next()) {
                LocalDateTime dl = LocalDateTime.now().plusDays(7);
                try { dl = LocalDateTime.parse(rsTask.getString("deadline").replace(" ", "T")); } catch(Exception ex) {}
                
                // Polymorphism
                Task task;
                if ("EXAM".equals(rsTask.getString("taskType"))) {
                    task = new ExamTask(rsTask.getString("activityId"), rsTask.getString("title"), dl, rsTask.getInt("difficultyLevel"), new ArrayList<>());
                } else {
                    task = new AssignmentTask(rsTask.getString("activityId"), rsTask.getString("title"), dl, rsTask.getInt("difficultyLevel"), "");
                }
                task.setCompleted(rsTask.getBoolean("isCompleted"));
                task.setStatus(rsTask.getString("status"));
                
                subj.addTask(task); // Aggregation
            }
            rsTask.close(); psTask.close();
        }
    } catch(Exception e) { e.printStackTrace(); }
    db.disconnect();
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
            <h1 class="page-title mb-4">PROGRES BELAJAR <span class="badge bg-primary bg-opacity-10 text-primary ms-2" style="font-size:0.6rem;">Menggunakan ProgressTracker</span></h1>

            <div class="row g-4 mb-4">
                <%
                    // === OOP: Use ProgressTracker.getSubjectProgressData() ===
                    for (Subject subj : subjectList) {
                        Map<String, Object> data = tracker.getSubjectProgressData(subj);
                        long pct = (long) data.get("completionPercentage");
                        int total = (int) data.get("totalTasks");
                        long comp = (long) data.get("completedTasks");
                        
                        out.print("<div class='col-md-4'>");
                        out.print("<div class='custom-card'>");
                        out.print("<div class='card-title'>" + data.get("subjectName") + "</div>");
                        out.print("<div class='d-flex justify-content-between align-items-end mb-2'>");
                        out.print("<span class='text-muted'>" + comp + " / " + total + " Tugas Selesai</span>");
                        out.print("<span class='progress-percentage'>" + pct + "%</span>");
                        out.print("</div>");
                        out.print("<div class='progress'>");
                        out.print("<div class='progress-bar bg-" + (pct==100?"success":"primary") + "' style='width: " + pct + "%'></div>");
                        out.print("</div></div></div>");
                    }
                    
                    if (subjectList.isEmpty()) {
                        out.print("<div class='col-12'><div class='custom-card text-center text-muted py-5'>Belum ada mata kuliah. Silakan tambahkan di Task Board.</div></div>");
                    }
                %>
            </div>
        </div>
    </main>

</body>
</html>
