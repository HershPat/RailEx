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
      font-size: 25px;
      background-color: #2c2c2c;
      color: #fff;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
    }
    .message {
      background-color: #333;
      padding: 30px;
      border-radius: 8px;
      max-width: 600px;
      text-align: center;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.5);
    }
    .btn-group {
      margin-top: 20px;
    }
    .btn,
    .btn.cancel {
      padding: 10px 20px;
      font-size: 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      text-decoration: none;
      margin: 0 10px;
    }
    .btn {
      background-color: #4CAF50;
      color: #fff;
    }
    }
    .btn:hover {
      opacity: 0.9;
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
  <h1><%= message %></h1>
  <div class="btn-group">
    <a href="dashboard.jsp" class="btn">Dashboard</a>
  </div>
</div>
</body>
</html>