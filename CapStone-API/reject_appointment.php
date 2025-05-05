<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['appointment_id']) || !isset($data['rejection_reason'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Appointment ID and rejection reason are required']);
    exit();
}

$appointment_id = $conn->real_escape_string($data['appointment_id']);
$rejection_reason = $conn->real_escape_string($data['rejection_reason']);
$query = "UPDATE appointments SET status = 'Rejected', rejection_reason = '$rejection_reason' WHERE id = '$appointment_id'";
if ($conn->query($query)) {
    ob_end_clean();
    echo json_encode(['status' => 'success', 'message' => 'Appointment rejected']);
} else {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Failed to reject appointment']);
}

$conn->close();
?>