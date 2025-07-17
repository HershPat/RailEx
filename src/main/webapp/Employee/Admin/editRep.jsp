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

  String method = request.getMethod();
  int    id     = Integer.parseInt(request.getParameter("employeeId"));

  if ("POST".equalsIgnoreCase(method)) {
    String ssn       = request.getParameter("ssn");
    String f         = request.getParameter("firstName");
    String l         = request.getParameter("lastName");
    String u         = request.getParameter("username");
    String p         = request.getParameter("password");

    try (Connection conn = new ApplicationDB().getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "UPDATE Employee SET SSN=?,firstName=?,lastName=?,user=?,pass=? " +
           "WHERE employeeId=? AND isManager=0"))
    {
      ps.setString(1, ssn);
      ps.setString(2, f);
      ps.setString(3, l);
      ps.setString(4, u);
      ps.setString(5, p);
      ps.setInt(6, id);
      ps.executeUpdate();
    } catch (SQLException e) {
      e.printStackTrace();
    }

    response.sendRedirect("manageReps.jsp");
    return;
  }

  String curSSN = "", curF = "", curL = "", curU = "", curP = "";
  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT SSN,firstName,lastName,user,pass FROM Employee " +
         "WHERE employeeId=? AND isManager=0"))
  {
    ps.setInt(1, id);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        curSSN = rs.getString("SSN");
        curF   = rs.getString("firstName");
        curL   = rs.getString("lastName");
        curU   = rs.getString("user");
        curP   = rs.getString("pass");
      }
    }
  } catch (SQLException e) {
    e.printStackTrace();
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Edit Representative</title>
  <style>
    body { margin:0; font-family:Roboto,sans-serif; background:#1a1a1a; color:#eee; }
    .dashboard-container { max-width:600px; margin:100px auto; padding:20px; }
    .form-control {
      width:100%; padding:8px; margin-bottom:10px;
      border:1px solid #444; border-radius:4px;
      background:#1f1f1f; color:#eee;
    }
    .btn-primary {
      padding:8px 12px; background:#4CAF50; color:#fff;
      border:none; border-radius:4px; cursor:pointer;
    }
    .btn-primary:hover { background:#43a047; }
    .cancel {
      margin-left:10px; color:#bbb; text-decoration:none;
    }
    .cancel:hover { color:#fff; }
  </style>
</head>
<body>
  <div class="dashboard-container">
    <h1>Edit Representative</h1>
    <form method="post">
      <input type="hidden" name="employeeId" value="<%= id %>"/>
      <input class="form-control" name="ssn"       value="<%= curSSN %>" placeholder="SSN" required/>
      <input class="form-control" name="firstName" value="<%= curF   %>" placeholder="First Name" required/>
      <input class="form-control" name="lastName"  value="<%= curL   %>" placeholder="Last Name" required/>
      <input class="form-control" name="username"  value="<%= curU   %>" placeholder="Username" required/>
      <input class="form-control" name="password"  value="<%= curP   %>" type="password" placeholder="Password" required/>
      <button class="btn-primary" type="submit">Save Changes</button>
      <a class="cancel" href="manageReps.jsp">Cancel</a>
    </form>
  </div>
</body>
</html>
