<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

// Import the db_config.php file
require_once 'db_config.php';

// Establish database connection using connectDB()
$connection = connectDB();

// Get data from Flutter App
$username = $_POST['username'];
$password = $_POST['password'];

// Check if username or password is empty
if (empty($username) || empty($password)) {
    echo json_encode([
        "status" => "error",
        "message" => "Both fields are required"
    ]);
    exit;
}

// Query to check login
$query = "SELECT * FROM patient_patient WHERE username = '$username' AND password = '$password'";
$result = mysqli_query($connection, $query);

// Check if patient exists
if (mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);

    // Send success response with user data
    echo json_encode([
        "status" => "success",
        "message" => "Login successful",
        "data" => [
            "id" => $row['id'],
            "username" => $row['username'],
            "email" => $row['email'],
            "gender" => $row['gender']
        ]
    ]);
} else {
    // Send error response
    echo json_encode([
        "status" => "error",
        "message" => "Invalid Username or password"
    ]);
}

mysqli_close($connection);
?>