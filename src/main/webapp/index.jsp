<html>
<body>
<h2>Maven JSP and Servlet Hello World</h2>
Hostname: <%=System.getenv("HOSTNAME")%>
<form action="HelloWorld" method="post">
    Enter Name: <input type="text" name="name" size="20">
    <input type="submit" value="Say Hello" />
</form>
</body>
</html>