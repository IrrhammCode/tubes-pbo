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
                        <div class="badge bg-primary bg-opacity-10 text-primary mb-3 px-3 py-2 rounded-pill" id="badge-status">
                            <i class="fa-solid fa-fire me-2"></i>FOKUS (Siklus 1/4)
                        </div>
                        
                        <div class="pomodoro-circle-large mb-4">
                            25:00
                        </div>

                        <div class="d-flex justify-content-center gap-2 flex-wrap">
                            <button type="button" class="btn btn-primary px-4 py-2" id="btn-start" onclick="onStartClick()">
                                <i class="fa-solid fa-play me-2"></i>Mulai
                            </button>
                            <button type="button" class="btn btn-secondary px-4 py-2 d-none" id="btn-skip-break" onclick="skipBreak()">
                                <i class="fa-solid fa-forward-step me-2"></i>Lewati Istirahat
                            </button>
                            <button type="button" class="btn btn-danger px-4 py-2 d-none" id="btn-reset" onclick="resetTimer()">
                                <i class="fa-solid fa-arrow-rotate-left me-2"></i>Reset
                            </button>
                            <button type="button" class="btn btn-warning px-4 py-2 d-none" id="btn-finish" onclick="finishEarly()">
                                <i class="fa-solid fa-stop me-2"></i>Selesai Awal
                            </button>
                            
                            <form action="PomodoroServlet" method="POST" id="pomoForm" class="d-none">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="duration" value="25" id="pomo-duration">
                                <button type="submit" class="btn btn-success px-4 py-2" id="btn-save-session">
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
                        <div class="card-title d-flex justify-content-between align-items-center">
                            <span>RIWAYAT SESI</span>
                            <form action="PomodoroServlet" method="POST" style="margin: 0;">
                                <input type="hidden" name="action" value="resetAll">
                                <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2" title="Hapus Semua Riwayat" onclick="return confirm('Yakin ingin mereset semua riwayat sesi pomodoro?')">
                                    <i class="fa-solid fa-trash"></i> Reset Semua
                                </button>
                            </form>
                        </div>
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
        let timerInterval;
        let totalSeconds = 25 * 60;
        let isRunning = false;
        
        let currentCycle = 1;
        let isBreak = false;
        let focusMinutesAccumulated = 0;
        let targetEndTime = 0;
        
        const display = document.querySelector('.pomodoro-circle-large');
        const badgeLabel = document.getElementById('badge-status');
        const btnStart = document.getElementById('btn-start');
        const btnReset = document.getElementById('btn-reset');
        const btnFinish = document.getElementById('btn-finish');
        const btnSkipBreak = document.getElementById('btn-skip-break');
        const formSave = document.getElementById('pomoForm');

        function saveState() {
            localStorage.setItem('pomo_isRunning', isRunning);
            localStorage.setItem('pomo_endTime', targetEndTime);
            localStorage.setItem('pomo_currentCycle', currentCycle);
            localStorage.setItem('pomo_isBreak', isBreak);
            localStorage.setItem('pomo_focusAccumulated', focusMinutesAccumulated);
            localStorage.setItem('pomo_totalSeconds', totalSeconds);
        }

        function clearState() {
            localStorage.removeItem('pomo_isRunning');
            localStorage.removeItem('pomo_endTime');
            localStorage.removeItem('pomo_currentCycle');
            localStorage.removeItem('pomo_isBreak');
            localStorage.removeItem('pomo_focusAccumulated');
            localStorage.removeItem('pomo_totalSeconds');
        }

        function loadState() {
            const savedIsRunning = localStorage.getItem('pomo_isRunning');
            if (savedIsRunning !== null) {
                isRunning = savedIsRunning === 'true';
                currentCycle = parseInt(localStorage.getItem('pomo_currentCycle')) || 1;
                isBreak = localStorage.getItem('pomo_isBreak') === 'true';
                focusMinutesAccumulated = parseInt(localStorage.getItem('pomo_focusAccumulated')) || 0;
                
                if (isRunning) {
                    targetEndTime = parseInt(localStorage.getItem('pomo_endTime'));
                    let remaining = Math.round((targetEndTime - Date.now()) / 1000);
                    
                    if (remaining <= 0) {
                        // Time elapsed while away
                        totalSeconds = 0;
                        handlePhaseComplete(true); 
                    } else {
                        totalSeconds = remaining;
                        btnStart.classList.add('d-none');
                        btnReset.classList.remove('d-none');
                        btnFinish.classList.remove('d-none');
                        if (isBreak) btnSkipBreak.classList.remove('d-none');
                        updateBadge();
                        updateDisplay();
                        
                        timerInterval = setInterval(tick, 1000);
                    }
                } else {
                    totalSeconds = parseInt(localStorage.getItem('pomo_totalSeconds')) || (25 * 60);
                    updateBadge();
                    updateDisplay();
                }
            } else {
                updateBadge();
                updateDisplay();
            }
        }

        function updateDisplay() {
            let m = Math.floor(totalSeconds / 60);
            let s = totalSeconds % 60;
            display.innerHTML = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
        }

        function updateBadge() {
            if (isBreak) {
                badgeLabel.className = 'badge bg-success bg-opacity-10 text-success mb-3 px-3 py-2 rounded-pill';
                badgeLabel.innerHTML = '<i class="fa-solid fa-mug-hot me-2"></i>ISTIRAHAT (Siklus ' + currentCycle + '/4)';
            } else {
                badgeLabel.className = 'badge bg-primary bg-opacity-10 text-primary mb-3 px-3 py-2 rounded-pill';
                badgeLabel.innerHTML = '<i class="fa-solid fa-fire me-2"></i>FOKUS (Siklus ' + currentCycle + '/4)';
            }
        }

        function speak(text) {
            if ('speechSynthesis' in window) {
                let msg = new SpeechSynthesisUtterance(text);
                msg.lang = 'en-US';
                window.speechSynthesis.speak(msg);
            }
        }

        function onStartClick() {
            if (!isRunning && totalSeconds === 25 * 60 && currentCycle === 1 && !isBreak) {
                speak("Timer started. Focus session 1");
            }
            startTimer();
        }

        function startTimer() {
            if (isRunning) return;
            isRunning = true;
            targetEndTime = Date.now() + (totalSeconds * 1000);
            saveState();
            
            btnStart.classList.add('d-none');
            btnReset.classList.remove('d-none');
            btnFinish.classList.remove('d-none');
            formSave.classList.add('d-none');
            
            if (isBreak) {
                btnSkipBreak.classList.remove('d-none');
            } else {
                btnSkipBreak.classList.add('d-none');
            }
            
            updateBadge();
            
            timerInterval = setInterval(tick, 1000);
        }

        function tick() {
            let remaining = Math.round((targetEndTime - Date.now()) / 1000);
            if (remaining < 0) remaining = 0;
            totalSeconds = remaining;
            
            updateDisplay();
            saveState(); 
            
            if (!isBreak && totalSeconds === 10 * 60) {
                speak("10 minutes left");
            }
            
            if (totalSeconds <= 0) {
                clearInterval(timerInterval);
                handlePhaseComplete(false);
            }
        }
        
        function handlePhaseComplete(isBackground) {
            if (!isBreak) {
                // Focus complete
                focusMinutesAccumulated += 25;
                if (currentCycle >= 4) {
                    isRunning = false;
                    clearState();
                    if(!isBackground) speak("Session 4 complete. Pomodoro finished.");
                    document.getElementById('pomo-duration').value = focusMinutesAccumulated;
                    showSaveSession();
                } else {
                    isBreak = true;
                    totalSeconds = 5 * 60;
                    if(!isBackground) speak("Session " + currentCycle + " complete. Time for a break.");
                    updateDisplay();
                    updateBadge();
                    isRunning = false; 
                    startTimer(); 
                }
            } else {
                // Break complete, start next focus
                isBreak = false;
                currentCycle++;
                totalSeconds = 25 * 60;
                if(!isBackground) speak("Break is over. Focus session " + currentCycle + " started.");
                btnSkipBreak.classList.add('d-none');
                updateDisplay();
                updateBadge();
                isRunning = false;
                startTimer();
            }
        }
        
        function skipBreak() {
            if (isBreak) {
                clearInterval(timerInterval);
                isRunning = false;
                totalSeconds = 0;
                handlePhaseComplete(false);
            }
        }

        function resetTimer() {
            clearInterval(timerInterval);
            isRunning = false;
            isBreak = false;
            currentCycle = 1;
            focusMinutesAccumulated = 0;
            totalSeconds = 25 * 60;
            clearState();
            
            document.getElementById('pomo-duration').value = "25";
            updateDisplay();
            updateBadge();
            
            btnStart.classList.remove('d-none');
            btnReset.classList.add('d-none');
            btnFinish.classList.add('d-none');
            btnSkipBreak.classList.add('d-none');
            formSave.classList.add('d-none');
        }

        function finishEarly() {
            clearInterval(timerInterval);
            isRunning = false;
            
            let currentCycleFocus = 0;
            if (!isBreak) {
                let completedSecs = (25 * 60) - totalSeconds;
                currentCycleFocus = Math.round(completedSecs / 60);
            }
            
            let totalDone = focusMinutesAccumulated + currentCycleFocus;
            if (totalDone < 1) totalDone = 1; 
            
            document.getElementById('pomo-duration').value = totalDone;
            totalSeconds = 0;
            clearState();
            updateDisplay();
            showSaveSession();
        }
        
        function showSaveSession() {
            btnStart.classList.add('d-none');
            btnReset.classList.remove('d-none');
            btnFinish.classList.add('d-none');
            btnSkipBreak.classList.add('d-none');
            formSave.classList.remove('d-none');
            badgeLabel.className = 'badge bg-success bg-opacity-10 text-success mb-3 px-3 py-2 rounded-pill';
            badgeLabel.innerHTML = '<i class="fa-solid fa-flag-checkered me-2"></i>SELESAI';
        }
        
        document.addEventListener('DOMContentLoaded', loadState);
    </script>
</body>
</html>
