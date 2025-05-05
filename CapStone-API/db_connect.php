<?php
$host = "localhost";
$username = "root"; // Replace with your MySQL username
$password = "root@123"; // Replace with your MySQL password
$database = "capstone";

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    header('Content-Type: application/json');
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
    exit();
}
?>