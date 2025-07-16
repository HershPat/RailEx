<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javax.servlet.http.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>RailEx Dashboard</title>
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
            max-width: 800px;
            margin: 80px auto 40px;
            padding: 0 20px;
        }
        .section-title {
            color: #4CAF50;
            font-size: 1.5rem;
            margin: 20px 0 10px;
        }
        .reservation-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        .reservation-table th,
        .reservation-table td {
            padding: 8px;
            border: 1px solid #444;
            text-align: left;
        }
        .card {
            background: #2c2c2c;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.7);
            margin-bottom: 40px;
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
        .radio-group {
            display: flex;
            gap: 20px;
        }
        .radio-group label {
            display: flex;
            align-items: center;
            font-size: 1rem;
        }
        .radio-group input {
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
        .btn.cancel {
            display: inline-block;
            padding: 6px;
            font-size: 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            margin: 0 10px;
            background-color: #f44336;
            color: #fff;
        }
        .help-section {
            background: #2c2c2c;
            padding: 20px;
            margin-top: 40px;
            border-radius: 8px;
        }
        .help-section h2 {
            color: #eee;
            margin-bottom: 10px;
            font-size: 1.5rem;
        }
        .help-section textarea {
            width: 100%;
            padding: 8px;
            border-radius: 4px;
            border: none;
            background: #1f1f1f;
            color: #eee;
        }
        .help-section button {
            margin-top: 8px;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            background: #4CAF50;
            color: #fff;
            cursor: pointer;
        }
        .qa-item {
            margin-bottom: 20px;
            padding: 10px;
            background: #333;
            border-radius: 4px;
        }
        .qa-item .question p,
        .qa-item .reply p {
            margin: 5px 0 0 0;
        }
        .qa-item .reply {
            margin-left: 20px;
            color: #ddd;
        }
        .qa-item .pending {
            color: #bbb;
            font-style: italic;
            margin-left: 20px;
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
    int custId = (Integer) session.getAttribute("customerid");
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    String deleteRes = request.getParameter("deleteRerv");
    if (deleteRes != null){
        int deleteResNum = Integer.parseInt(deleteRes);
        Connection conn = null;
        PreparedStatement ps = null;
        try {
             conn = new ApplicationDB().getConnection();
             String deleteSql = "DELETE FROM Reservation WHERE ReservationNumber = ?";
             ps = conn.prepareStatement(deleteSql);
             ps.setInt(1, deleteResNum);
             ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception ignore) {}
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
    }

    String questionMsg = request.getParameter("questionMessage");
    if (questionMsg != null && !questionMsg.trim().isEmpty()) {
        Connection csConn = null;
        PreparedStatement csPs = null;
        try {
            csConn = new ApplicationDB().getConnection();
            String csInsert = "INSERT INTO CustomerService (customerId, questionMessage, questionDate) VALUES (?, ?, NOW())";
            csPs = csConn.prepareStatement(csInsert);
            csPs.setInt(1, custId);
            csPs.setString(2, questionMsg.trim());
            csPs.executeUpdate();
        } catch(SQLException e) {
            e.printStackTrace();
        } finally {
            if (csPs!=null) try { csPs.close(); } catch(SQLException ignore) {}
            if (csConn!=null) try { csConn.close(); } catch(SQLException ignore) {}
        }
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
    <div class="section-title">Upcoming Reservations</div>
    <table class="reservation-table">
        <tr>
            <th>Origin</th>
            <th>Destination</th>
            <th>Departure</th>
            <th>Arrival</th>
            <th>Fare</th>
            <th>Round Trip</th>
            <th>Cancel</th>
        </tr>
        <%
            String upSql =
                "SELECT r.reservationNumber, oi.stationName AS origin, di.stationName AS dest, " +
                "so.stopDepartureTime AS dep, sd.stopArrivalTime AS arr, r.totalFare, r.isRound " +
                "FROM reservation r " +
                "JOIN stopsat so ON r.originStopId = so.stopStation AND so.stopLine = r.ScheduleLineId " +
                "JOIN stopsat sd ON r.destinationStopId = sd.stopStation AND sd.stopLine = r.ScheduleLineId " +
                "JOIN station oi ON so.stopStation = oi.stationId " +
                "JOIN station di ON sd.stopStation = di.stationId " +
                "WHERE r.customerId = ? AND so.stopDepartureTime > NOW() " +
                "ORDER BY so.stopDepartureTime";
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = new ApplicationDB().getConnection();
                ps = conn.prepareStatement(upSql);
                ps.setInt(1, custId);
                rs = ps.executeQuery();
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getString("origin") %></td>
            <td><%= rs.getString("dest") %></td>
            <td><%= fmt.format(rs.getTimestamp("dep")) %></td>
            <td><%= fmt.format(rs.getTimestamp("arr")) %></td>
            <td>$<%= String.format("%.2f", rs.getDouble("totalFare")) %></td>
            <td><%= rs.getBoolean("isRound") ? "Yes" : "No" %></td>
            <td>
                <form method="post">
                    <input type="hidden" name="deleteRerv" value="<%= rs.getInt("reservationNumber") %>"/>
                    <button type="submit" class="btn cancel">Cancel</button>
                </form>
            </td>
        </tr>
        <%
                }
            } catch(SQLException e) {
                e.printStackTrace();
            } finally {
                if (rs!=null) try { rs.close(); } catch(Exception ignore){}
                if (ps!=null) try { ps.close(); } catch(Exception ignore){}
                if (conn!=null) try { conn.close(); } catch(Exception ignore){}
            }
        %>
    </table>
    <div class="section-title">Past Reservations</div>
    <table class="reservation-table">
        <tr>
            <th>Origin</th>
            <th>Destination</th>
            <th>Departure</th>
            <th>Arrival</th>
            <th>Fare</th>
            <th>Round Trip</th>
        </tr>
        <%
            String pastSql = upSql.replace("> NOW()", "<= NOW()");
            Connection conn2 = null;
            PreparedStatement ps2 = null;
            ResultSet rs2 = null;
            try {
                conn2 = new ApplicationDB().getConnection();
                ps2 = conn2.prepareStatement(pastSql);
                ps2.setInt(1, custId);
                rs2 = ps2.executeQuery();
                while (rs2.next()) {
        %>
        <tr>
            <td><%= rs2.getString("origin") %></td>
            <td><%= rs2.getString("dest") %></td>
            <td><%= fmt.format(rs2.getTimestamp("dep")) %></td>
            <td><%= fmt.format(rs2.getTimestamp("arr")) %></td>
            <td>$<%= String.format("%.2f", rs2.getDouble("totalFare")) %></td>
            <td><%= rs2.getBoolean("isRound") ? "Yes" : "No" %></td>
        </tr>
        <%
                }
            } catch(SQLException e) {
                e.printStackTrace();
            } finally {
                if (rs2!=null) try { rs2.close(); } catch(Exception ignore){}
                if (ps2!=null) try { ps2.close(); } catch(Exception ignore){}
                if (conn2!=null) try { conn2.close(); } catch(Exception ignore){}
            }
        %>
    </table>
    <div class="card">
        <h2>Book a Reservation</h2>
        <form action="checkSchedule.jsp" method="post">
            <div class="form-group">
                <label for="origin">Origin</label>
                <input type="text" id="origin" name="origin" placeholder="Enter origin station" required/>
            </div>
            <div class="form-group">
                <label for="destination">Destination</label>
                <input type="text" id="destination" name="destination" placeholder="Enter destination station" required/>
            </div>
            <div class="form-group">
                <label for="date">Travel Date</label>
                <input type="date" id="date" name="date" required/>
            </div>
            <div class="form-group">
                <label>Sort By</label>
                <div class="radio-group">
                    <label><input type="radio" name="sort" value="arrivalTime" checked/> Arrival Time</label>
                    <label><input type="radio" name="sort" value="departureTime"/> Departure Time</label>
                    <label><input type="radio" name="sort" value="fare"/> Fare</label>
                </div>
            </div>
            <button type="submit" class="btn-primary">Search Trains</button>
        </form>
    </div>
    <div class="help-section">
        <h2>Need Help?</h2>
        <form action="dashboard.jsp" method="post">
            <textarea name="questionMessage" rows="4" placeholder="Type your question here…" required></textarea>
            <button type="submit">Submit Question</button>
        </form>
        <%
            Connection csConn2 = null;
            PreparedStatement csPs2 = null;
            ResultSet csRs2 = null;
            try {
                csConn2 = new ApplicationDB().getConnection();
                String csFetch =
                    "SELECT questionDate, questionMessage, replyMessage, replyDate " +
                    "FROM CustomerService WHERE customerId = ? ORDER BY questionDate DESC";
                csPs2 = csConn2.prepareStatement(csFetch);
                csPs2.setInt(1, custId);
                csRs2 = csPs2.executeQuery();
                while (csRs2.next()) {
                    Timestamp qDate = csRs2.getTimestamp("questionDate");
                    String qMsg = csRs2.getString("questionMessage");
                    String rMsg = csRs2.getString("replyMessage");
                    Timestamp rDate = csRs2.getTimestamp("replyDate");
        %>
        <div class="qa-item">
            <div class="question">
                <strong>Q ( <%= qDate %> ):</strong>
                <p><%= qMsg %></p>
            </div>
            <%
                if (rMsg != null && !rMsg.trim().isEmpty()) {
            %>
            <div class="reply">
                <strong>A ( <%= rDate %> ):</strong>
                <p><%= rMsg %></p>
            </div>
            <%
                } else {
            %>
            <div class="pending">Awaiting a reply…</div>
            <%
                }
            %>
        </div>
        <%
                }
            } catch(SQLException e) {
                e.printStackTrace();
            } finally {
                if (csRs2!=null) try { csRs2.close(); } catch(Exception ignore){}
                if (csPs2!=null) try { csPs2.close(); } catch(Exception ignore){}
                if (csConn2!=null) try { csConn2.close(); } catch(Exception ignore){}
            }
        %>
    </div>
</div>
</body>
</html>