<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';

$conn = connectDB();

$data = json_decode(file_get_contents("php://input"), true);

$appointment_id = $data['appointment_id'] ?? '';
$appointment_date = $data['appointment_date'] ?? '';
$consulting_type = $data['consulting_type'] ?? '';

if (empty($appointment_id)) {
    echo json_encode([
        'success' => false,
        'message' => 'Appointment ID is required'
    ]);
    $conn->close();
    exit;
}

$query = "UPDATE appointments SET appointment_date = ?, consulting_type = ? WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ssi", $appointment_date, $consulting_type, $appointment_id);

if ($stmt->execute()) {
    echo json_encode([
        'success' => true,
        'message' => 'Appointment details updated successfully'
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