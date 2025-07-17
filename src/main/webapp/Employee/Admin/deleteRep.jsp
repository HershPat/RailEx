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

  int id = Integer.parseInt(request.getParameter("employeeId"));
  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "DELETE FROM Employee WHERE employeeId=? AND isManager=0"))
  {
    ps.setInt(1, id);
    ps.executeUpdate();
  } catch (SQLException e) {
    e.printStackTrace();
  }

  response.sendRedirect("manageReps.jsp");
%>
