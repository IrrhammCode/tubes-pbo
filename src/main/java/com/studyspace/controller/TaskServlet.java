package com.studyspace.controller;

import com.studyspace.data.DatabaseManager;
import com.studyspace.model.AssignmentTask;
import com.studyspace.model.ExamTask;
import com.studyspace.model.Task;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/TaskServlet")
public class TaskServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        String taskId = request.getParameter("id");

        if ("delete".equals(action) && taskId != null) {
            DatabaseManager db = new DatabaseManager();
            Connection con = db.getConnection();
            try {
                if (con != null) {
                    String sql = "DELETE FROM tasks WHERE activityId = ?";
                    PreparedStatement pstmt = con.prepareStatement(sql);
                    pstmt.setString(1, taskId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                db.disconnect();
            }
        } else if ("complete".equals(action) && taskId != null) {
            // === OOP: Load task from DB, wrap into model object, use markAsCompleted() ===
            DatabaseManager db = new DatabaseManager();
            Connection con = db.getConnection();
            try {
                if (con != null) {
                    // 1. Read task data from DB
                    String selectSql = "SELECT taskType, difficultyLevel, deadline FROM tasks WHERE activityId = ?";
                    PreparedStatement psSelect = con.prepareStatement(selectSql);
                    psSelect.setString(1, taskId);
                    ResultSet rs = psSelect.executeQuery();

                    if (rs.next()) {
                        String taskType = rs.getString("taskType");
                        int difficulty = rs.getInt("difficultyLevel");
                        String deadlineStr = rs.getString("deadline");
                        LocalDateTime deadline = LocalDateTime.parse(deadlineStr.replace(" ", "T"));

                        // 2. Polymorphism: create the correct subclass
                        Task task;
                        if ("EXAM".equals(taskType)) {
                            task = new ExamTask(taskId, "", deadline, difficulty, new ArrayList<>());
                        } else {
                            task = new AssignmentTask(taskId, "", deadline, difficulty, "");
                        }

                        // 3. Use OOP method to mark as completed
                        task.markAsCompleted();

                        // 4. Update DB using object state
                        String updateSql = "UPDATE tasks SET status = ?, isCompleted = ? WHERE activityId = ?";
                        PreparedStatement psUpdate = con.prepareStatement(updateSql);
                        psUpdate.setString(1, task.getStatus());       // "DONE" from markAsCompleted()
                        psUpdate.setBoolean(2, task.isCompleted());     // true from markAsCompleted()
                        psUpdate.setString(3, task.getActivityId());
                        psUpdate.executeUpdate();
                        psUpdate.close();

                        // 5. XP based on difficulty (OOP encapsulation), not hardcoded
                        int xpGained = task.getDifficultyLevel() * 20; // difficulty 1=20XP, 5=100XP
                        int userId = (int) session.getAttribute("userId");
                        String xpSql = "UPDATE users SET totalXP = totalXP + ? WHERE id = ?";
                        PreparedStatement pstmtXp = con.prepareStatement(xpSql);
                        pstmtXp.setInt(1, xpGained);
                        pstmtXp.setInt(2, userId);
                        pstmtXp.executeUpdate();
                        pstmtXp.close();
                    }
                    rs.close();
                    psSelect.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                db.disconnect();
            }
        } else if ("updateStatus".equals(action) && taskId != null) {
            String newStatus = request.getParameter("status");
            
            if (newStatus != null) {
                DatabaseManager db = new DatabaseManager();
                Connection con = db.getConnection();
                try {
                    if (con != null) {
                        boolean isCompleted = "DONE".equals(newStatus);
                        String sql = "UPDATE tasks SET status = ?, isCompleted = ? WHERE activityId = ?";
                        PreparedStatement pstmt = con.prepareStatement(sql);
                        pstmt.setString(1, newStatus);
                        pstmt.setBoolean(2, isCompleted);
                        pstmt.setString(3, taskId);
                        pstmt.executeUpdate();
                        pstmt.close();
                        
                        if (isCompleted) {
                            int userId = (int) session.getAttribute("userId");
                            // Get difficulty for XP calculation
                            String selSql = "SELECT difficultyLevel FROM tasks WHERE activityId = ?";
                            PreparedStatement psSel = con.prepareStatement(selSql);
                            psSel.setString(1, taskId);
                            ResultSet rs = psSel.executeQuery();
                            int xpGained = 50;
                            if (rs.next()) {
                                xpGained = rs.getInt("difficultyLevel") * 20;
                            }
                            rs.close(); psSel.close();

                            String xpSql = "UPDATE users SET totalXP = totalXP + ? WHERE id = ?";
                            PreparedStatement pstmtXp = con.prepareStatement(xpSql);
                            pstmtXp.setInt(1, xpGained);
                            pstmtXp.setInt(2, userId);
                            pstmtXp.executeUpdate();
                            pstmtXp.close();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    db.disconnect();
                }
            }
        }
        
        response.sendRedirect("task-board.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String title = request.getParameter("title");
            String taskType = request.getParameter("type");
            String deadlineStr = request.getParameter("deadline");
            String subjectCode = request.getParameter("subjectCode");
            String difficultyStr = request.getParameter("difficultyLevel");
            String attachmentLink = request.getParameter("attachmentLink");
            String syllabusStr = request.getParameter("syllabusList");

            int difficulty = 3;
            try { difficulty = Integer.parseInt(difficultyStr); } catch (Exception e) {}
            int userId = (int) session.getAttribute("userId");
            String newId = "task-" + UUID.randomUUID().toString().substring(0, 8);

            // Parse deadline
            if (deadlineStr != null && deadlineStr.length() == 10) {
                deadlineStr += " 23:59:59";
            }
            LocalDateTime deadline = LocalDateTime.now().plusDays(7); // default
            try {
                deadline = LocalDateTime.parse(deadlineStr.replace(" ", "T"));
            } catch (Exception e) {}

            // === OOP: Polymorphism — create correct subclass based on taskType ===
            Task task;
            if ("EXAM".equals(taskType)) {
                List<String> syllabusList = new ArrayList<>();
                if (syllabusStr != null && !syllabusStr.trim().isEmpty()) {
                    syllabusList = Arrays.asList(syllabusStr.split(","));
                }
                task = new ExamTask(newId, title, deadline, difficulty, syllabusList);
            } else {
                task = new AssignmentTask(newId, title, deadline, difficulty,
                        attachmentLink != null ? attachmentLink : "");
            }

            // Set subject code
            if (subjectCode != null && subjectCode.trim().isEmpty()) {
                subjectCode = null;
            }
            task.setSubjectCode(subjectCode);

            // Calculate priority score using Prioritizable interface
            double priorityScore = task.calculatePriorityScore();

            // Persist to database
            DatabaseManager db = new DatabaseManager();
            Connection con = db.getConnection();
            try {
                if (con != null) {
                    String sql = "INSERT INTO tasks (activityId, title, taskType, deadline, difficultyLevel, status, subjectCode, attachmentLink, syllabusList, priorityScore, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement pstmt = con.prepareStatement(sql);
                    pstmt.setString(1, task.getActivityId());
                    pstmt.setString(2, task.getTitle());
                    pstmt.setString(3, taskType != null ? taskType : "ASSIGNMENT");

                    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    pstmt.setString(4, task.getDeadline().format(dtf));
                    pstmt.setInt(5, task.getDifficultyLevel());
                    pstmt.setString(6, task.getStatus());  // "TODO" from constructor
                    pstmt.setString(7, task.getSubjectCode());

                    // Polymorphic field storage
                    if (task instanceof AssignmentTask) {
                        pstmt.setString(8, ((AssignmentTask) task).getAttachmentLink());
                        pstmt.setString(9, null);
                    } else if (task instanceof ExamTask) {
                        pstmt.setString(8, null);
                        pstmt.setString(9, String.join(",", ((ExamTask) task).getSyllabusList()));
                    } else {
                        pstmt.setString(8, null);
                        pstmt.setString(9, null);
                    }

                    pstmt.setDouble(10, priorityScore);
                    pstmt.setInt(11, userId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                db.disconnect();
            }
            response.sendRedirect("task-board.jsp");
        }
    }
}
