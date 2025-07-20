<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("../login.jsp");
    return;
  }
  String username = (String) session.getAttribute("username");
  String station = request.getParameter("station");

  java.util.Map<String, String> stations = new java.util.LinkedHashMap<>();
  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT stationId, stationName FROM Station ORDER BY stationName")) {
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      stations.put(rs.getString("stationName"), rs.getString("stationName"));
    }
  } catch (SQLException e) { e.printStackTrace(); }

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
    .station-search input, .station-search select { padding:8px; width:300px; border-radius:4px; border:1px solid #444; background:#222; color:#eee; }
    .station-search button { padding:8px 12px; background:#4CAF50; color:#fff; border:none; border-radius:4px; cursor:pointer; }
    .station-search button:hover { background:#43a047; }
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
    <a href="replyQuestions.jsp">Reply to Customer Questions</a>
    <a href="stationSchedules.jsp">Schedules by Station</a>
    <a href="lineReservations.jsp">Customers by Line & Date</a>
  </div>

  <header class="site-header">
    <h1>Station Schedules</h1>
    <div class="top-right">
      <p>Welcome, <%= username %></p>
      <form method="post">
        <button id="logout" name="log" type="submit">Log Out</button>
      </form>
    </div>
  </header>

  <div class="dashboard-container">
    <div class="section-title">Schedules for Station</div>
    <form class="station-search" method="get">
      <select name="station" required>
        <option value="">Select Station</option>
        <% for (java.util.Map.Entry<String, String> entry : stations.entrySet()) { %>
          <option value="<%= entry.getKey() %>" <%= entry.getKey().equals(station) ? "selected" : "" %>><%= entry.getValue() %></option>
        <% } %>
      </select>
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