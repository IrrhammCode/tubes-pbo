package com.studyspace.controller;

import com.studyspace.data.DatabaseManager;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.UUID;

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
            DatabaseManager db = new DatabaseManager();
            Connection con = db.getConnection();
            try {
                if (con != null) {
                    // Update task status
                    String sql = "UPDATE tasks SET status = 'DONE', isCompleted = TRUE WHERE activityId = ?";
                    PreparedStatement pstmt = con.prepareStatement(sql);
                    pstmt.setString(1, taskId);
                    pstmt.executeUpdate();
                    pstmt.close();

                    // Add XP to user (simplification)
                    int userId = (int) session.getAttribute("userId");
                    String xpSql = "UPDATE users SET totalXP = totalXP + 50 WHERE id = ?";
                    PreparedStatement pstmtXp = con.prepareStatement(xpSql);
                    pstmtXp.setInt(1, userId);
                    pstmtXp.executeUpdate();
                    pstmtXp.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                db.disconnect();
            }
        } else if ("updateStatus".equals(action) && taskId != null) {
            String newStatus = request.getParameter("status"); // TODO, IN_PROGRESS, DONE
            
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
                            String xpSql = "UPDATE users SET totalXP = totalXP + 50 WHERE id = ?";
                            PreparedStatement pstmtXp = con.prepareStatement(xpSql);
                            pstmtXp.setInt(1, userId);
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
            String deadline = request.getParameter("deadline");
            String subjectCode = request.getParameter("subjectCode");
            String difficultyStr = request.getParameter("difficultyLevel");

            int difficulty = 3;
            try { difficulty = Integer.parseInt(difficultyStr); } catch (Exception e) {}
            int userId = (int) session.getAttribute("userId");
            String newId = "task-" + UUID.randomUUID().toString().substring(0, 8);

            DatabaseManager db = new DatabaseManager();
            Connection con = db.getConnection();
            try {
                if (con != null) {
                    String sql = "INSERT INTO tasks (activityId, title, taskType, deadline, difficultyLevel, status, subjectCode, user_id) VALUES (?, ?, ?, ?, ?, 'TODO', ?, ?)";
                    PreparedStatement pstmt = con.prepareStatement(sql);
                    pstmt.setString(1, newId);
                    pstmt.setString(2, title);
                    pstmt.setString(3, taskType != null ? taskType : "ASSIGNMENT");
                    // simple append of time if only date is provided
                    if(deadline != null && deadline.length() == 10) {
                        deadline += " 23:59:59";
                    }
                    pstmt.setString(4, deadline);
                    pstmt.setInt(5, difficulty);
                    
                    if (subjectCode != null && subjectCode.trim().isEmpty()) {
                        subjectCode = null;
                    }
                    pstmt.setString(6, subjectCode);
                    
                    pstmt.setInt(7, userId);
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
