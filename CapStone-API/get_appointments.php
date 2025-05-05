<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['physio_name']) || empty($data['physio_name'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Physiotherapist name is required']);
    exit();
}

$physio_name = $conn->real_escape_string($data['physio_name']);
$query = "SELECT * FROM appointments WHERE physio_name = '$physio_name'";
$result = $conn->query($query);

file_put_contents('debug.log', "Query: $query\nRows: " . ($result ? $result->num_rows : 'Failed') . "\n", FILE_APPEND);

if (!$result) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Database query failed: ' . $conn->error]);
    exit();
}

$appointments = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $appointments[] = [
            'id' => (int)$row['id'],
            'patient_name' => $row['patient_name'] ?? '',
            'appointment_date' => $row['appointment_date'] ?? '',
            'selected_slot' => $row['selected_slot'] ?? '',
            'consulting_type' => $row['consulting_type'] == 'Home Consulting' ? 'Home Consulting' : 'Clinic Consulting',
            'status' => $row['status'] ?? 'Pending',
            'is_emergency' => (bool)$row['is_emergency'],
            'patient_contactno' => $row['patient_contactno'] ?? '',
            'patient_email' => $row['patient_email'] ?? '',
            'patient_gender' => $row['patient_gender'] ?? '',
            'address' => ($row['appartment'] ?? '') . ', ' . ($row['area'] ?? '') . ', ' . ($row['city'] ?? '') . ' - ' . ($row['pincode'] ?? ''),
            'rejection_reason' => $row['rejection_reason'] ?? null
        ];
    }
}

file_put_contents('debug.log', "Appointments: " . json_encode($appointments) . "\n", FILE_APPEND);

ob_end_clean();
echo json_encode(['status' => 'success', 'appointments' => $appointments], JSON_UNESCAPED_UNICODE);

$conn->close();
?>