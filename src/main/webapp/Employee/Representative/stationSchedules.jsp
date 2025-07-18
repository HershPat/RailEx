<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("../login.jsp");
    return;
  }
  String username = (String) session.getAttribute("username");
  String station = request.getParameter("station");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Schedules by Station</title>
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
    .section-title { color:#4CAF50; font-size: 1.5rem; margin-bottom:10px; }
    .station-search { margin-bottom:20px; }
    .station-search input { padding:8px; width:300px; border-radius:4px; border:1px solid #444; background:#222; color:#eee; }
    .station-search button { padding:8px 12px; background:#4CAF50; color:#fff; border:none; border-radius:4px; cursor:pointer; }
    .station-search button:hover { background:#43a047; }
    .table-admin { width:100%; border-collapse:collapse; background:#2c2c2c; }
    .table-admin th, .table-admin td { padding:10px; border:1px solid #444; text-align:left; }
    .table-admin th { background:#333; }
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
    <div class="section-title">Schedules for Station</div>
    <form class="station-search" method="get">
      <input type="text" name="station" value="<%= station != null ? station : "" %>" placeholder="Enter station name..." required/>
      <button type="submit">Search</button>
    </form>
    <% if (station != null && !station.trim().isEmpty()) { %>
    <table class="table-admin">
      <tr><th>Line ID</th><th>Line Name</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Arrival</th></tr>
      <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
          conn = new ApplicationDB().getConnection();
          ps = conn.prepareStatement("SELECT t.lineId, t.lineName, s1.stationName as originName, s2.stationName as destName, t.departureTime, t.arrivalTime FROM TrainSchedule t JOIN Station s1 ON t.origin = s1.stationId JOIN Station s2 ON t.destination = s2.stationId WHERE s1.stationName = ? OR s2.stationName = ?");
          ps.setString(1, station);
          ps.setString(2, station);
          rs = ps.executeQuery();
          boolean found = false;
          while (rs.next()) {
            found = true;
      %>
      <tr>
        <td><%= rs.getString("lineId") %></td>
        <td><%= rs.getString("lineName") %></td>
        <td><%= rs.getString("originName") %></td>
        <td><%= rs.getString("destName") %></td>
        <td><%= rs.getString("departureTime") %></td>
        <td><%= rs.getString("arrivalTime") %></td>
      </tr>
      <%
          }
          if (!found) {
      %>
      <tr><td colspan="6" style="text-align:center;color:#bbb;">No schedules found for this station.</td></tr>
      <%
          }
        } catch (Exception e) { %>
      <tr><td colspan="6" style="color:#e53935;text-align:center;">Error: <%= e.getMessage() %></td></tr>
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