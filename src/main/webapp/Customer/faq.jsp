<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  String keyword = request.getParameter("keyword");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Frequently Asked Questions</title>
  <style>
    body {
      margin: 0;
      font-family: 'Roboto', sans-serif;
      background: #1a1a1a;
      color: #eee;
    }
    .site-header {
      background: #1c1c1c;
      padding: 20px;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 2px 5px rgba(0,0,0,0.7);
      z-index: 200;
    }
    .site-header h1 {
      color: #4CAF50;
      margin: 0;
      font-size: 1.8rem;
    }
    .dashboard-container {
      margin: 100px auto 0 auto;
      padding: 20px;
      max-width: 900px;
    }
    .section-title {
      color: #4CAF50;
      font-size: 1.5rem;
      margin: 20px 0 10px;
    }
    .faq-search {
      margin-bottom: 24px;
      text-align: left;
    }
    .faq-search input {
      padding: 10px;
      width: 320px;
      border-radius: 4px;
      border: 1px solid #444;
      background: #222;
      color: #eee;
      font-size: 1rem;
    }
    .faq-search button {
      padding: 10px 18px;
      background: #4CAF50;
      color: #fff;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 1rem;
      margin-left: 8px;
      transition: background .2s;
    }
    .faq-search button:hover {
      background: #388e3c;
    }
    .faq-table {
      width: 100%;
      border-collapse: collapse;
      background: #232323;
      border-radius: 6px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    .faq-table th, .faq-table td {
      padding: 14px 10px;
      border-bottom: 1px solid #333;
      text-align: left;
    }
    .faq-table th {
      background: #222;
      color: #4CAF50;
      font-size: 1.1rem;
    }
    .faq-table tr:last-child td {
      border-bottom: none;
    }
    .no-results {
      text-align: center;
      color: #888;
      padding: 24px 0;
    }
    .back-btn {
      display: inline-block;
      margin-bottom: 24px;
      padding: 10px 22px;
      background: #333;
      color: #4CAF50;
      border: none;
      border-radius: 4px;
      font-size: 1rem;
      text-decoration: none;
      cursor: pointer;
      transition: background .2s, color .2s;
    }
    .back-btn:hover {
      background: #4CAF50;
      color: #fff;
    }
  </style>
</head>
<body>
  <header class="site-header">
    <h1>Frequently Asked Questions</h1>
  </header>

  <div class="dashboard-container">
    <a href="dashboard.jsp" class="back-btn">&larr; Back to Dashboard</a>
    <div class="section-title">FAQ</div>
    <form class="faq-search" method="get">
      <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>" placeholder="Search questions..."/>
      <button type="submit">Search</button>
    </form>
    <table class="faq-table">
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
      <tr><td colspan="2" class="no-results">No questions found.</td></tr>
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