<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Book Reservation</title>
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
        .container {
            width: 100%;
            max-width: 600px;
            background-color: #333;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.5);
        }
        h1 {
            text-align: center;
            margin-bottom: 20px;
        }
        .summary p {
            margin: 10px 0;
        }
         .btn-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 20px;
        }
        .btn,
        .btn.cancel {
            display: inline-block;
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
        .btn.cancel {
            background-color: #f44336;
            color: #fff;
        }
        .btn:hover,
        .btn.cancel:hover {
            opacity: 0.9;
        }
    </style>
</head>
<body>
<%
	int fareDiscount = 0;
    int lineId = Integer.parseInt(request.getParameter("reserve"));
    int originStopId = Integer.parseInt(request.getParameter("originStopId"));
    int destinationStopId = Integer.parseInt(request.getParameter("destinationStopId"));
    double baseFare = Double.parseDouble(request.getParameter("fare"));
    boolean isRound = "true".equals(request.getParameter("isRound"));
    String pType = request.getParameter("passengerType");

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
    <h1>Book Your Reservation</h1>

    <div class="summary">
        <p>Line ID: <%= lineId %></p>
        <p>Origin Stop ID: <%= originStopId %></p>
        <p>Destination Stop ID: <%= destinationStopId %></p>
        <p>Round Trip: <%= isRound ? "Yes" : "No" %></p>
        <p>Passenger Type: <%= pType.substring(0, 1).toUpperCase() + pType.substring(1) %></p>
        <p>Original Fare: $<%= String.format("%.2f", isRound ? baseFare * 2 : baseFare) %></p>
        <p>Discount: <%= pType.equals("child") ? "25% off" : pType.equals("senior") ? "35% off" : pType.equals("disabled") ? "50% off" : "None" %></p>
        <p>Total Fare: $<%= String.format("%.2f", finalFare) %></p>
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
</body>
</html>