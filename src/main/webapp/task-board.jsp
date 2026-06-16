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
    <title>Task Board - StudySpace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body data-page="task-board">
    <nav class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-graduation-cap"></i> STUDYSPACE
        </div>
        <div class="nav flex-column mt-4">
            <a href="index.jsp" class="nav-link"><i class="fa-solid fa-border-all"></i> Dashboard</a>
            <a href="task-board.jsp" class="nav-link active"><i class="fa-solid fa-columns"></i> Task Board</a>
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

    <main class="main-content">
        <header class="topbar">
            <div class="user-profile">
                <img src="https://ui-avatars.com/api/?name=<%= session.getAttribute("username") %>&background=4F46E5&color=fff" alt="User Profile">
            </div>
        </header>

        <div class="content-wrapper">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="page-title mb-1">TASK BOARD</h1>
                    <p class="text-muted" style="font-size: 0.9rem;">Kelola semua tugasmu secara detail di sini.</p>
                </div>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addTaskModal"><i class="fa-solid fa-plus me-2"></i> Tambah Tugas Baru</button>
            </div>

            <div class="kanban-row">
                <!-- BELUM MULAI (TODO) -->
                <div class="kanban-col">
                    <div class="board-column">
                        <div class="board-header">BELUM MULAI</div>
                        <div>
                            <%
                                try {
                                    PreparedStatement ps = con.prepareStatement("SELECT t.*, s.subjectName FROM tasks t LEFT JOIN subjects s ON t.subjectCode = s.subjectCode WHERE t.user_id = ? AND t.status = 'TODO' ORDER BY t.deadline ASC");
                                    ps.setInt(1, userId);
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        out.print("<div class='kanban-card'>");
                                        out.print("<div class='fw-bold mb-1'>" + rs.getString("title") + "</div>");
                                        out.print("<div class='text-muted small mb-2'>" + (rs.getString("subjectName")!=null?rs.getString("subjectName"):"-") + "</div>");
                                        out.print("<div class='d-flex justify-content-between align-items-center'>");
                                        out.print("<span class='badge bg-light text-dark border'><i class='fa-regular fa-clock me-1'></i>" + rs.getString("deadline").substring(0, 10) + "</span>");
                                        out.print("<div>");
                                        out.print("<a href='TaskServlet?action=updateStatus&id=" + rs.getString("activityId") + "&status=IN_PROGRESS' class='btn btn-sm btn-outline-primary py-0 px-1' title='Mulai Kerjakan'><i class='fa-solid fa-play'></i></a> ");
                                        out.print("<a href='TaskServlet?action=delete&id=" + rs.getString("activityId") + "' class='btn btn-sm btn-outline-danger py-0 px-1' title='Hapus'><i class='fa-solid fa-trash'></i></a>");
                                        out.print("</div></div></div>");
                                    }
                                    rs.close(); ps.close();
                                } catch(Exception e){}
                            %>
                        </div>
                    </div>
                </div>

                <!-- SEDANG DIKERJAKAN (IN_PROGRESS) -->
                <div class="kanban-col">
                    <div class="board-column">
                        <div class="board-header">SEDANG DIKERJAKAN</div>
                        <div>
                            <%
                                try {
                                    PreparedStatement ps = con.prepareStatement("SELECT t.*, s.subjectName FROM tasks t LEFT JOIN subjects s ON t.subjectCode = s.subjectCode WHERE t.user_id = ? AND t.status = 'IN_PROGRESS' ORDER BY t.deadline ASC");
                                    ps.setInt(1, userId);
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        out.print("<div class='kanban-card border-primary border-start border-3'>");
                                        out.print("<div class='fw-bold mb-1'>" + rs.getString("title") + "</div>");
                                        out.print("<div class='text-muted small mb-2'>" + (rs.getString("subjectName")!=null?rs.getString("subjectName"):"-") + "</div>");
                                        out.print("<div class='d-flex justify-content-between align-items-center'>");
                                        out.print("<span class='badge bg-light text-primary border'><i class='fa-regular fa-clock me-1'></i>" + rs.getString("deadline").substring(0, 10) + "</span>");
                                        out.print("<div>");
                                        out.print("<a href='TaskServlet?action=updateStatus&id=" + rs.getString("activityId") + "&status=IN_REVIEW' class='btn btn-sm btn-outline-warning py-0 px-1' title='Ke Review'><i class='fa-solid fa-forward'></i></a> ");
                                        out.print("<a href='TaskServlet?action=complete&id=" + rs.getString("activityId") + "' class='btn btn-sm btn-success py-0 px-1' title='Selesai'><i class='fa-solid fa-check'></i></a>");
                                        out.print("</div></div></div>");
                                    }
                                    rs.close(); ps.close();
                                } catch(Exception e){}
                            %>
                        </div>
                    </div>
                </div>

                <!-- DALAM PENINJAUAN (IN_REVIEW) -->
                <div class="kanban-col">
                    <div class="board-column">
                        <div class="board-header">DALAM PENINJAUAN</div>
                        <div>
                            <%
                                try {
                                    PreparedStatement ps = con.prepareStatement("SELECT t.*, s.subjectName FROM tasks t LEFT JOIN subjects s ON t.subjectCode = s.subjectCode WHERE t.user_id = ? AND t.status = 'IN_REVIEW' ORDER BY t.deadline ASC");
                                    ps.setInt(1, userId);
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        out.print("<div class='kanban-card border-warning border-start border-3'>");
                                        out.print("<div class='fw-bold mb-1'>" + rs.getString("title") + "</div>");
                                        out.print("<div class='text-muted small mb-2'>" + (rs.getString("subjectName")!=null?rs.getString("subjectName"):"-") + "</div>");
                                        out.print("<div class='d-flex justify-content-between align-items-center'>");
                                        out.print("<span class='badge bg-light text-warning border'><i class='fa-regular fa-clock me-1'></i>" + rs.getString("deadline").substring(0, 10) + "</span>");
                                        out.print("<div>");
                                        out.print("<a href='TaskServlet?action=updateStatus&id=" + rs.getString("activityId") + "&status=IN_PROGRESS' class='btn btn-sm btn-outline-secondary py-0 px-1' title='Kembali'><i class='fa-solid fa-backward'></i></a> ");
                                        out.print("<a href='TaskServlet?action=complete&id=" + rs.getString("activityId") + "' class='btn btn-sm btn-success py-0 px-1' title='Selesai'><i class='fa-solid fa-check'></i></a>");
                                        out.print("</div></div></div>");
                                    }
                                    rs.close(); ps.close();
                                } catch(Exception e){}
                            %>
                        </div>
                    </div>
                </div>

                <!-- SELESAI (DONE) -->
                <div class="kanban-col">
                    <div class="board-column">
                        <div class="board-header">SELESAI</div>
                        <div>
                            <%
                                try {
                                    PreparedStatement ps = con.prepareStatement("SELECT t.*, s.subjectName FROM tasks t LEFT JOIN subjects s ON t.subjectCode = s.subjectCode WHERE t.user_id = ? AND t.status = 'DONE' ORDER BY t.deadline DESC LIMIT 10");
                                    ps.setInt(1, userId);
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        out.print("<div class='kanban-card border-success border-start border-3' style='opacity:0.7'>");
                                        out.print("<div class='fw-bold mb-1 text-decoration-line-through'>" + rs.getString("title") + "</div>");
                                        out.print("<div class='text-muted small mb-2'>" + (rs.getString("subjectName")!=null?rs.getString("subjectName"):"-") + "</div>");
                                        out.print("<div class='d-flex justify-content-between align-items-center'>");
                                        out.print("<span class='badge bg-light text-success border'><i class='fa-solid fa-check me-1'></i>Selesai</span>");
                                        out.print("<a href='TaskServlet?action=delete&id=" + rs.getString("activityId") + "' class='btn btn-sm btn-outline-danger py-0 px-1' title='Hapus'><i class='fa-solid fa-trash'></i></a>");
                                        out.print("</div></div>");
                                    }
                                    rs.close(); ps.close();
                                } catch(Exception e){}
                            %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Add Task Modal -->
    <div class="modal fade" id="addTaskModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Tambah Tugas Baru</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="TaskServlet" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label text-muted">Nama Tugas</label>
                            <input type="text" class="form-control" name="title" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted">Tipe Tugas</label>
                            <select class="form-select" name="type">
                                <option value="ASSIGNMENT">Tugas/Assignment</option>
                                <option value="EXAM">Ujian/Exam</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <label class="form-label text-muted m-0">Mata Kuliah</label>
                                <button type="button" class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 0.8rem;" data-bs-toggle="modal" data-bs-target="#addSubjectModal"><i class="fa-solid fa-plus"></i> Tambah Baru</button>
                            </div>
                            <select class="form-select" name="subjectCode">
                                <option value="">-- Tanpa Mata Kuliah --</option>
                                <%
                                    try {
                                        PreparedStatement ps = con.prepareStatement("SELECT subjectCode, subjectName FROM subjects WHERE user_id = ?");
                                        ps.setInt(1, userId);
                                        ResultSet rs = ps.executeQuery();
                                        while(rs.next()) {
                                            out.print("<option value='" + rs.getString("subjectCode") + "'>" + rs.getString("subjectName") + "</option>");
                                        }
                                        rs.close(); ps.close();
                                    } catch(Exception e){}
                                    db.disconnect();
                                %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted">Deadline</label>
                            <input type="date" class="form-control" name="deadline" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted d-flex justify-content-between">
                                <span>Tingkat Kesulitan (1-5)</span>
                                <span id="difficultyValue" class="badge bg-primary rounded-pill" style="font-size: 0.85rem;">3</span>
                            </label>
                            <input type="range" class="form-range" name="difficultyLevel" min="1" max="5" value="3" oninput="document.getElementById('difficultyValue').innerText = this.value">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">Tambah Tugas</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Add Subject Modal -->
    <div class="modal fade" id="addSubjectModal" tabindex="-1">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Tambah Mata Kuliah</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="SubjectServlet" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label text-muted">Nama Mata Kuliah</label>
                            <input type="text" class="form-control" name="subjectName" required placeholder="Contoh: Algoritma">
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted">Kode MK (Opsional)</label>
                            <input type="text" class="form-control" name="subjectCode" placeholder="Contoh: IF101">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">Simpan</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
