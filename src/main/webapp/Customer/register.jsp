<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
    <link rel="stylesheet" href="signup.css">
</head>
<body>
	<div>
        <h1 class="header">RailEx</h1>
    <div>
        <div>
            <fieldset class="SignLog">
                <input type="radio" id="signup" name="SignLog" value="signup" checked>
                <label for="signup" class="SignLogButton">Sign Up</label>
            
                <input type="radio" id="login"  name="SignLog" value="login">
                <label for="login" class="SignLogButton">Log In</label>
              </fieldset>
        </div>
        <div class="register-container">
            <div class="register-header">
                <h1>Sign Up</h1>
                <p>Create an account to get started.</p>
            </div>
             
             <% 
             String username = request.getParameter("username");
             String firstname = request.getParameter("firstname");
             String lastname = request.getParameter("lastname");
             String pass = request.getParameter("pass");
             String conpass = request.getParameter("conpass");
             String email = request.getParameter("email");
             String error = null;
             boolean success = false;
             Boolean connect = true;
             if (username != null){
                 if (username.length() > 15) {
                 	error = "Username must be less than or equal to 15 characters.";
                 	connect = false;
                 } 
                 if (firstname.length() > 50) {
                 	error = "First Name must be less than or equal to 50 characters.";
                 	connect = false;
                 } 
                 if (lastname.length() > 50) {
                 	error = "Last Name must be less than or equal to 50 characters.";
                 	connect = false;
                 } 
                 if (pass.length() > 20) {
                 	error = "First Name must be less than or equal to 20 characters.";
                 	connect = false;
                 } 
                 if (email.length() > 150) {
                 	error = "Email must be less than or equal to 150 characters.";
                 	connect = false;
                 }
                 if (!pass.equals(conpass)) {
                  	error = "Password does not match.";
                  	connect = false;
                  }
 
                 	if (connect) {	
                    try {
                        ApplicationDB appdb = new ApplicationDB();
                        Connection conn = appdb.getConnection();

                        PreparedStatement ps = conn.prepareStatement("SELECT * FROM Customer WHERE user = ?");
                        ps.setString(1, username);
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                        	error = "Username already exists!";
                        	rs.close();
                        	ps.close();
                        	conn.close();	
                        } else {
                        	ps = conn.prepareStatement("SELECT * FROM Customer WHERE email = ?");
                            ps.setString(1, email);
                            rs = ps.executeQuery();
                            if (rs.next()) {
                            	error = "Email already exists!";
                            	rs.close();
                            	ps.close();
                            	conn.close();
                            }
                        }
                        
                        if (error == null) {
                            ps = conn.prepareStatement("INSERT INTO Customer (user, firstName, lastName, email, pass)" + 
                        								"VALUES (?, ?, ?, ?, ?)");
                            ps.setString(1, username);
                            ps.setString(2, firstname);
                            ps.setString(3, lastname);
                            ps.setString(4, email);
                            ps.setString(5, pass);

                            ps.executeUpdate();
                            success = true;
                        }
                        rs.close();
                    	ps.close();
                    	conn.close();
                        
                        } catch (Exception ex) {
                    		out.print(ex);
                       		error = "Error Creating the Account.";
                       		
                    	}
                 	}
             } %>
             
             <% if (success) { 
            	 response.sendRedirect("login.jsp?success=true");
             } %>
        <% if (error != null) { %>
            <div class="error">
                <p><%= error %></p>
            </div>
        <% } %>
        
            <div class="register-form">
                <form action="register.jsp" method="POST">
                	<input type="text" name="username" placeholder="Username" required/>
                    <input type="text" name="firstname" placeholder="First Name" required/>
                    <input type="text" name="lastname" placeholder="Last Name" required/>
                    <input type="email" name="email" placeholder="Email" required/>
                    <input type="password" name="pass" placeholder="Password" required/>
                    <input type="password" name="conpass" placeholder="Confirm Password" required/>
                    <button id="custreg" type="submit">Register</button>
                </form>
                </div>
            </div>
        </div>
        <div class="EmpCust-button">
            <button type="button" id="emplogbtn" class="toggle-btn">
                Employee?
            </button>
        </div>
    </div>
    
    <script src="../signup.js"></script>
</body>

</html>