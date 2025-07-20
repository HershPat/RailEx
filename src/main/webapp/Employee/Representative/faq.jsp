<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("../login.jsp");
    return;
  }
  String username = (String) session.getAttribute("username");
  String keyword = request.getParameter("keyword");

  if (request.getParameter("log") != null) {
    session.invalidate();
    response.sendRedirect("../login.jsp?logout=true");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>FAQ - Questions & Answers</title>
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
    .section-title { color: #4CAF50; font-size: 1.5rem; margin-bottom:10px; }
    .faq-search { margin-bottom:20px; }
    .faq-search input { padding:8px; width:300px; border-radius:4px; border:1px solid #444; background:#222; color:#eee; }
    .faq-search button { padding:8px 12px; background:#4CAF50; color:#fff; border:none; border-radius:4px; cursor:pointer; }
    .faq-search button:hover { background:#43a047; }
    .table-admin { width:100%; border-collapse:collapse; background:#2c2c2c; }
    .table-admin th, .table-admin td { padding:10px; border:1px solid #444; text-align:left; }
    .table-admin th { background:#333; }
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
    <h1>FAQ</h1>
    <div class="top-right">
      <p>Welcome, <%= username %></p>
      <form method="post">
        <button id="logout" name="log" type="submit">Log Out</button>
      </form>
    </div>
  </header>

  <div class="dashboard-container">
    <div class="section-title">Frequently Asked Questions</div>
    <form class="faq-search" method="get">
      <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>" placeholder="Search questions..."/>
      <button type="submit">Search</button>
    </form>
    <table class="table-admin">
      <tr><th>Question</th><th>Answer</th></tr>
      <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
          conn = new ApplicationDB().getConnection();
          String sql = "SELECT questionMessage, replyMessage FROM CustomerService WHERE replyMessage IS NOT NULL";
          if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND questionMessage LIKE ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + keyword + "%");
          } else {
            ps = conn.prepareStatement(sql);
          }
          rs = ps.executeQuery();
          boolean found = false;
          while (rs.next()) {
            found = true;
      %>
      <tr>
        <td><%= rs.getString("questionMessage") %></td>
        <td><%= rs.getString("replyMessage") %></td>
      </tr>
      <%
          }
          if (!found) {
      %>
      <tr><td colspan="2" style="text-align:center;color:#bbb;">No questions found.</td></tr>
      <%
          }
        } catch (Exception e) { %>
      <tr><td colspan="2" style="color:#e53935;text-align:center;">Error: <%= e.getMessage() %></td></tr>
      <%
        } finally {
          if (rs != null) try { rs.close(); } catch (Exception ignore) {}
          if (ps != null) try { ps.close(); } catch (Exception ignore) {}
          if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
      %>
    </table>
  </div>
</body>
</html> 