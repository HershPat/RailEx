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

  String ssn       = request.getParameter("ssn");
  String u         = request.getParameter("username");
  String p         = request.getParameter("password");
  String firstName = request.getParameter("firstName");
  String lastName  = request.getParameter("lastName");
  String isManager = request.getParameter("isManager");

  int nextId = 1;
  try (Connection c0 = new ApplicationDB().getConnection();
       Statement s0   = c0.createStatement();
       ResultSet r0   = s0.executeQuery("SELECT COALESCE(MAX(employeeId),0)+1 FROM Employee"))
  {
    if (r0.next()) nextId = r0.getInt(1);
  } catch (SQLException e) {
    e.printStackTrace();
  }

  Connection conn = null;
  PreparedStatement ps = null;
  try {
    conn = new ApplicationDB().getConnection();
    ps = conn.prepareStatement("INSERT INTO Employee (SSN, firstName, lastName, user, pass, isManager) VALUES (?, ?, ?, ?, ?, ?)");
    ps.setString(1, ssn);
    ps.setString(2, firstName);
    ps.setString(3, lastName);
    ps.setString(4, u);
    ps.setString(5, p);
    ps.setInt(6, Integer.parseInt(isManager));
    ps.executeUpdate();
  } catch (Exception e) {
    e.printStackTrace();
  } finally {
    try {
      if (ps != null) ps.close();
      if (conn != null) conn.close();
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

  response.sendRedirect("manageReps.jsp");
%>
