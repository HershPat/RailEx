<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Reservation Status</title>
  <style>
    body {
      margin: 0;
      font-family: 'Roboto', sans-serif;
      background: #1a1a1a;
      color: #eee;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0;
    }
    .message {
      background: #232323;
      padding: 36px 32px 32px 32px;
      border-radius: 10px;
      max-width: 420px;
      text-align: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
      margin: 0 auto;
    }
    .status-success {
      color: #43e97b;
      font-size: 2.5rem;
      margin-bottom: 10px;
      display: block;
    }
    .status-error {
      color: #e53935;
      font-size: 2.5rem;
      margin-bottom: 10px;
      display: block;
    }
    .btn-group {
      margin-top: 24px;
    }
    .btn {
      padding: 10px 18px;
      background: #4CAF50;
      color: #fff;
      border: none;
      border-radius: 4px;
      font-size: 1rem;
      font-weight: 500;
      letter-spacing: 0.5px;
      cursor: pointer;
      transition: background .2s;
      text-decoration: none;
      display: inline-block;
      margin: 0 6px;
    }
    .btn:hover {
      background: #388e3c;
    }
  </style>
</head>
<body>
<%
  Integer customerId = (session != null) ? (Integer) session.getAttribute("customerid") : null;
  if (customerId == null) {
    response.sendRedirect("login.jsp");
    return;
  }


  int lineId = Integer.parseInt(request.getParameter("reserve"));
  int originStopId = Integer.parseInt(request.getParameter("originStopId"));
  int destinationStopId = Integer.parseInt(request.getParameter("destinationStopId"));
  double fare = Double.parseDouble(request.getParameter("fare"));
  boolean isRound = Boolean.parseBoolean(request.getParameter("isRound"));
  int fareDiscount = Integer.parseInt(request.getParameter("fareDiscount"));
  String passengerType = request.getParameter("passengerType");

  String message;
  try {
	  Connection conn = new ApplicationDB().getConnection();
	  String sql = "INSERT INTO Reservation (ScheduleLineId, originStopId, destinationStopId, totalFare, isRound, fareDiscount, customerId) " +
		         "VALUES ( ?, ?, ?, ?, ?, ?, ?)";
       PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, lineId);
    ps.setInt(2, originStopId);
    ps.setInt(3, destinationStopId);
    ps.setDouble(4, fare);
    ps.setBoolean(5, isRound);
    ps.setInt(6, fareDiscount);
    ps.setInt(7, customerId);

    int count = ps.executeUpdate();
    ps.close();
    conn.close();
    message = (count > 0) ? "Your reservation was created successfully!" : "Reservation failed. Please try again.";
    
  } catch (SQLException e) {
    e.printStackTrace();
    message = "Error: " + e.getMessage();
  }


%>
<div class="message">
  <% boolean isSuccess = message != null && message.toLowerCase().contains("success"); %>
  <% if (isSuccess) { %>
    <span class="status-success">&#10003;</span>
  <% } else { %>
    <span class="status-error">&#10007;</span>
  <% } %>
  <h1 style="font-size:1.4rem;font-weight:500;margin-bottom:10px;"><%= message %></h1>
  <div class="btn-group">
    <a href="dashboard.jsp" class="btn">Dashboard</a>
  </div>
</div>
</body>
</html>