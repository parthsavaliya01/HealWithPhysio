<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

// Log received data
file_put_contents('debug.log', "get_physio_feedback.php - Received data: " . json_encode($data) . "\n", FILE_APPEND);

if (!isset($data['physio_name']) || empty($data['physio_name'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Physiotherapist name is required']);
    exit();
}

$physio_name = $conn->real_escape_string($data['physio_name']);

$query = "SELECT appointment_id, patient_name, rating, feedback FROM ratings_feedback WHERE physio_name = '$physio_name' ORDER BY created_at DESC";
$result = $conn->query($query);

$feedback = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $feedback[] = [
            'appointment_id' => $row['appointment_id'] ?? 'N/A',
            'patient_name' => $row['patient_name'] ?? 'Unknown',
            'rating' => (double)$row['rating'],
            'feedback' => $row['feedback'] ?? 'No feedback provided',
        ];
    }
}

ob_end_clean();
echo json_encode(['status' => 'success', 'feedback' => $feedback]);

$conn->close();
?>