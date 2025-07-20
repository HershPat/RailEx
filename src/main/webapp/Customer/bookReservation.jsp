<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Book Reservation</title>
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
    .container {
      background: #181818;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
      padding: 32px 24px;
      max-width: 700px;
      margin: 0 auto 32px auto;
    }
    .summary {
      margin-bottom: 28px;
      padding: 20px 20px;
      background: #232323;
      border-radius: 8px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.08);
      display: block;
    }
    .summary-row {
      display: flex;
      align-items: center;
      font-size: 1.08rem;
      margin: 0 0 8px 0;
      padding: 0;
      border-bottom: none;
    }
    .summary-label {
      color: #aaa;
      min-width: 140px;
      font-weight: 500;
      margin-right: 10px;
    }
    .summary-value {
      color: #fff;
      font-weight: 400;
    }
    .summary-total {
      text-align: left;
      font-size: 1.2rem;
      font-weight: bold;
      color: #fff;
      margin-top: 16px;
      margin-bottom: 0;
      letter-spacing: 0.5px;
    }
    .btn-group {
      display: flex;
      gap: 16px;
      align-items: center;
      margin-top: 18px;
      justify-content: flex-start;
    }
    .btn {
      font-weight: 500;
      letter-spacing: 0.5px;
    }
    .btn.cancel {
      background: #b71c1c;
      color: #fff;
      margin-left: 12px;
      border: none;
      border-radius: 4px;
      padding: 10px 18px;
      font-size: 1rem;
      font-weight: 500;
      letter-spacing: 0.5px;
      cursor: pointer;
      transition: background .2s;
      height: auto;
      display: inline-flex;
      align-items: center;
      box-shadow: none;
      text-decoration: none;
    }
    .btn.cancel:hover {
      background: #c62828;
    }
    .btn:active {
      transform: translateY(1px) scale(0.98);
      box-shadow: none;
    }
  </style>
</head>
<body>
  <header class="site-header">
    <h1>Book Reservation</h1>
  </header>
  <div class="dashboard-container">
    <%
	int fareDiscount = 0;
    int lineId = Integer.parseInt(request.getParameter("reserve"));
    int originStopId = Integer.parseInt(request.getParameter("originStopId"));
    int destinationStopId = Integer.parseInt(request.getParameter("destinationStopId"));
    double baseFare = Double.parseDouble(request.getParameter("fare"));
    boolean isRound = "true".equals(request.getParameter("isRound"));
    String pType = request.getParameter("passengerType");

    String lineName = "";
    String originStopName = "";
    String destinationStopName = "";
    try (Connection conn = new ApplicationDB().getConnection()) {
      try (PreparedStatement ps = conn.prepareStatement("SELECT lineName FROM TrainSchedule WHERE lineId = ?")) {
        ps.setInt(1, lineId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) lineName = rs.getString("lineName");
        }
      }
      try (PreparedStatement ps = conn.prepareStatement("SELECT stationName FROM Station WHERE stationId = ?")) {
        ps.setInt(1, originStopId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) originStopName = rs.getString("stationName");
        }
      }
      try (PreparedStatement ps = conn.prepareStatement("SELECT stationName FROM Station WHERE stationId = ?")) {
        ps.setInt(1, destinationStopId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) destinationStopName = rs.getString("stationName");
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }

    double finalFare = baseFare;
    if (isRound) {
        finalFare *= 2;
    }
    switch (pType) {
        case "child":
            finalFare *= 0.75;
            fareDiscount = 25;
            break;
        case "senior":
            finalFare *= 0.65;
            fareDiscount = 35;
            break;
        case "disabled":
            finalFare *= 0.50;
            fareDiscount = 50;
            break;
        default:
            break;
    }
    finalFare = Math.round(finalFare * 100.0) / 100.0;
%>
<div class="container">
    <div class="summary">
      <div class="summary-row">
        <span class="summary-label">Line:</span>
        <span class="summary-value"><%= lineName %></span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Origin Station:</span>
        <span class="summary-value"><%= originStopName %></span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Destination Station:</span>
        <span class="summary-value"><%= destinationStopName %></span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Round Trip:</span>
        <span class="summary-value"><%= isRound ? "Yes" : "No" %></span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Passenger Type:</span>
        <span class="summary-value"><%= pType.substring(0, 1).toUpperCase() + pType.substring(1) %></span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Original Fare:</span>
        <span class="summary-value">$<%= String.format("%.2f", isRound ? baseFare * 2 : baseFare) %></span>
      </div>
      <div class="summary-row">
        <span class="summary-label">Discount:</span>
        <span class="summary-value"><%= pType.equals("child") ? "25% off" : pType.equals("senior") ? "35% off" : pType.equals("disabled") ? "50% off" : "None" %></span>
      </div>
      <div class="summary-total">
        Total Fare: $<%= String.format("%.2f", finalFare) %>
      </div>
    </div>

    <div class="btn-group">
        <form action="createReservation.jsp" method="POST">
            <input type="hidden" name="reserve" value="<%= lineId %>" />
            <input type="hidden" name="originStopId" value="<%= originStopId %>" />
            <input type="hidden" name="destinationStopId" value="<%= destinationStopId %>" />
            <input type="hidden" name="fare" value="<%= finalFare %>" />
            <input type="hidden" name="isRound" value="<%= isRound %>" />
            <input type="hidden" name="fareDiscount" value="<%= fareDiscount %>" />
            <button type="submit" class="btn">Confirm Booking</button>
        </form>

        <a href="dashboard.jsp" class="btn cancel">Cancel</a>
    </div>
</div>
  </div>
</body>
</html>