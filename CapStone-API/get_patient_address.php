<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Include the database configuration file
require_once 'db_config.php';

// Connect to the database
$conn = connectDB();

// Get the POST data (username from the Flutter app)
$data = json_decode(file_get_contents("php://input"), true);
$username = $data['username'] ?? '';

if (empty($username)) {
    echo json_encode([
        "status" => "error",
        "message" => "Username is required"
    ]);
    $conn->close();
    exit();
}

try {
    // Prepare and execute the query
    $query = "SELECT appartment, landmark, area, city, pincode FROM patient_patient WHERE username = ?";
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        throw new Exception("Query preparation failed: " . $conn->error);
    }

    $stmt->bind_param("s", $username);
    if (!$stmt->execute()) {
        throw new Exception("Query execution failed: " . $stmt->error);
    }

    $result = $stmt->get_result();
    if ($row = $result->fetch_assoc()) {
        echo json_encode([
            "status" => "success",
            "data" => $row,
            "message" => "Patient address retrieved successfully"
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Patient not found"
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}

$stmt->close();
$conn->close();
?>