<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("../login.jsp");
    return;
  }
  String username = (String) session.getAttribute("username");
  String lineName = request.getParameter("lineName");
  String date = request.getParameter("date");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Customers by Transit Line & Date</title>
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
    .section-title { color: #4CAF50; font-size: 1.5rem; margin-bottom: 10px; }
    .line-search { margin-bottom: 20px; }
    .line-search input { padding: 8px; width: 200px; border-radius: 4px; border: 1px solid #444; background: #222; color: #eee; margin-right: 10px; }
    .line-search button { padding: 8px 12px; background: #4CAF50; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    .line-search button:hover { background: #43a047; }
    .table-admin { width: 100%; border-collapse: collapse; background: #2c2c2c; }
    .table-admin th, .table-admin td { padding: 10px; border: 1px solid #444; text-align: left; }
    .table-admin th { background: #333; }
  </style>
</head>
<body>
  <div class="navbar">
    <h2>Representative Panel</h2>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="editSchedule.jsp">Edit Train Schedule</a>
    <a href="replyQuestions.jsp">Reply to Customer Questions</a>
    <a href="stationSchedules.jsp">Schedules by Station</a>
    <a href="lineReservations.jsp">Customers by Line & Date</a>
  </div>
  <div class="dashboard-container">
    <div class="section-title">Customers with Reservations</div>
    <form class="line-search" method="get">
      <input type="text" name="lineName" value="<%= lineName != null ? lineName : "" %>" placeholder="Transit Line Name" required/>
      <input type="date" name="date" value="<%= date != null ? date : "" %>" required/>
      <button type="submit">Search</button>
    </form>
    <% if (lineName != null && date != null && !lineName.trim().isEmpty() && !date.trim().isEmpty()) { %>
    <table class="table-admin">
      <tr><th>Line Name</th><th>Customer Name</th><th>Email</th><th>Reservation Number</th><th>Date</th></tr>
      <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
          conn = new ApplicationDB().getConnection();
          ps = conn.prepareStatement("SELECT ts.lineName, c.firstName, c.lastName, c.email, r.reservationNumber, r.reservationDate FROM Reservation r JOIN Customer c ON r.customerId = c.customerId JOIN TrainSchedule ts ON r.ScheduleLineId = ts.lineId WHERE ts.lineName = ? AND DATE(ts.departureTime) = DATE(r.reservationDate) AND DATE(r.reservationDate) LIKE ?%");
          ps.setString(1, lineName);
          ps.setString(2, date);
          rs = ps.executeQuery();
          boolean found = false;
          while (rs.next()) {
            found = true;
      %>
      <tr>
        <td><%= rs.getString("lineName") %></td>
        <td><%= rs.getString("firstName") %> <%= rs.getString("lastName") %></td>
        <td><%= rs.getString("email") %></td>
        <td><%= rs.getString("reservationNumber") %></td>
        <td><%= rs.getString("reservationDate") %></td>
      </tr>
      <%
          }
          if (!found) {
      %>
      <tr><td colspan="5" style="text-align:center;color:#bbb;">No reservations found for this line and date.</td></tr>
      <%
          }
        } catch (Exception e) { %>
      <tr><td colspan="5" style="color:#e53935;text-align:center;">Error: <%= e.getMessage() %></td></tr>
      <%
        } finally {
          if (rs != null) try { rs.close(); } catch (Exception ignore) {}
          if (ps != null) try { ps.close(); } catch (Exception ignore) {}
          if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
      %>
    </table>
    <% } %>
  </div>
</body>
</html>
