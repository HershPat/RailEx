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
            padding: 20px;
        }
        .dashboard-container {
            width: 100%;
            max-width: 900px;
            margin-top: 50px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 8px;
            border: 1px solid #555;
            text-align: left;
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
        .btn-cancel {
            background-color: #f44336;
            color: #fff;
            border: none;
            padding: 10px 20px;
            font-size: 20px;
            border-radius: 4px;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
        }
        .btn-cancel:hover {
            opacity: 0.9;
        }
    </style>
    <title>Train Schedule</title>
</head>
<body>
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
    <a href="dashboard.jsp" class="btn-cancel">Cancel</a>
</div>
<% } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
</body>
</html>
