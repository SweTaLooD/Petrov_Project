<?php
$servername = "212.233.98.71";  
$username = "webuser";          
$password = "password";         
$dbname = "website_db";         

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
?>
