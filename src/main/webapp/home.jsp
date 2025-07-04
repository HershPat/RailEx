<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RailEx</title>
    <style>
    	@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap');
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;

}

body {
    font-family: 'Roboto', sans-serif;
    font-size: 55px;
    background-color: #2c2c2c;
    color: #f1f1f1;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    padding: 20px;
    padding-top: 64px;
    
  }
  button {
    font-family: 'Roboto', sans-serif;
    padding: 8px 16px;
    background-color: #66bb6a;
    color: #fff;
    border: none;
    border-radius: 16px;
    cursor: pointer;
    font-size: 30px;
    font-weight: 500;
    transition: background-color 0.2s;
    display: block;
    margin: 0 auto;
  }
  button:hover {
    background-color: #43a047;
  }
  </style>
</head>
<body>
    <div>
        <div>
            <h1> Welcome To RailEx</h1>
        </div>
        <button id="start" type="submit">Get Started</button>
    </div>
    <script>
    const btn = document.getElementById('start');
    btn.addEventListener('click', () => {
        window.location.href = 'Customer/login.jsp';
    });
    </script>
</body>
</html>