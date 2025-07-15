<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.io.*, java.util.*, java.sql.*, java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      margin: 0;
      font-family: 'Roboto', sans-serif;
      font-size: 25px;
      background-color: #2c2c2c;
      color: #f1f1f1;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 0 20px;
    }
    .site-header {
      position: fixed;
      top: 0;
      left: 0;
      width: 95%;
      display: flex;
      justify-content: space-between;
      align-items: center;
      background-color: #2c2c2c;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
      padding: 0 75px;
      margin: 0;
    }
    .dashboard-container {
      margin-top: 100px;
    }
    table {
      border-collapse: collapse;
      width: 100%;
    }
    th, td {
      padding: 8px;
      border: 1px solid #555;
    }
    th a {
      color: #fff;
      text-decoration: none;
    }
    .reserve-button {
      background-color: #4CAF50;
      color: #fff;
      border: none;
      padding: 8px 16px;
      font-size: 25px;
      border-radius: 4px;
      cursor: pointer;
    }
    .reserve-button:hover {
      background-color: #45A049;
    }
  </style>
  <title>Train Schedule</title>
</head>
<body>
<%
  String origin = request.getParameter("origin").trim();
  String destination = request.getParameter("destination").trim();
  String sortParam = request.getParameter("sort");
  String travelDate = request.getParameter("date");

  String orderBy;
  if ("departureTime".equals(sortParam)) {
    orderBy = "so_o.stopDepartureTime";
  } else if ("fare".equals(sortParam)) {
    orderBy = "ts.fare";
  } else {
    orderBy = "so_d.stopArrivalTime";
  }

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  try {
    ApplicationDB appdb = new ApplicationDB();
    conn = appdb.getConnection();

    String sql =
        "SELECT ts.lineId, ts.trainId AS trainId, o.stationName AS Origin, " +
        "so_o.stopDepartureTime AS Departure, d.stationName AS Destination, " +
        "so_d.stopArrivalTime AS Arrival, " +
        "CASE WHEN (so_d.stopIndex - so_o.stopIndex) <= 0 THEN -1 " +
        "ELSE ROUND(ts.fare / (so_o.totalStops - 1) * (so_d.stopIndex - so_o.stopIndex), 2) END AS Fare " +
        "FROM trainschedule AS ts " +
        "JOIN (" +
        "  SELECT stopLine, stopStation, stopDepartureTime, " +
        "         ROW_NUMBER() OVER (PARTITION BY stopLine ORDER BY stopDepartureTime) AS stopIndex, " +
        "         COUNT(*) OVER (PARTITION BY stopLine) AS totalStops " +
        "  FROM stopsat" +
        ") AS so_o ON ts.lineId = so_o.stopLine " +
        "JOIN station AS o ON so_o.stopStation = o.stationId " +
        "JOIN (" +
        "  SELECT stopLine, stopStation, stopArrivalTime, " +
        "         ROW_NUMBER() OVER (PARTITION BY stopLine ORDER BY stopDepartureTime) AS stopIndex, " +
        "         COUNT(*) OVER (PARTITION BY stopLine) AS totalStops " +
        "  FROM stopsat" +
        ") AS so_d ON ts.lineId = so_d.stopLine " +
        "JOIN station AS d ON so_d.stopStation = d.stationId " +
        "WHERE DATE(so_o.stopDepartureTime) = ? " +
        "  AND DATE(so_d.stopArrivalTime) = ? " +
        "  AND o.stationName = ? " +
        "  AND d.stationName = ? " +
        "  AND so_o.stopDepartureTime < so_d.stopArrivalTime " +
        "ORDER BY " + orderBy + " ASC";

    ps = conn.prepareStatement(sql);
    ps.setString(1, travelDate);
    ps.setString(2, travelDate);
    ps.setString(3, origin);
    ps.setString(4, destination);
    rs = ps.executeQuery();

    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
%>
  <div class="dashboard-container">
    <h1>Trains: <%= origin %> to <%= destination %> on <%= travelDate %></h1>
    <table>
      <tr>
        <th>Train ID</th>
        <th>Origin</th>
        <th>Departure</th>
        <th>Destination</th>
        <th>Arrival</th>
        <th>Fare</th>
        <th>Reserve</th>
      </tr>
      <% while (rs.next()) { %>
      <tr>
        <td><%= rs.getInt("trainId") %></td>
        <td><%= rs.getString("Origin") %></td>
        <td><%= timeFormat.format(rs.getTimestamp("Departure")) %></td>
        <td><%= rs.getString("Destination") %></td>
        <td><%= timeFormat.format(rs.getTimestamp("Arrival")) %></td>
        <td>$<%= String.format("%.2f", rs.getDouble("Fare")) %></td>
        <td>
          <form action="createReservation.jsp" method="POST">
            <input type="hidden" name="reserve" value="<%= rs.getInt("lineId") %>"> 
            <button type="submit" class="reserve-button">Reserve</button>
          </form>
        </td>
      </tr>
      <% } %>
    </table>
    <p><a href="dashboard.jsp">Go Back</a></p>
  </div>
<%
  } catch (SQLException e) {
    e.printStackTrace();
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception ignore) {}
    if (ps != null) try { ps.close(); } catch (Exception ignore) {}
    if (conn != null) try { conn.close(); } catch (Exception ignore) {}
  }
%>
</body>
</html>