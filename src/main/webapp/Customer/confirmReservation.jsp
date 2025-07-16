<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Confirm Reservation</title>
  <style>
    body {
      margin: 0;
      font-family: 'Roboto', sans-serif;
      font-size: 25px;
      background-color: #2c2c2c;
      color: #fff;
      display: flex;
      justify-content: center;
      padding: 20px;
    }
    .container {
      width: 100%;
      max-width: 800px;
    }
    h1 {
      text-align: center;
      margin-bottom: 20px;
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
    .origin-row {
      background-color: #4CAF50;
      color: #fff;
    }
    .destination-row {
      background-color: #f44336;
      color: #fff;
    }
    .form-group {
      margin-bottom: 15px;
    }
    .form-group label {
      margin-right: 10px;
    }
    .btn {
      background-color: #4CAF50;
      color: #fff;
      border: none;
      padding: 10px 20px;
      font-size: 20px;
      border-radius: 4px;
      cursor: pointer;
      text-decoration: none;
    }
    .btn.cancel {
      background-color: #f44336;
      margin-left: 10px;
    }
    .btn:hover {
      opacity: 0.9;
    }
  </style>
</head>
<body>
<%
  int lineId = Integer.parseInt(request.getParameter("reserve"));
  int originStopId = Integer.parseInt(request.getParameter("originStopId"));
  int destinationStopId = Integer.parseInt(request.getParameter("destinationStopId"));
  double totalFare = Double.parseDouble(request.getParameter("fare"));

 
  List<Map<String,Object>> stops = new ArrayList<>();
  SimpleDateFormat fmt = new SimpleDateFormat("HH:mm:ss");
  String sql =
    "SELECT sa.stopStation AS stationId, s.stationName, " +
    " sa.stopDepartureTime, sa.stopArrivalTime, " +
    " ROW_NUMBER() OVER (PARTITION BY sa.stopLine ORDER BY sa.stopDepartureTime) AS stopIndex, " +
    " COUNT(*) OVER (PARTITION BY sa.stopLine) AS totalStops " +
    "FROM stopsat sa " +
    "JOIN station s ON sa.stopStation = s.stationId " +
    "WHERE sa.stopLine = ? " +
    "ORDER BY sa.stopDepartureTime";
  
  try (
      Connection conn = new ApplicationDB().getConnection();
      PreparedStatement ps = conn.prepareStatement(sql)
  ) {
    ps.setInt(1, lineId);
    
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String,Object> m = new HashMap<>();
        m.put("id", rs.getInt("stationId"));
        m.put("name", rs.getString("stationName"));
        m.put("depart", rs.getTimestamp("stopDepartureTime"));
        m.put("arrive", rs.getTimestamp("stopArrivalTime"));
        m.put("index", rs.getInt("stopIndex"));
        m.put("totalStops", rs.getInt("totalStops"));
        stops.add(m);
      }
    }
  } catch (SQLException e) {
    e.printStackTrace();
  }

  int originIndex = -1;
  int destIndex = -1;
  for (Map<String,Object> m : stops) {
    int sid = (Integer) m.get("id");
    int idx = (Integer) m.get("index");
    if (sid == originStopId) originIndex = idx;
    if (sid == destinationStopId) destIndex = idx;
  }
  double segmentCost = destIndex > originIndex
    ? totalFare / (destIndex - originIndex)
    : 0;
%>
<div class="container">
  <h1>Confirm Your Reservation</h1>
  <table>
    <thead>
      <tr>
        <th>Station</th>
        <th>Departure</th>
        <th>Arrival</th>
        <th>Fare</th>
      </tr>
    </thead>
    <tbody>
      <% for (Map<String,Object> stop : stops) {
        int sid = (Integer)stop.get("id");
        int idx = (Integer)stop.get("index");
        String rowClass = "";
        if (sid == originStopId) rowClass = "origin-row";
        else if (sid == destinationStopId) rowClass = "destination-row";
        double fare = idx > originIndex
          ? segmentCost * (idx - originIndex)
          : -1;
      %>
      <tr class="<%=rowClass%>">
        <td><%=stop.get("name")%></td>
        <td><%=fmt.format(stop.get("depart"))%></td>
        <td><%=fmt.format(stop.get("arrive"))%></td>
        <td><%= fare < 0 ? "-" : String.format("$%.2f", fare) %></td>
      </tr>
      <% } %>
    </tbody>
  </table>
  <form action="bookReservation.jsp" method="POST">
    <input type="hidden" name="reserve" value="<%=lineId%>" />
    <input type="hidden" name="originStopId" value="<%=originStopId%>" />
    <input type="hidden" name="destinationStopId" value="<%=destinationStopId%>" />
    <input type="hidden" name="fare" value="<%=totalFare%>" />
    <div class="form-group">
      <label>Round Trip?</label>
      <label><input type="radio" name="isRound" value="true" /> Yes</label>
      <label><input type="radio" name="isRound" value="false" checked /> No</label>
    </div>
    <div class="form-group">
      <label for="passengerType">Passenger Type:</label>
      <select name="passengerType" id="passengerType">
        <option value="none">None</option>
        <option value="child">Child</option>
        <option value="senior">Senior</option>
        <option value="disabled">Disabled</option>
      </select>
    </div>
    <button type="submit" class="btn">Confirm Reservation</button>
    <a href="dashboard.jsp" class="btn cancel">Cancel</a>
  </form>
</div>
</body>
</html>
