<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
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
  <title>Manage Representatives</title>
  <style>
    body { margin:0; font-family:Roboto,sans-serif; background:#1a1a1a; color:#eee; }
    .site-header {
      background:#2c2c2c; padding:0 20px; display:flex;
      justify-content:space-between; align-items:center; height:60px;
      box-shadow:0 2px 4px rgba(0,0,0,0.5);
      position:fixed; width:calc(100% - 240px); left:240px; top:0; z-index:10;
    }
    .site-header h1 { margin:0; font-size:2rem; }
    .top-right { display:flex; align-items:center; }
    .top-right p { margin:0 15px 0 0; font-size:1.2rem; line-height:1; }
    #logout {
      background:#e53935; border:none; padding:8px 16px; font-size:1rem;
      color:#fff; border-radius:4px; cursor:pointer; transition:.2s; line-height:1;
    }
    #logout:hover { background:#d32f2f; }
    .navbar {
      background:#1c1c1c; width:240px; position:fixed; top:0; left:0;
      height:100vh; padding-top:60px; box-shadow:2px 0 5px rgba(0,0,0,0.7);
    }
    .navbar h2 { color:#4CAF50; text-align:center; margin:20px 0; font-size:1.4rem; }
    .navbar a {
      display:block; padding:12px 20px; color:#bbb;
      text-decoration:none; transition:.2s;
    }
    .navbar a:hover { background:#333; color:#fff; }
    .dashboard-container {
      margin-left:240px; margin-top:60px; padding:20px;
      max-width:calc(100% - 260px);
    }
    .section-title { color:#4CAF50; font-size:1.5rem; margin:20px 0 10px; }
    .form-control {
      width:100%; padding:8px; margin-bottom:10px;
      border:1px solid #444; border-radius:4px;
      background:#1f1f1f; color:#eee; font-size:1rem;
    }
    .btn {
      padding:8px 12px; border:none; border-radius:4px;
      cursor:pointer; font-size:.9rem; transition:.2s;
    }
    .btn-primary { background:#4CAF50; color:#fff; }
    .btn-primary:hover { background:#43a047; }
    .btn-danger { background:#e53935; color:#fff; }
    .btn-danger:hover { background:#d32f2f; }
    .table-admin {
      width:100%; border-collapse:collapse; background:#2c2c2c; margin-top:10px;
    }
    .table-admin th, .table-admin td {
      padding:10px; border:1px solid #444; text-align:left;
    }
    .table-admin th { background:#333; }
  </style>
</head>
<body>

  <div class="navbar">
    <h2>Admin Panel</h2>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="manageReps.jsp">Manage Representatives</a>
    <a href="salesReport.jsp">Sales Reports</a>
    <a href="reservationReport.jsp">Reservation Reports</a>
    <a href="revenueReport.jsp">Revenue Reports</a>
    <a href="bestCustomer.jsp">Best Customer</a>
    <a href="topTransit.jsp">Top 5 Transit Lines</a>
  </div>

  <header class="site-header">
    <h1>RailEx Admin</h1>
    <div class="top-right">
      <p>Welcome, <%= username %></p>
      <form method="post">
        <button id="logout" name="log" type="submit">Log Out</button>
      </form>
    </div>
  </header>

  <div class="dashboard-container">

    <div class="section-title">Add New Representative</div>
    <form action="addRep.jsp" method="post">
      <input class="form-control" name="ssn"       placeholder="SSN" required/>
      <input class="form-control" name="username"  placeholder="Username" required/>
      <input class="form-control" name="password"  type="password" placeholder="Password" required/>
      <input class="form-control" name="firstName" placeholder="First Name" required/>
      <input class="form-control" name="lastName"  placeholder="Last Name" required/>
      <button class="btn btn-primary">Add Representative</button>
    </form>

    <div class="section-title">Current Representatives</div>
    <table class="table-admin">
      <tr>
        <th>ID</th><th>SSN</th><th>Username</th><th>Name</th><th>Actions</th>
      </tr>
      <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int count = 0;
        try {
          conn = new ApplicationDB().getConnection();
          ps = conn.prepareStatement(
            "SELECT employeeId, SSN, user, firstName, lastName FROM Employee WHERE isManager=0"
          );
          rs = ps.executeQuery();
          while (rs.next()) {
            count++;
      %>
      <tr>
        <td><%= rs.getInt("employeeId") %></td>
        <td><%= rs.getString("SSN") %></td>
        <td><%= rs.getString("user") %></td>
        <td><%= rs.getString("firstName") + " " + rs.getString("lastName") %></td>
        <td>
          <form action="editRep.jsp" method="get" style="display:inline;">
            <input type="hidden" name="employeeId" value="<%= rs.getInt("employeeId") %>"/>
            <button class="btn btn-primary">Edit</button>
          </form>
          <form action="deleteRep.jsp" method="post" style="display:inline;"
                onsubmit="return confirm('Are you sure you want to delete this representative?');">
            <input type="hidden" name="employeeId" value="<%= rs.getInt("employeeId") %>"/>
            <button class="btn btn-danger">Delete</button>
          </form>
        </td>
      </tr>
      <%
          }
          if (count == 0) {
      %>
      <tr>
        <td colspan="5" style="text-align:center;color:#bbb;">
          No representatives found.
        </td>
      </tr>
      <%
          }
        } catch (Exception e) {
          out.println("<tr><td colspan='5' style='color:#e53935;text-align:center;'>"
                    + "Error: " + e.getMessage() + "</td></tr>");
        } finally {
          if (rs != null) try { rs.close(); } catch (Exception ignore) {}
          if (ps != null) try { ps.close(); } catch (Exception ignore) {}
          if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
      %>
    </table>
  </div>
</body>
</html>
