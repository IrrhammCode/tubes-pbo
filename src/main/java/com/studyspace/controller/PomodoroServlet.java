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

@WebServlet("/PomodoroServlet")
public class PomodoroServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        int userId = (int) session.getAttribute("userId");

        if ("complete".equals(action)) {
            String durationStr = request.getParameter("duration");
            int duration = 25;
            try { duration = Integer.parseInt(durationStr); } catch(Exception e) {}

            String sessionId = "pom-" + UUID.randomUUID().toString().substring(0, 8);

            DatabaseManager db = new DatabaseManager();
            Connection con = db.getConnection();
            try {
                if (con != null) {
                    // Insert Pomodoro Session
                    String sql = "INSERT INTO pomodoro_sessions (sessionId, startTime, endTime, durationMinutes, completed, user_id) VALUES (?, NOW() - INTERVAL ? MINUTE, NOW(), ?, TRUE, ?)";
                    PreparedStatement pstmt = con.prepareStatement(sql);
                    pstmt.setString(1, sessionId);
                    pstmt.setInt(2, duration);
                    pstmt.setInt(3, duration);
                    pstmt.setInt(4, userId);
                    pstmt.executeUpdate();
                    pstmt.close();

                    // Update User Stats
                    String xpSql = "UPDATE users SET totalXP = totalXP + 50, pomodoroSessionsCount = pomodoroSessionsCount + 1, totalFocusMinutes = totalFocusMinutes + ? WHERE id = ?";
                    PreparedStatement pstmtXp = con.prepareStatement(xpSql);
                    pstmtXp.setInt(1, duration);
                    pstmtXp.setInt(2, userId);
                    pstmtXp.executeUpdate();
                    pstmtXp.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                db.disconnect();
            }
        } else if ("resetAll".equals(action)) {
            DatabaseManager db = new DatabaseManager();
            Connection con = db.getConnection();
            try {
                if (con != null) {
                    String sql = "DELETE FROM pomodoro_sessions WHERE user_id = ?";
                    PreparedStatement pstmt = con.prepareStatement(sql);
                    pstmt.setInt(1, userId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                db.disconnect();
            }
        }
        
        response.sendRedirect("pomodoro.jsp");
    }
}
