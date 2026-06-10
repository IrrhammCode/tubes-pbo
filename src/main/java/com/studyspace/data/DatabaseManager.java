package com.studyspace.data;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class DatabaseManager {
    private Connection con;
    private String message;

    // Koneksi Database
    public void connect() {
        try {
            // Register JDBC driver (for MySQL 8.0+)
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/studyspace", "root", "");
            message = "DB connected";
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
        }
    }

    public void disconnect() {
        try {
            if (con != null && !con.isClosed()) {
                con.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
        }
    }

    public String getMessage() {
        return message;
    }

    // Untuk CREATE, UPDATE, DELETE
    public int runUpdate(String query) {
        int result = 0;
        try {
            connect();
            Statement stmt = con.createStatement();
            result = stmt.executeUpdate(query);
            message = "info: " + result + " rows affected";
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
        } finally {
            disconnect();
        }
        return result;
    }

    // Untuk penggunaan PreparedStatement (Lebih aman dari SQL Injection)
    public Connection getConnection() {
        connect();
        return con;
    }
}
