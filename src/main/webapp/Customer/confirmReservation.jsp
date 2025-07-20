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
    tr.origin-row td {
      background: #2e7d32 !important;
      color: #fff !important;
    }
    tr.destination-row td {
      background: #c62828 !important;
      color: #fff !important;
    }
    .container {
      background: #181818;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
      padding: 32px 24px;
      max-width: 700px;
      margin: 0 auto 32px auto;
    }
    .form-group {
      margin-bottom: 18px;
    }
    .btn.cancel {
      background: #b71c1c;
      margin-left: 10px;
    }
    .btn.cancel:hover {
      background: #c62828;
    }
    .roundtrip-group {
      display: flex;
      align-items: center;
      gap: 24px;
      margin-bottom: 18px;
    }
    .roundtrip-group label {
      font-weight: 500;
      margin: 0 8px 0 0;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .roundtrip-title {
      font-weight: bold;
      margin-right: 18px;
      color: #eee;
      font-size: 1.08rem;
    }
    .form-group label[for="passengerType"] {
      margin-bottom: 8px;
      display: inline-block;
      font-weight: 500;
      font-size: 1.08rem;
      margin-right: 18px;
    }
    #passengerType {
      margin-left: 0;
      min-width: 180px;
    }
  </style>
</head>
<body>
  <header class="site-header">
    <h1>Confirm Reservation</h1>
  </header>
  <div class="dashboard-container">
    <a href="dashboard.jsp" class="back-btn">&larr; Back to Dashboard</a>
<%
  int lineId = Integer.parseInt(request.getParameter("reserve"));
  int originStopId = Integer.parseInt(request.getParameter("originStopId"));
  int destinationStopId = Integer.parseInt(request.getParameter("destinationStopId"));
  double totalFare = Double.parseDouble(request.getParameter("fare"));

  String lineName = "";
  try (
      Connection conn = new ApplicationDB().getConnection();
      PreparedStatement ps = conn.prepareStatement("SELECT lineName FROM TrainSchedule WHERE lineId = ?")
  ) {
    ps.setInt(1, lineId);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        lineName = rs.getString("lineName");
      }
    }
  } catch (SQLException e) {
    e.printStackTrace();
  }

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
  String originStopName = "";
  String destinationStopName = "";
  for (Map<String,Object> m : stops) {
    int sid = (Integer) m.get("id");
    int idx = (Integer) m.get("index");
    if (sid == originStopId) {
      originIndex = idx;
      originStopName = (String) m.get("name");
    }
    if (sid == destinationStopId) {
      destIndex = idx;
      destinationStopName = (String) m.get("name");
    }
  }
  double segmentCost = destIndex > originIndex
    ? totalFare / (destIndex - originIndex)
    : 0;
%>
<div class="container">
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
    <div class="form-group roundtrip-group">
      <span class="roundtrip-title">Round Trip?</span>
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
</div>
</body>
</html>
