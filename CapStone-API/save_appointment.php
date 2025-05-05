<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Include the database configuration file
require_once 'db_config.php';

$conn = connectDB();

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);

$physio_name = $data['physio_name'] ?? '';
$contact_number = $data['contact_number'] ?? '';
$email = $data['email'] ?? '';
$gender = $data['gender'] ?? '';
$specialization = $data['specialization'] ?? '';

// Validate required fields
if (empty($physio_name) || empty($contact_number) || empty($email) || empty($gender) || empty($specialization)) {
    echo json_encode([
        'success' => false,
        'message' => 'All fields are required'
    ]);
    $conn->close();
    exit;
}

// Prepare and execute query
$query = "INSERT INTO appointments (physio_name, contact_number, email, gender, specialization) 
          VALUES (?, ?, ?, ?, ?)";
          
$stmt = $conn->prepare($query);
$stmt->bind_param("sssss", $physio_name, $contact_number, $email, $gender, $specialization);

if ($stmt->execute()) {
    $appointment_id = $conn->insert_id; // Get the last inserted ID
    echo json_encode([
        'success' => true,
        'message' => 'Appointment booked successfully',
        'appointment_id' => $appointment_id
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>