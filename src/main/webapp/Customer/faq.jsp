<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  // Optional: Only allow access if customer is logged in
  // if (session == null || session.getAttribute("customerId") == null) {
  //   response.sendRedirect("login.jsp");
  //   return;
  // }
  String keyword = request.getParameter("keyword");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Frequently Asked Questions</title>
  <style>
    body { margin:0; font-family:'Roboto',sans-serif; background:#f8f8f8; color:#222; }
    .faq-container { max-width:800px; margin:60px auto; padding:32px 24px; background:#fff; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.08); }
    .faq-title { color:#4CAF50; font-size:2rem; margin-bottom:24px; text-align:center; }
    .faq-search { margin-bottom:24px; text-align:center; }
    .faq-search input { padding:10px; width:320px; border-radius:4px; border:1px solid #bbb; background:#f4f4f4; color:#222; font-size:1rem; }
    .faq-search button { padding:10px 18px; background:#4CAF50; color:#fff; border:none; border-radius:4px; cursor:pointer; font-size:1rem; margin-left:8px; }
    .faq-search button:hover { background:#388e3c; }
    .faq-table { width:100%; border-collapse:collapse; background:#fafafa; }
    .faq-table th, .faq-table td { padding:14px 10px; border-bottom:1px solid #eee; text-align:left; }
    .faq-table th { background:#f0f0f0; color:#333; font-size:1.1rem; }
    .no-results { text-align:center; color:#888; padding:24px 0; }
  </style>
</head>
<body>
  <div class="faq-container">
    <div class="faq-title">Frequently Asked Questions</div>
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