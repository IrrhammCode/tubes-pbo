<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.studyspace.data.DatabaseManager"%>
<%@page import="com.studyspace.model.*"%>
<%@page import="com.studyspace.controller.ReminderManager"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.*"%>
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

            <!-- Daftar Tugas (Sorted by Priority using ReminderManager + PriorityQueue) -->
            <div class="custom-card">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="m-0" style="font-weight: 700; letter-spacing: 1px;">DAFTAR TUGAS <span class="badge bg-primary bg-opacity-10 text-primary ms-2" style="font-size:0.7rem;">Diurutkan berdasarkan Prioritas</span></h5>
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
                                <th>Prioritas</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                // === OOP: Use ReminderManager (PriorityQueue<Task>) for sorting ===
                                ReminderManager reminderManager = new ReminderManager();
                                java.util.Map<String, String> taskSubjectMap = new java.util.HashMap<>();
                                
                                try {
                                    PreparedStatement psList = con.prepareStatement(
                                        "SELECT t.activityId, t.title, t.taskType, t.deadline, t.difficultyLevel, t.status, t.isCompleted, t.attachmentLink, t.syllabusList, s.subjectName " +
                                        "FROM tasks t LEFT JOIN subjects s ON t.subjectCode = s.subjectCode WHERE t.user_id = ? ORDER BY t.deadline ASC LIMIT 15");
                                    psList.setInt(1, userId);
                                    ResultSet rsList = psList.executeQuery();
                                    
                                    while(rsList.next()) {
                                        String tId = rsList.getString("activityId");
                                        String tTitle = rsList.getString("title");
                                        String tType = rsList.getString("taskType");
                                        String tDeadlineStr = rsList.getString("deadline");
                                        int tDiff = rsList.getInt("difficultyLevel");
                                        String tStatus = rsList.getString("status");
                                        boolean tCompleted = rsList.getBoolean("isCompleted");
                                        String subName = rsList.getString("subjectName");
                                        
                                        // Parse deadline
                                        LocalDateTime tDeadline = LocalDateTime.now().plusDays(7);
                                        try { tDeadline = LocalDateTime.parse(tDeadlineStr.replace(" ", "T")); } catch(Exception ex) {}
                                        
                                        // Polymorphism: create correct subclass
                                        Task task;
                                        if ("EXAM".equals(tType)) {
                                            String sylStr = rsList.getString("syllabusList");
                                            List<String> sylList = sylStr != null ? Arrays.asList(sylStr.split(",")) : new ArrayList<>();
                                            task = new ExamTask(tId, tTitle, tDeadline, tDiff, sylList);
                                        } else {
                                            String attLink = rsList.getString("attachmentLink");
                                            task = new AssignmentTask(tId, tTitle, tDeadline, tDiff, attLink != null ? attLink : "");
                                        }
                                        task.setStatus(tStatus);
                                        task.setCompleted(tCompleted);
                                        
                                        // Add to PriorityQueue via ReminderManager
                                        reminderManager.addTaskToQueue(task);
                                        taskSubjectMap.put(tId, subName != null ? subName : "-");
                                    }
                                    rsList.close(); psList.close();
                                } catch(Exception e){}
                                
                                // Get tasks sorted by priority score (highest first)
                                List<Task> sortedTasks = reminderManager.getSortedTasks();
                                
                                // Also add completed tasks at the end
                                List<Task> allCompleted = new ArrayList<>();
                                try {
                                    PreparedStatement psDone = con.prepareStatement(
                                        "SELECT t.activityId, t.title, t.taskType, t.deadline, t.difficultyLevel, t.status, s.subjectName " +
                                        "FROM tasks t LEFT JOIN subjects s ON t.subjectCode = s.subjectCode WHERE t.user_id = ? AND t.status = 'DONE' ORDER BY t.deadline DESC LIMIT 5");
                                    psDone.setInt(1, userId);
                                    ResultSet rsDone = psDone.executeQuery();
                                    while(rsDone.next()) {
                                        String tId = rsDone.getString("activityId");
                                        taskSubjectMap.put(tId, rsDone.getString("subjectName") != null ? rsDone.getString("subjectName") : "-");
                                        LocalDateTime dl = LocalDateTime.now();
                                        try { dl = LocalDateTime.parse(rsDone.getString("deadline").replace(" ", "T")); } catch(Exception ex) {}
                                        Task doneTask = new AssignmentTask(tId, rsDone.getString("title"), dl, rsDone.getInt("difficultyLevel"), "");
                                        doneTask.setCompleted(true); doneTask.setStatus("DONE");
                                        allCompleted.add(doneTask);
                                    }
                                    rsDone.close(); psDone.close();
                                } catch(Exception e){}
                                
                                db.disconnect();
                                
                                // Render sorted active tasks
                                for (Task t : sortedTasks) {
                                    double score = t.calculatePriorityScore();
                                    String scoreColor = score > 50 ? "danger" : (score > 20 ? "warning" : "success");
                                    String badge = t.getStatus().equals("IN_PROGRESS") ? "bg-primary" : "bg-secondary";
                                    out.print("<tr>");
                                    out.print("<td>" + t.getTitle() + "</td>");
                                    out.print("<td>" + taskSubjectMap.getOrDefault(t.getActivityId(), "-") + "</td>");
                                    out.print("<td>" + t.getDeadline().toLocalDate() + "</td>");
                                    out.print("<td>Level " + t.getDifficultyLevel() + "</td>");
                                    out.print("<td><span class='badge bg-" + scoreColor + "'>" + String.format("%.1f", score) + "</span></td>");
                                    out.print("<td><span class='badge " + badge + "'>" + t.getStatus() + "</span></td>");
                                    out.print("</tr>");
                                }
                                
                                // Render completed tasks
                                for (Task t : allCompleted) {
                                    out.print("<tr style='opacity:0.5'>");
                                    out.print("<td class='text-decoration-line-through'>" + t.getTitle() + "</td>");
                                    out.print("<td>" + taskSubjectMap.getOrDefault(t.getActivityId(), "-") + "</td>");
                                    out.print("<td>" + t.getDeadline().toLocalDate() + "</td>");
                                    out.print("<td>Level " + t.getDifficultyLevel() + "</td>");
                                    out.print("<td><span class='badge bg-secondary'>-</span></td>");
                                    out.print("<td><span class='badge bg-success'>DONE</span></td>");
                                    out.print("</tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

</body>
</html>
