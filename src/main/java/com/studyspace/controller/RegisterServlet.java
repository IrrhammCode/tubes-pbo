package com.studyspace.controller;

import com.studyspace.data.DatabaseManager;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("user");
        String email = request.getParameter("email");
        String pass = request.getParameter("pass");
        String confirmPass = request.getParameter("confirm_pass");

        // Simple validation
        if (username == null || email == null || pass == null || confirmPass == null || 
            username.trim().isEmpty() || email.trim().isEmpty() || pass.isEmpty()) {
            request.setAttribute("error", "Semua kolom harus diisi!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!pass.equals(confirmPass)) {
            request.setAttribute("error", "Password dan Konfirmasi Password tidak cocok!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        DatabaseManager db = new DatabaseManager();
        Connection con = db.getConnection();
        boolean success = false;
        String errorMessage = "Gagal mendaftar, silakan coba lagi.";

        try {
            if (con != null) {
                // Check if username already exists
                String checkSql = "SELECT id FROM users WHERE username = ? OR email = ?";
                PreparedStatement checkStmt = con.prepareStatement(checkSql);
                checkStmt.setString(1, username);
                checkStmt.setString(2, email);
                ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    errorMessage = "Username atau Email sudah terdaftar!";
                } else {
                    // Get current month/year for joinedDate, e.g., "Agt 2026"
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM yyyy", new Locale("id", "ID"));
                    String joinedDate = YearMonth.now().format(formatter);

                    String insertSql = "INSERT INTO users (username, email, password, joinedDate) VALUES (?, ?, ?, ?)";
                    PreparedStatement insertStmt = con.prepareStatement(insertSql);
                    insertStmt.setString(1, username);
                    insertStmt.setString(2, email);
                    insertStmt.setString(3, pass);
                    insertStmt.setString(4, joinedDate);
                    
                    int rows = insertStmt.executeUpdate();
                    if (rows > 0) {
                        success = true;
                    }
                    insertStmt.close();
                }
                rs.close();
                checkStmt.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.disconnect();
        }

        if (success) {
            request.setAttribute("success", "Pendaftaran berhasil! Silakan masuk dengan akun baru Anda.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } else {
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
