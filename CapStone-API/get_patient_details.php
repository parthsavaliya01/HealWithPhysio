<?php
header("Content-Type: application/json");
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Import the db_config.php file
require_once 'db_config.php';

// Establish database connection using connectDB()
$conn = connectDB();

// Get username from query parameter (e.g., GET request: get_patient_details.php?username=john_doe)
$username = isset($_GET['username']) ? $_GET['username'] : '';

if (empty($username)) {
    echo json_encode(["status" => "error", "message" => "Username is required"]);
    exit();
}

// Query to fetch patient details
$query = "SELECT name, contact_no, email, gender FROM patient_patient WHERE username = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $patient = $result->fetch_assoc();
    echo json_encode(["status" => "success", "data" => $patient]);
} else {
    echo json_encode(["status" => "error", "message" => "Patient not found"]);
}

$stmt->close();
$conn->close();
?>