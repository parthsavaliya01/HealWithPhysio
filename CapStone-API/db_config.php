<?php
function connectDB() {
    $servername = "localhost";  // Change if using a different server
    $username = "root";         // Default XAMPP username
    $password = "root@123";             // Default XAMPP password (empty)
    $dbname = "capstone";       // Change to your actual database name

    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
    }
    
    return $conn;
}
?>