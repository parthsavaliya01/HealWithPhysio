<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Import the db_config.php file
require_once 'db_config.php';

// Establish database connection using connectDB()
$conn = connectDB();

// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);

$appointment_id = isset($data['appointment_id']) ? $data['appointment_id'] : '';
$patient_name = isset($data['patient_name']) ? $data['patient_name'] : '';
$patient_contactno = isset($data['patient_contactno']) ? $data['patient_contactno'] : '';
$patient_email = isset($data['patient_email']) ? $data['patient_email'] : '';
$patient_gender = isset($data['patient_gender']) ? $data['patient_gender'] : '';

// Validate required fields
if (empty($appointment_id)) {
    echo json_encode(["status" => "error", "message" => "Appointment ID is required"]);
    exit;
}

if (empty($patient_name) || empty($patient_contactno) || empty($patient_email) || empty($patient_gender)) {
    echo json_encode(["status" => "error", "message" => "All patient details are required"]);
    exit;
}

// Update the appointment with patient details
$sql = "UPDATE appointments 
        SET 
            patient_name = ?, 
            patient_contactno = ?, 
            patient_email = ?, 
            patient_gender = ? 
        WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $patient_name, $patient_contactno, $patient_email, $patient_gender, $appointment_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(["status" => "success", "message" => "Patient details updated successfully for appointment ID: $appointment_id"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No appointment found for ID: $appointment_id"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update patient details: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>