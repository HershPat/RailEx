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

  int nextId = 1;
  try (Connection c0 = new ApplicationDB().getConnection();
       Statement s0   = c0.createStatement();
       ResultSet r0   = s0.executeQuery("SELECT COALESCE(MAX(employeeId),0)+1 FROM Employee"))
  {
    if (r0.next()) nextId = r0.getInt(1);
  } catch (SQLException e) {
    e.printStackTrace();
  }

  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "INSERT INTO Employee(employeeId,SSN,firstName,lastName,user,pass,isManager) " +
         "VALUES(?,?,?,?,?,?,0)"))
  {
    ps.setInt(1, nextId);
    ps.setString(2, ssn);
    ps.setString(3, firstName);
    ps.setString(4, lastName);
    ps.setString(5, u);
    ps.setString(6, p);
    ps.executeUpdate();
  } catch (SQLException e) {
    e.printStackTrace();
  }

  response.sendRedirect("manageReps.jsp");
%>
