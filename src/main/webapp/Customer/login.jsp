<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="signup.css">
</head>
<body>
   <div>
        <h1 class="header">RailEx</h1>
     <div>
        <div>
            <fieldset class="SignLog">
                <input type="radio" id="signup" name="SignLog" value="signup">
                <label for="signup" class="SignLogButton">Sign Up</label>
              
                <input type="radio" id="login"  name="SignLog" value="login" checked>
                <label for="login" class="SignLogButton">Log In</label>
              </fieldset>
        </div>
        <div class="register-container">
            <div class="register-header">
            <% 
	            String registered = request.getParameter("success");
	            if (registered != null){
            		if (registered.equals("true")) { %>
	                <div class="success">
	                    <p>Successfully created an account!</p>
	                </div>
	            	<% }
            	} %>
            	
            	 <% 
	            String logout = request.getParameter("logout");
	            if (logout != null){
            		if (logout.equals("true")) { %>
	                <div class="success">
	                    <p>Successfully logged out!</p>
	                </div>
	            	<% }
            	} %>
            	
            	 <% 
             		String username = request.getParameter("username");
            	 	String pass = request.getParameter("pass");
            	 	String error = null;
            	 	if (username != null){
            	 		
            	 		try {
                            ApplicationDB appdb = new ApplicationDB();
                            Connection conn = appdb.getConnection();
                            
                            PreparedStatement ps = conn.prepareStatement("SELECT * FROM Customer WHERE user = ?");
                            ps.setString(1, username);
                            ResultSet rs = ps.executeQuery();
                            if(!rs.next()){
                            	error = "Invalid Username!";
                            	} else {
	                            	 ps = conn.prepareStatement("SELECT * FROM Customer WHERE user = ? AND pass = ?");
	                            	 ps.setString(1, username);
	                            	 ps.setString(2, pass);
	                                 rs = ps.executeQuery();
		                                 if(!rs.next()){
		                                 	error = "Invalid Password!";
		                            		} else {
		                            			int customerid = rs.getInt("Customerid");
		                            			session.setAttribute("username", username);
		                            			session.setAttribute("customerid", customerid);
		                            			response.sendRedirect("dashboard.jsp");
		                            		}
                            		}
                            rs.close();
                        	ps.close();
                        	conn.close();
            	 			} catch (Exception ex) {
                    		out.print(ex);
                       		error = "Error logging in.";
                    	}
            	 	}
            	 	
            	 %>
            	<% if (error != null) { %>
            <div class="error">
                <p><%= error %></p>
            </div>
        <% } %>
                <h1>Log In</h1>
                <p>Log in to get started.</p>
                 </div>
            <div class="register-form">
                <form action="login.jsp" method="post">
                    <input type="text" name="username" placeholder="Username" required/>
                    <input type="password" name="pass" placeholder="Password" required/>
                    <button id="custlogin" type="submit">Log In</button>
                </form>
            </div>
        </div>
        <div class="EmpCust-button">
            <button type="button" id="emplogbtn" class="toggle-btn">
                Employee?
            </button>
        </div>
    </div>
    </div>
    <script src="../signup.js"></script>
</body>

</html>