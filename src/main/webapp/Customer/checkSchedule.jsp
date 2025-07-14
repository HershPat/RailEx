<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <%
    	
    	String origin = request.getParameter("origin");
   	 	String destination = request.getParameter("destination");
   	 	String date = request.getParameter("date");
   	 %>
   	 <div> <%=origin %></div>
   	 <div> <%=destination %></div>
   	 <div> <%=date %></div>
    	