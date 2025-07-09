<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RailEx</title>
    <style>
        body {
        margin: 0;
        font-family: 'Roboto', sans-serif;
        font-size: 25px;
        background-color: #2c2c2c;
        color: #f1f1f1;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        padding-top: 64px;
        padding-left: 20px;
        padding-right: 20px;
        }

        .site-header {
        position: fixed;
        top: 0;
        left: 0;
        width: 95%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        background-color: #2c2c2c;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        padding-left: 75px;
        padding-right: 75px;
        }

        .site-header {
        margin: 0;
        }
        .top-right {
        display: flex;
        justify-content: center;
        align-items: center;
        }
         .top-right > p {
         padding: 10px;
         }

        #logout {
        font-family: 'Roboto', sans-serif;
        padding: 8px 16px;
        background-color: #66bb6a;
        color: #fff;
        border: none;
        border-radius: 16px;
        cursor: pointer;
        font-size: 25px;
        font-weight: 500;
        transition: background-color 0.2s;
        }

        #logout:hover {
        background-color: #43a047;
        }
        .dashboard-container {
        text-align: center;
        margin-top: 100px;
        }
    </style>
</head>
<body>
		<%
			if(session == null){
				response.sendRedirect("login.jsp");
			}
			String username = (String)session.getAttribute("username");
			
			if(username == null){
				response.sendRedirect("login.jsp");
			}
			
			if(request.getParameter("log") != null){
				session.invalidate();
			    response.sendRedirect("../login.jsp?logout=true");
			}
				%>
    <div>
        <header class="site-header">
            <h1>RailEx</h1>
            <div class="top-right">
            	<p>Welcome <%=username %></p>
	            <form method="post">
	            		<button id="logout" name="log" type="submit">Log Out</button>
            	</form>
            </div>
        </header>
        
    </div>
    <div class="dashboard-container">
    	<h1> Welcome Representative <%=username %>,</h1>
        <p>Manage and Update Customer's bookings.</p>
      </div>
</body>
</html>