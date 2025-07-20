<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("../login.jsp");
    return;
  }
  String username = (String) session.getAttribute("username");
  String method = request.getMethod();
  String message = null;

  if (request.getParameter("log") != null) {
    session.invalidate();
    response.sendRedirect("../login.jsp?logout=true");
    return;
  }
  if ("POST".equalsIgnoreCase(method)) {
    String question = request.getParameter("question");
    if (question != null && !question.trim().isEmpty()) {
      try (Connection conn = new ApplicationDB().getConnection();
           PreparedStatement ps = conn.prepareStatement(
             "INSERT INTO Questions (username, question, status) VALUES (?, ?, 'pending')")) {
        ps.setString(1, username);
        ps.setString(2, question);
        ps.executeUpdate();
        message = "Your question has been submitted.";
      } catch (SQLException e) {
        message = "Error: " + e.getMessage();
      }
    } else {
      message = "Please enter a question.";
    }
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Ask a Question</title>
  <style>
    body { margin:0; font-family:'Roboto',sans-serif; background:#1a1a1a; color:#eee; }
    .navbar {
      background: #1c1c1c;
      width: 240px;
      position: fixed;
      top: 0;
      left: 0;
      height: 100vh;
      padding-top: 80px;
      box-shadow: 2px 0 5px rgba(0,0,0,0.7);
    }
    .navbar h2 {
      color: #4CAF50;
      text-align: center;
      margin: 20px 0;
      font-size: 1.4rem;
    }
    .navbar a {
      display: block;
      padding: 12px 20px;
      color: #bbb;
      text-decoration: none;
      transition: background .2s, color .2s;
    }
    .navbar a:hover { background: #333; color: #fff; }
    .dashboard-container { margin-left: 240px; margin-top: 80px; padding: 20px; max-width: calc(100% - 260px); }
    .form-control { width:100%; padding:8px; margin-bottom:10px; border:1px solid #444; border-radius:4px; background:#1f1f1f; color:#eee; }
    .btn-primary { padding:8px 12px; background:#4CAF50; color:#fff; border:none; border-radius:4px; cursor:pointer; }
    .btn-primary:hover { background:#43a047; }
    .site-header {
      background: #2c2c2c;
      padding: 10px 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 2px 4px rgba(0,0,0,0.5);
      position: fixed;
      left: 240px;
      right: 0;
      top: 0;
      z-index: 10;
    }
    .site-header h1 {
      margin: 0;
      font-size: 2rem;
    }
    .top-right {
      display: flex;
      align-items: center;
    }
    .top-right p {
      margin: 0 15px 0 0;
      font-size: 1.2rem;
    }
    #logout {
      background: #e53935;
      border: none;
      padding: 8px 16px;
      font-size: 1rem;
      border-radius: 4px;
      cursor: pointer;
      color: #fff;
      transition: background .2s;
    }
    #logout:hover {
      background: #d32f2f;
    }
  </style>
</head>
<body>
  <div class="navbar">
    <h2>Representative Panel</h2>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="editSchedule.jsp">Edit Train Schedule</a>
    <a href="faq.jsp">Browse Q&A (FAQ)</a>
    <a href="askQuestion.jsp">Ask a Question</a>
    <a href="replyQuestions.jsp">Reply to Customer Questions</a>
    <a href="stationSchedules.jsp">Schedules by Station</a>
    <a href="lineReservations.jsp">Customers by Line & Date</a>
  </div>

  <header class="site-header">
    <h1>Ask a Question</h1>
    <div class="top-right">
      <p>Welcome, <%= username %></p>
      <form method="post">
        <button id="logout" name="log" type="submit">Log Out</button>
      </form>
    </div>
  </header>

  <div class="dashboard-container">
    <h1>Ask a Question</h1>
    <% if (message != null) { %>
      <div style="margin-bottom:10px;color:#4CAF50;"><%= message %></div>
    <% } %>
    <form method="post">
      <textarea class="form-control" name="question" rows="4" placeholder="Type your question here..." required></textarea>
      <button class="btn-primary" type="submit">Submit</button>
    </form>
  </div>
</body>
</html> 