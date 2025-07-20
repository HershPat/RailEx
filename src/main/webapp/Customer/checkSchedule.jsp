<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"
    import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Check Schedule</title>
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
    input, select, textarea {
      width: 100%;
      padding: 10px;
      margin-bottom: 16px;
      border-radius: 4px;
      border: 1px solid #444;
      background: #222;
      color: #eee;
      font-size: 1rem;
    }
    button, .btn {
      padding: 10px 18px;
      background: #4CAF50;
      color: #fff;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 1rem;
      transition: background .2s;
    }
    button:hover, .btn:hover {
      background: #388e3c;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background: #232323;
      border-radius: 6px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      margin-bottom: 24px;
    }
    th, td {
      padding: 14px 10px;
      border-bottom: 1px solid #333;
      text-align: left;
    }
    th {
      background: #222;
      color: #4CAF50;
      font-size: 1.1rem;
    }
    tr:last-child td {
      border-bottom: none;
    }
    .no-results {
      text-align: center;
      color: #888;
      padding: 24px 0;
    }
  </style>
</head>
<body>
  <header class="site-header">
    <h1>Schedule Search</h1>
  </header>
  <div class="dashboard-container">
    <a href="dashboard.jsp" class="back-btn">&larr; Back to Dashboard</a>
    <%
        String origin = request.getParameter("origin").trim();
        String destination = request.getParameter("destination").trim();
        String date = request.getParameter("date");
        String sort = request.getParameter("sort");
        String orderBy = "so_d.stopArrivalTime";
        if ("departureTime".equals(sort)) orderBy = "so_o.stopDepartureTime";
        else if ("fare".equals(sort)) orderBy = "ts.fare";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        SimpleDateFormat fmt = new SimpleDateFormat("HH:mm:ss");
        try {
            conn = new ApplicationDB().getConnection();
            String sql =
                "SELECT DISTINCT " +
                "  ts.lineId, ts.trainId, " +
                "  o.stationName AS Origin, so_o.stopStation AS originStopId, so_o.stopIndex AS startIndex, " +
                "  d.stationName AS Destination, so_d.stopStation AS destinationStopId, so_d.stopIndex AS endIndex, " +
                "  so_o.totalStops, ts.fare AS totalFare, " +
                "  so_o.stopDepartureTime AS Departure, so_d.stopArrivalTime AS Arrival " +
                "FROM trainschedule ts " +
                "JOIN (" +
                "    SELECT stopLine, stopStation, stopDepartureTime, " +
                "           ROW_NUMBER() OVER (PARTITION BY stopLine ORDER BY stopDepartureTime) AS stopIndex, " +
                "           COUNT(*) OVER (PARTITION BY stopLine) AS totalStops " +
                "    FROM stopsat" +
                ") so_o ON ts.lineId = so_o.stopLine " +
                "JOIN station o ON so_o.stopStation = o.stationId " +
                "JOIN (" +
                "    SELECT stopLine, stopStation, stopArrivalTime, " +
                "           ROW_NUMBER() OVER (PARTITION BY stopLine ORDER BY stopDepartureTime) AS stopIndex " +
                "    FROM stopsat" +
                ") so_d ON ts.lineId = so_d.stopLine " +
                "JOIN station d ON so_d.stopStation = d.stationId " +
                "WHERE DATE(so_o.stopDepartureTime) = ? " +
                "  AND DATE(so_d.stopArrivalTime) = ? " +
                "  AND o.stationName = ? " +
                "  AND d.stationName = ? " +
                "  AND so_o.stopDepartureTime < so_d.stopArrivalTime " +
                "ORDER BY " + orderBy + " ASC";
            ps = conn.prepareStatement(sql);
            ps.setString(1, date);
            ps.setString(2, date);
            ps.setString(3, origin);
            ps.setString(4, destination);
            rs = ps.executeQuery();
%>
<div class="dashboard-container">
    <h1>Trains: <%= origin %> to <%= destination %> on <%= date %></h1>
    <table>
        <thead>
            <tr>
                <th>Train ID</th>
                <th>Origin</th>
                <th>Departure</th>
                <th>Destination</th>
                <th>Arrival</th>
                <th>Fare</th>
                <th>Reserve</th>
            </tr>
        </thead>
        <tbody>
            <% while (rs.next()) {
                int start = rs.getInt("startIndex");
                int end = rs.getInt("endIndex");
                int stopsCount = rs.getInt("totalStops");
                double totalFare = rs.getDouble("totalFare");
                double segmentFare = totalFare / (stopsCount - 1) * (end - start);
            %>
            <tr>
                <td><%= rs.getInt("trainId") %></td>
                <td><%= rs.getString("Origin") %></td>
                <td><%= fmt.format(rs.getTimestamp("Departure")) %></td>
                <td><%= rs.getString("Destination") %></td>
                <td><%= fmt.format(rs.getTimestamp("Arrival")) %></td>
                <td>$<%= String.format("%.2f", segmentFare) %></td>
                <td>
                    <form action="confirmReservation.jsp" method="POST">
                        <input type="hidden" name="originStopId" value="<%= rs.getInt("originStopId") %>" />
                        <input type="hidden" name="destinationStopId" value="<%= rs.getInt("destinationStopId") %>" />
                        <input type="hidden" name="fare" value="<%= segmentFare %>" />
                        <input type="hidden" name="reserve" value="<%= rs.getInt("lineId") %>" />
                        <button type="submit" class="reserve-button">Reserve</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
</div>
</body>
</html>
