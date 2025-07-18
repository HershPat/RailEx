<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*"%>
<%
    if(session == null || session.getAttribute("username") == null){
        response.sendRedirect("../login.jsp");
        return;
    }
    String username = (String)session.getAttribute("username");
    if(request.getParameter("log") != null){
        session.invalidate();
        response.sendRedirect("../login.jsp?logout=true");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RailEx Representative Dashboard</title>
    <style>
        body {
            margin: 0;
            font-family: 'Roboto', sans-serif;
            background: #1a1a1a;
            color: #eee;
        }
        .navbar {
            background: #1c1c1c;
            width: 240px;
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            padding-top: 80px;
            box-shadow: 2px 0 5px rgba(0,0,0,0.7);
        }
        .navbar h2 {
            color: #4CAF50;
            text-align: center;
            margin: 20px 0;
            font-size: 1.4rem;
        }
        .navbar a {
            display: block;
            padding: 12px 20px;
            color: #bbb;
            text-decoration: none;
            transition: background .2s, color .2s;
        }
        .navbar a:hover {
            background: #333;
            color: #fff;
        }
        .dashboard-container {
            margin-left: 240px;
            margin-top: 80px;
            padding: 20px;
            max-width: calc(100% - 260px);
        }
        .section-title {
            color: #4CAF50;
            font-size: 1.5rem;
            margin: 20px 0 10px;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="navbar">
        <h2>Representative Panel</h2>
        <a href="dashboard.jsp">Dashboard</a>
        <a href="editSchedule.jsp">Edit Train Schedule</a>
        <a href="replyQuestions.jsp">Reply to Customer Questions</a>
        <a href="stationSchedules.jsp">Schedules by Station</a>
        <a href="lineReservations.jsp">Customers by Line & Date</a>
    </div>

    <!-- Header -->
    <header class="site-header">
        <h1>RailEx Representative</h1>
        <div class="top-right">
            <p>Welcome, <%=username %></p>
            <form method="post">
                <button id="logout" name="log" type="submit">Log Out</button>
            </form>
        </div>
    </header>

    <!-- Main Content -->
    <div class="dashboard-container">
        <div class="section-title">Dashboard</div>
        <p>This is the representative dashboard. Use the sidebar to navigate.</p>
    </div>
</body>
</html>