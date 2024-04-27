<?php
$servername = "localhost";
$username   = "root";
$password   = "Khongq11@";
$dbname     = "mypfmdb";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>