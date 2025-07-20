<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="com.cs336.pkg.ApplicationDB,java.sql.*,javax.servlet.http.HttpSession" %>
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
  boolean foundLine = false, foundCust = false;
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Revenue Reports</title>
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
    .navbar h2 {
      color:#4CAF50;text-align:center;margin:20px 0;font-size:1.4rem;
    }
    .navbar a {
      display:block;padding:12px 20px;color:#bbb;
      text-decoration:none;transition:.2s;
    }
    .navbar a:hover { background:#333;color:#fff; }

    .dashboard-container {
      margin-left:240px;margin-top:60px;padding:20px;
      max-width:calc(100% - 260px);
    }
    .section-title { color:#4CAF50;font-size:1.5rem;margin:0 0 10px; }

    .toggle-btns { margin-bottom:20px; }
    .toggle-btn {
      padding:8px 12px;margin-right:10px;border:none;
      border-radius:4px;cursor:pointer;font-size:.9rem;
      background:#444;color:#eee;transition:.2s;
    }
    .toggle-btn.active { background:#4CAF50;color:#fff; }
    .toggle-btn:hover:not(.active) { background:#555; }

    .table-admin {
      width:100%;border-collapse:collapse;background:#2c2c2c;margin-bottom:30px;
    }
    .table-admin th,.table-admin td {
      padding:10px;border:1px solid #444;text-align:left;
    }
    .table-admin th { background:#333; }
    .hidden { display:none; }
  </style>
  <script>
    function showSection(id) {
      document.getElementById('byLine').classList.add('hidden');
      document.getElementById('byCust').classList.add('hidden');
      document.getElementById(id).classList.remove('hidden');
      document.getElementById('btnLine').classList.remove('active');
      document.getElementById('btnCust').classList.remove('active');
      document.getElementById('btn' + (id==='byLine'?'Line':'Cust')).classList.add('active');
    }
    window.addEventListener('DOMContentLoaded', () => showSection('byLine'));
  </script>
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
    <h1>Revenue Reports</h1>
    <div class="top-right">
      <p>Welcome, <%= username %></p>
      <form method="post">
        <button id="logout" name="log">Log Out</button>
      </form>
    </div>
  </header>

  <div class="dashboard-container">
    <div class="section-title">View Revenue</div>
    <div class="toggle-btns">
      <button id="btnLine" class="toggle-btn" onclick="showSection('byLine')">
        By Transit Line
      </button>
      <button id="btnCust" class="toggle-btn" onclick="showSection('byCust')">
        By Customer Name
      </button>
    </div>

    <div id="byLine">
      <table class="table-admin">
        <tr><th>Transit Line ID</th><th>Total Revenue</th></tr>
        <%
          Connection conn = null;
          PreparedStatement ps = null;
          ResultSet rs = null;
          try {
            conn = new ApplicationDB().getConnection();
            ps = conn.prepareStatement(
              "SELECT so.stopLine AS lineId, SUM(r.totalFare) AS total " +
              "FROM reservation r " +
              "  JOIN stopsat so ON r.originStopId = so.stopStation " +
              "    AND so.stopLine = r.scheduleLineId " +
              "GROUP BY so.stopLine " +
              "ORDER BY total DESC"
            );
            rs = ps.executeQuery();
            while (rs.next()) {
              foundLine = true;
        %>
        <tr>
          <td><%= rs.getInt("lineId") %></td>
          <td>$<%= String.format("%.2f", rs.getDouble("total")) %></td>
        </tr>
        <%
            }
            if (!foundLine) {
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
            if (rs   != null) try { rs.close();   } catch(Exception ign){}
            if (ps   != null) try { ps.close();   } catch(Exception ign){}
            if (conn != null) try { conn.close(); } catch(Exception ign){}
          }
        %>
      </table>
    </div>

    <div id="byCust" class="hidden">
      <table class="table-admin">
        <tr><th>Customer Name</th><th>Total Revenue</th></tr>
        <%
          try {
            conn = new ApplicationDB().getConnection();
            ps = conn.prepareStatement(
              "SELECT CONCAT(c.firstName,' ',c.lastName) AS cust, SUM(r.totalFare) AS total " +
              "FROM reservation r " +
              "  JOIN customer c ON r.customerId = c.customerId " +
              "GROUP BY c.customerId " +
              "ORDER BY total DESC"
            );
            rs = ps.executeQuery();
            while (rs.next()) {
              foundCust = true;
        %>
        <tr>
          <td><%= rs.getString("cust") %></td>
          <td>$<%= String.format("%.2f", rs.getDouble("total")) %></td>
        </tr>
        <%
            }
            if (!foundCust) {
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
            if (rs   != null) try { rs.close();   } catch(Exception ign){}
            if (ps   != null) try { ps.close();   } catch(Exception ign){}
            if (conn != null) try { conn.close(); } catch(Exception ign){}
          }
        %>
      </table>
    </div>

  </div>
</body>
</html>
