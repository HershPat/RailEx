<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    body {
      margin: 0;
      font-family: 'Roboto', sans-serif;
      font-size: 25px;
      background: #2c2c2c;
      color: #f1f1f1;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 20px;
    }

    .container {
      width: 100%;
      max-width: 800px;
    }

    h1,
    p {
      text-align: center;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
    }

    th,
    td {
      border: 1px solid #555;
      padding: 8px;
      text-align: left;
    }

    .actions {
      display: flex;
      justify-content: space-around;
      margin: 20px 0;
    }

    .btn {
      background: #4CAF50;
      color: #fff;
      border: none;
      padding: 10px 20px;
      font-size: 20px;
      border-radius: 4px;
      cursor: pointer;
      text-decoration: none;
      text-align: center;
    }

    .btn.cancel {
      background: #f44336;
    }

    .btn:hover {
      opacity: 0.9;
    }
  </style>

  <title>Confirm Reservation</title>
</head>

<body>
  <%
    session = request.getSession(false);
    Integer customerId = (session != null)
        ? (Integer) session.getAttribute("customerId")
        : null;

    if (customerId == null) {
      response.sendRedirect("login.jsp");
      return;
    }

    int scheduleLineId = Integer.parseInt(
        request.getParameter("scheduleLineId")
    );

    int originStopId = Integer.parseInt(
        request.getParameter("originStopId")
    );

    int destinationStopId = Integer.parseInt(
        request.getParameter("destinationStopId")
    );

    float totalFare = Float.parseFloat(
        request.getParameter("totalFare")
    );

    int fareDiscount = (request.getParameter("fareDiscount") != null)
        ? Integer.parseInt(request.getParameter("fareDiscount"))
        : 0;

    boolean isRound = "true".equals(
        request.getParameter("isRound")
    );

    List<Map<String, Object>> stops = new ArrayList<>();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
      ApplicationDB appdb = new ApplicationDB();
      conn = appdb.getConnection();

      String stopSql =
          "SELECT s.stationName, sa.stopDepartureTime, sa.stopArrivalTime " +
          "FROM stopsat sa " +
          "JOIN station s ON sa.stopStation = s.stationId " +
          "WHERE sa.stopLine = ? " +
          "ORDER BY sa.stopIndex";

      ps = conn.prepareStatement(stopSql);
      ps.setInt(1, scheduleLineId);
      rs = ps.executeQuery();

      while (rs.next()) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", rs.getString("stationName"));
        m.put("depart", rs.getTimestamp("stopDepartureTime"));
        m.put("arrive", rs.getTimestamp("stopArrivalTime"));
        stops.add(m);
      }
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (rs != null) try { rs.close(); } catch (Exception ignore) {}
      if (ps != null) try { ps.close(); } catch (Exception ignore) {}
      if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
  %>

  <div class="container">
    <h1>Confirm Your Reservation</h1>

    <p>
      Customer ID: <%= customerId %><br>
      Line ID: <%= scheduleLineId %><br>
      Origin Stop: <%= originStopId %> → Destination Stop: <%= destinationStopId %>
    </p>

    <p>
      Total Fare: $<%= String.format("%.2f", totalFare) %><br>
      Discount: <%= fareDiscount %>%<br>
      Round Trip: <%= isRound ? "Yes" : "No" %>
    </p>

    <h2>Stops on This Route</h2>
    <table>
      <tr>
        <th>Station</th>
        <th>Departure</th>
        <th>Arrival</th>
      </tr>
      <% for (Map<String, Object> stop : stops) { %>
      <tr>
        <td><%= stop.get("name") %></td>
        <td><%= stop.get("depart") %></td>
        <td><%= stop.get("arrive") %></td>
      </tr>
      <% } %>
    </table>

    <div class="actions">
      <form action="createReservation.jsp" method="post">
        <input type="hidden" name="scheduleLineId" value="<%= scheduleLineId %>">
        <input type="hidden" name="originStopId" value="<%= originStopId %>">
        <input type="hidden" name="destinationStopId" value="<%= destinationStopId %>">
        <input type="hidden" name="totalFare" value="<%= totalFare %>">
        <input type="hidden" name="fareDiscount" value="<%= fareDiscount %>">
        <input type="hidden" name="isRound" value="<%= isRound %>">

        <button type="submit" class="btn">Confirm</button>
      </form>

      <a href="dashboard.jsp" class="btn cancel">Cancel</a>
    </div>
  </div>
</body>
</html>
