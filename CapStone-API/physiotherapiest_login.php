<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");

// Import the db_config.php file
require_once 'db_config.php';

// Establish database connection using connectDB()
$conn = connectDB();

// Get data from Flutter app
$username = $_POST['username'];
$password = $_POST['password'];

// Query to check email and password
$sql = "SELECT * FROM physio_physiotherapist WHERE username = '$username' AND password = '$password'";
$result = mysqli_query($conn, $sql);

// Check if user exists
if (mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    echo json_encode(array(
        "status" => "success",
        "message" => "Login successful",
        "user_id" => $row['id'],
        "username" => $row['username'],
        "email" => $row['email']
    ));
} else {
    echo json_encode(array(
        "status" => "error",
        "message" => "Invalid email or password"
    ));
}

// Close connection
mysqli_close($conn);
?>