<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['appointment_id'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Appointment ID is required']);
    exit();
}

$appointment_id = $conn->real_escape_string($data['appointment_id']);
$query = "UPDATE appointments SET status = 'Accepted' WHERE id = '$appointment_id'";
if ($conn->query($query)) {
    ob_end_clean();
    echo json_encode(['status' => 'success', 'message' => 'Appointment accepted']);
} else {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Failed to accept appointment']);
}

$conn->close();
?>