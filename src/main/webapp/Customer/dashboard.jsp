<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RailEx</title>
    <style>
        body {
            margin: 0;
            font-family: 'Roboto', sans-serif;
            background: #1a1a1a;
            color: #eee;
        }
        .site-header {
            background: #2c2c2c;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.5);
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
            transition: background 0.2s;
        }
        #logout:hover {
            background: #d32f2f;
        }
        .dashboard-container {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 80px 20px 40px;
        }
        .card {
            background: #2c2c2c;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.7);
            width: 100%;
            max-width: 600px;
        }
        .card h2 {
            margin-top: 0;
            font-size: 1.8rem;
            text-align: center;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-size: 1rem;
        }
        .form-group input[type="text"],
        .form-group input[type="date"] {
            width: 100%;
            padding: 10px;
            font-size: 1rem;
            border: 1px solid #444;
            border-radius: 4px;
            background: #1f1f1f;
            color: #eee;
        }
        .form-group .radio-group {
            display: flex;
            gap: 20px;
        }
        .form-group .radio-group label {
            display: flex;
            align-items: center;
            font-size: 1rem;
        }
        .form-group .radio-group input {
            margin-right: 8px;
        }
        .btn-primary {
            width: 100%;
            padding: 12px;
            font-size: 1.2rem;
            background: #4CAF50;
            border: none;
            border-radius: 4px;
            color: #fff;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-primary:hover {
            background: #43a047;
        }
    </style>
</head>
<body>
<%
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    if (request.getParameter("log") != null) {
        session.invalidate();
        response.sendRedirect("login.jsp?logout=true");
        return;
    }
%>
<header class="site-header">
    <h1>RailEx</h1>
    <div class="top-right">
        <p>Welcome, <%= username %></p>
        <form method="post">
            <button id="logout" name="log" type="submit">Log Out</button>
        </form>
    </div>
</header>
<div class="dashboard-container">
    <div class="card">
        <h2>Book a Reservation</h2>
        <form action="checkSchedule.jsp" method="post">
            <div class="form-group">
                <label for="origin">Origin</label>
                <input type="text" id="origin" name="origin" placeholder="Enter origin station" required />
            </div>
            <div class="form-group">
                <label for="destination">Destination</label>
                <input type="text" id="destination" name="destination" placeholder="Enter destination station" required />
            </div>
            <div class="form-group">
                <label for="date">Travel Date</label>
                <input type="date" id="date" name="date" required />
            </div>
            <div class="form-group">
                <label>Sort By</label>
                <div class="radio-group">
                    <label><input type="radio" name="sort" value="arrivalTime" checked /> Arrival Time</label>
                    <label><input type="radio" name="sort" value="departureTime" /> Departure Time</label>
                    <label><input type="radio" name="sort" value="fare" /> Fare</label>
                </div>
            </div>
            <button type="submit" class="btn-primary">Search Trains</button>
        </form>
    </div>
</div>
</body>
</html>
