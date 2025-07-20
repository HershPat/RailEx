<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="com.cs336.pkg.ApplicationDB,java.sql.*" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("../login.jsp");
    return;
  }
  String username = (String) session.getAttribute("username");
  if (request.getParameter("log") != null) {
    session.invalidate();
    response.sendRedirect("../login.jsp?logout=true");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Top 5 Transit Lines</title>
  <style>
    body { margin:0; font-family:'Roboto',sans-serif; background:#1a1a1a; color:#eee; }
    .site-header {
      background:#2c2c2c; padding:0 20px; display:flex;
      justify-content:space-between; align-items:center; height:60px;
      box-shadow:0 2px 4px rgba(0,0,0,0.5);
      position:fixed; left:240px; right:0; top:0; z-index:10;
    }
    .site-header h1 { margin:0; font-size:2rem; }
    .top-right { display:flex; align-items:center; }
    .top-right p { margin:0 15px; font-size:1.2rem; }
    #logout {
      background:#e53935;border:none;padding:8px 16px;
      font-size:1rem;border-radius:4px;cursor:pointer;color:#fff;
      transition:.2s;
    }
    #logout:hover { background:#d32f2f; }

    .navbar {
      background:#1c1c1c;width:240px;position:fixed;
      top:0;left:0;height:100vh;padding-top:60px;
      box-shadow:2px 0 5px rgba(0,0,0,0.7);
    }
    .navbar h2 { color:#4CAF50;text-align:center;margin:20px 0;font-size:1.4rem; }
    .navbar a {
      display:block;padding:12px 20px;color:#bbb;
      text-decoration:none;transition:.2s;
    }
    .navbar a:hover { background:#333;color:#fff; }

    .dashboard-container {
      margin-left:240px;margin-top:60px;padding:20px;
      max-width:calc(100% - 260px);
    }
    .section-title { color:#4CAF50;font-size:1.5rem;margin-bottom:10px; }

    .table-admin {
      width:100%;border-collapse:collapse;background:#2c2c2c;
    }
    .table-admin th, .table-admin td {
      padding:10px;border:1px solid #444;text-align:left;
    }
    .table-admin th { background:#333; }
  </style>
</head>
<body>

  <div class="navbar">
    <h2>Admin Panel</h2>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="manageReps.jsp">Manage Employees</a>
    <a href="salesReport.jsp">Sales Reports</a>
    <a href="reservationReport.jsp">Reservation Reports</a>
    <a href="revenueReport.jsp">Revenue Reports</a>
    <a href="bestCustomer.jsp">Best Customer</a>
    <a href="topTransit.jsp">Top 5 Transit Lines</a>
  </div>

  <header class="site-header">
    <h1>Top 5 Transit Lines</h1>
    <div class="top-right">
      <p>Welcome, <%= username %></p>
      <form method="post">
        <button id="logout" name="log" type="submit">Log Out</button>
      </form>
    </div>
  </header>

  <div class="dashboard-container">
    <div class="section-title">Most Active Lines</div>
    <table class="table-admin">
      <tr>
        <th>Transit Line ID</th>
        <th># Reservations</th>
      </tr>
      <%
        boolean found = false;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
          conn = new ApplicationDB().getConnection();
          ps = conn.prepareStatement(
            "SELECT r.scheduleLineId AS lineId, COUNT(*) AS cnt " +
            "FROM Reservation r " +
            "GROUP BY r.scheduleLineId " +
            "ORDER BY cnt DESC " +
            "LIMIT 5"
          );
          rs = ps.executeQuery();
          while (rs.next()) {
            found = true;
      %>
      <tr>
        <td><%= rs.getInt("lineId") %></td>
        <td><%= rs.getInt("cnt") %></td>
      </tr>
      <%
          }
          if (!found) {
      %>
      <tr>
        <td colspan="2" style="text-align:center;color:#bbb;">
          No data available.
        </td>
      </tr>
      <%
          }
        } catch (Exception e) {
      %>
      <tr>
        <td colspan="2" style="color:#e53935;text-align:center;">
          Error: <%= e.getMessage() %>
        </td>
      </tr>
      <%
        } finally {
          if (rs   != null) try{ rs.close();   } catch(Exception ign){}
          if (ps   != null) try{ ps.close();   } catch(Exception ign){}
          if (conn != null) try{ conn.close(); } catch(Exception ign){}
        }
      %>
    </table>
  </div>

</body>
</html>
