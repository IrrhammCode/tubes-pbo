package com.studyspace.controller;

import com.studyspace.data.DatabaseManager;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Logout functionality
        if (request.getParameter("logout") != null) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect("login.jsp");
        } else {
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("user");
        String pass = request.getParameter("pass");

        DatabaseManager db = new DatabaseManager();
        Connection con = db.getConnection();
        boolean isValid = false;
        int userId = -1;

        try {
            if (con != null) {
                String sql = "SELECT id, password FROM users WHERE username = ?";
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setString(1, username);
                ResultSet rs = pstmt.executeQuery();

                if (rs.next()) {
                    if (rs.getString("password").equals(pass)) {
                        isValid = true;
                        userId = rs.getInt("id");
                    }
                }
                rs.close();
                pstmt.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.disconnect();
        }

        if (isValid) {
            // Set session
            HttpSession session = request.getSession();
            session.setAttribute("username", username);
            session.setAttribute("userId", userId);
            response.sendRedirect("index.jsp"); // go to dashboard
        } else {
            request.setAttribute("error", "Username atau Password salah!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
