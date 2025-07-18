<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("../login.jsp");
    return;
  }
  String method = request.getMethod();
  String action = request.getParameter("action");
  String editId = request.getParameter("editId");
  String deleteId = request.getParameter("deleteId");
  String message = null;

  // Handle Delete
  if (deleteId != null) {
    try (Connection conn = new ApplicationDB().getConnection();
         PreparedStatement ps = conn.prepareStatement("DELETE FROM TrainSchedule WHERE lineId=?")) {
      ps.setInt(1, Integer.parseInt(deleteId));
      ps.executeUpdate();
      message = "Schedule deleted.";
    } catch (SQLException e) { message = "Error: " + e.getMessage(); }
  }

  // Handle Edit (POST)
  if ("POST".equalsIgnoreCase(method) && action != null && action.equals("edit")) {
    String lineId = request.getParameter("lineId");
    String lineName = request.getParameter("lineName");
    String trainId = request.getParameter("trainId");
    String fare = request.getParameter("fare");
    String originId = request.getParameter("origin");
    String destId = request.getParameter("destination");
    String dep = request.getParameter("departureTime");
    String arr = request.getParameter("arrivalTime");
    try (Connection conn = new ApplicationDB().getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "UPDATE TrainSchedule SET lineName=?, trainId=?, fare=?, origin=?, destination=?, departureTime=?, arrivalTime=? WHERE lineId=?")) {
      ps.setString(1, lineName);
      ps.setString(2, trainId);
      ps.setString(3, fare);
      ps.setString(4, originId);
      ps.setString(5, destId);
      ps.setString(6, dep);
      ps.setString(7, arr);
      ps.setString(8, lineId);
      ps.executeUpdate();
      message = "Schedule updated.";
    } catch (SQLException e) { message = "Error: " + e.getMessage(); }
    editId = null; // Hide form after edit
  }

  // Fetch stations for dropdowns
  java.util.Map<String, String> stations = new java.util.LinkedHashMap<>();
  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT stationId, stationName FROM Station ORDER BY stationName")) {
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      stations.put(rs.getString("stationId"), rs.getString("stationName"));
    }
  } catch (SQLException e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Edit/Delete Train Schedules</title>
  <style>
    body { margin:0; font-family:Roboto,sans-serif; background:#1a1a1a; color:#eee; }
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
    .navbar a:hover { background: #333; color: #fff; }
    .dashboard-container { max-width:1000px; margin:100px auto; padding:20px; margin-left: 240px; margin-top: 80px; }
    .table-admin { width:100%; border-collapse:collapse; background:#2c2c2c; margin-bottom:30px; }
    .table-admin th, .table-admin td { padding:10px; border:1px solid #444; text-align:left; }
    .table-admin th { background:#333; }
    .btn-primary { padding:6px 12px; background:#4CAF50; color:#fff; border:none; border-radius:4px; cursor:pointer; }
    .btn-primary:hover { background:#43a047; }
    .btn-danger { padding:6px 12px; background:#e53935; color:#fff; border:none; border-radius:4px; cursor:pointer; }
    .btn-danger:hover { background:#b71c1c; }
    .form-control { width:100%; padding:8px; margin-bottom:10px; border:1px solid #444; border-radius:4px; background:#1f1f1f; color:#eee; }
    .cancel { margin-left:10px; color:#bbb; text-decoration:none; }
    .cancel:hover { color:#fff; }
  </style>
</head>
<body>
  <div class="navbar">
    <h2>Representative Panel</h2>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="editSchedule.jsp">Edit Train Schedule</a>
    <a href="replyQuestions.jsp">Reply to Customer Questions</a>
    <a href="stationSchedules.jsp">Schedules by Station</a>
    <a href="lineReservations.jsp">Customers by Line & Date</a>
  </div>
  <div class="dashboard-container">
    <h1>Edit/Delete Train Schedules</h1>
    <% if (message != null) { %>
      <div style="margin-bottom:10px;color:#4CAF50;"><%= message %></div>
    <% } %>
    <table class="table-admin">
      <tr>
        <th>Line ID</th><th>Line Name</th><th>Train ID</th><th>Fare</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Arrival</th><th>Actions</th>
      </tr>
      <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
          conn = new ApplicationDB().getConnection();
          String sql = "SELECT t.lineId, t.lineName, t.trainId, t.fare, t.origin, t.destination, t.departureTime, t.arrivalTime, " +
                       "s1.stationName as originName, s2.stationName as destName " +
                       "FROM TrainSchedule t " +
                       "JOIN Station s1 ON t.origin = s1.stationId " +
                       "JOIN Station s2 ON t.destination = s2.stationId " +
                       "ORDER BY t.lineId";
          ps = conn.prepareStatement(sql);
          rs = ps.executeQuery();
          while (rs.next()) {
            String id = rs.getString("lineId");
      %>
      <tr>
        <td><%= id %></td>
        <td><%= rs.getString("lineName") %></td>
        <td><%= rs.getString("trainId") %></td>
        <td><%= rs.getString("fare") %></td>
        <td><%= rs.getString("originName") %></td>
        <td><%= rs.getString("destName") %></td>
        <td><%= rs.getString("departureTime") %></td>
        <td><%= rs.getString("arrivalTime") %></td>
        <td>
          <form method="get" style="display:inline;">
            <input type="hidden" name="editId" value="<%= id %>"/>
            <button class="btn-primary" type="submit">Edit</button>
          </form>
          <form method="post" style="display:inline;">
            <input type="hidden" name="deleteId" value="<%= id %>"/>
            <button class="btn-danger" type="submit" onclick="return confirm('Are you sure you want to delete this schedule?');">Delete</button>
          </form>
        </td>
      </tr>
      <% if (editId != null && editId.equals(id)) {
        // Fetch current values for the edit form
        String curLineName = rs.getString("lineName");
        String curTrainId = rs.getString("trainId");
        String curFare = rs.getString("fare");
        String curOrigin = rs.getString("origin");
        String curDest = rs.getString("destination");
        String curDep = rs.getString("departureTime");
        String curArr = rs.getString("arrivalTime");
      %>
      <tr>
        <td colspan="9">
          <form method="post">
            <input type="hidden" name="action" value="edit"/>
            <input type="hidden" name="lineId" value="<%= id %>"/>
            <input class="form-control" name="lineName" value="<%= curLineName %>" placeholder="Line Name" required/>
            <input class="form-control" name="trainId" value="<%= curTrainId %>" placeholder="Train ID" required/>
            <input class="form-control" name="fare" value="<%= curFare %>" placeholder="Fare" required/>
            <label style="color:#bbb;">Origin Station:</label>
            <select class="form-control" name="origin" required>
              <% for (java.util.Map.Entry<String, String> entry : stations.entrySet()) { %>
                <option value="<%= entry.getKey() %>" <%= entry.getKey().equals(curOrigin) ? "selected" : "" %>><%= entry.getValue() %></option>
              <% } %>
            </select>
            <label style="color:#bbb;">Destination Station:</label>
            <select class="form-control" name="destination" required>
              <% for (java.util.Map.Entry<String, String> entry : stations.entrySet()) { %>
                <option value="<%= entry.getKey() %>" <%= entry.getKey().equals(curDest) ? "selected" : "" %>><%= entry.getValue() %></option>
              <% } %>
            </select>
            <input class="form-control" name="departureTime" value="<%= curDep %>" placeholder="Departure Time (YYYY-MM-DD HH:MM:SS)" required/>
            <input class="form-control" name="arrivalTime" value="<%= curArr %>" placeholder="Arrival Time (YYYY-MM-DD HH:MM:SS)" required/>
            <button class="btn-primary" type="submit">Save Changes</button>
            <a class="cancel" href="editSchedule.jsp">Cancel</a>
          </form>
        </td>
      </tr>
      <% } %>
      <%   }
        } catch (Exception e) { %>
      <tr><td colspan="9" style="color:#e53935;text-align:center;">Error: <%= e.getMessage() %></td></tr>
      <% } finally {
          if (rs != null) try { rs.close(); } catch (Exception ignore) {}
          if (ps != null) try { ps.close(); } catch (Exception ignore) {}
          if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
      %>
    </table>
  </div>
</body>
</html> 