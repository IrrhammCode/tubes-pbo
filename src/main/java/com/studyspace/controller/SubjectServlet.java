package com.studyspace.controller;

import com.studyspace.data.DatabaseManager;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SubjectServlet")
public class SubjectServlet extends HttpServlet {

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

        if ("add".equals(action)) {
            String subjectName = request.getParameter("subjectName");
            String subjectCode = request.getParameter("subjectCode");

            // If user didn't provide a code, generate one automatically
            if (subjectCode == null || subjectCode.trim().isEmpty()) {
                subjectCode = "MK-" + UUID.randomUUID().toString().substring(0, 5).toUpperCase();
            }

            if (subjectName != null && !subjectName.trim().isEmpty()) {
                DatabaseManager db = new DatabaseManager();
                Connection con = db.getConnection();
                try {
                    if (con != null) {
                        String sql = "INSERT INTO subjects (subjectCode, subjectName, user_id) VALUES (?, ?, ?)";
                        PreparedStatement pstmt = con.prepareStatement(sql);
                        pstmt.setString(1, subjectCode);
                        pstmt.setString(2, subjectName);
                        pstmt.setInt(3, userId);
                        pstmt.executeUpdate();
                        pstmt.close();
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
}
