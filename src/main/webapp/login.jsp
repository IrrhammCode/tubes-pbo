<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Prevent caching so user cannot go back to login page after logging in
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
    <title>Login - StudySpace</title>
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
    </style>
</head>
<body>

<div class="login-card">
    <h2 style="color: #2c3e50; margin-bottom: 5px;">StudySpace</h2>
    <p style="color: #7f8c8d; margin-bottom: 25px;">Masuk ke akun Anda</p>
    
    <% if(request.getAttribute("error") != null) { %>
        <div class="error-msg"><%= request.getAttribute("error") %></div>
    <% } %>

    <form action="LoginServlet" method="POST">
        <div class="form-group">
            <label>Username</label>
            <input type="text" name="user" required placeholder="admin" value="admin">
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="pass" required placeholder="admin123" value="admin123">
        </div>
        <button type="submit" class="btn-primary">Masuk</button>
    </form>
</div>

</body>
</html>
