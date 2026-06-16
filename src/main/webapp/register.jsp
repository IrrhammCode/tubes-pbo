<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Prevent caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    if(session.getAttribute("userId") != null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar - StudySpace</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background-color: #f8f9fa;
        }
        .login-card {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            width: 100%;
            max-width: 400px;
            text-align: center;
        }
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-top: 8px;
            box-sizing: border-box;
        }
        .btn-primary {
            width: 100%;
            padding: 12px;
            background-color: #4a6ee0;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
        }
        .btn-primary:hover {
            background-color: #385bce;
        }
        .error-msg {
            color: #e74c3c;
            margin-bottom: 15px;
            font-size: 0.9em;
        }
        .success-msg {
            color: #27ae60;
            margin-bottom: 15px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>

<div class="login-card">
    <h2 style="color: #2c3e50; margin-bottom: 5px;">StudySpace</h2>
    <p style="color: #7f8c8d; margin-bottom: 25px;">Buat akun baru Anda</p>
    
    <% if(request.getAttribute("error") != null) { %>
        <div class="error-msg"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if(request.getAttribute("success") != null) { %>
        <div class="success-msg"><%= request.getAttribute("success") %></div>
    <% } %>

    <form action="RegisterServlet" method="POST">
        <div class="form-group">
            <label>Username</label>
            <input type="text" name="user" required placeholder="Masukkan username">
        </div>
        <div class="form-group">
            <label>Email</label>
            <input type="email" name="email" required placeholder="email@contoh.com">
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="pass" required placeholder="Masukkan password">
        </div>
        <div class="form-group">
            <label>Konfirmasi Password</label>
            <input type="password" name="confirm_pass" required placeholder="Ulangi password">
        </div>
        <button type="submit" class="btn-primary" style="margin-bottom: 15px;">Daftar</button>
        <p style="color: #7f8c8d; font-size: 0.9em;">Sudah punya akun? <a href="login.jsp" style="color: #4a6ee0; text-decoration: none; font-weight: bold;">Masuk di sini</a></p>
    </form>
</div>

</body>
</html>
