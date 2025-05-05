<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php'; // Include your database config

$conn = connectDB();

$data = json_decode(file_get_contents("php://input"), true);

// Validate required fields
$appointment_id = $data['appointment_id'] ?? '';
$selected_slot = $data['selected_slot'] ?? '';
$is_emergency = $data['is_emergency'] ?? '';
$appartment = $data['appartment'] ?? 'Not available';
$landmark = $data['landmark'] ?? 'Not available';
$area = $data['area'] ?? 'Not available';
$city = $data['city'] ?? 'Not available';
$pincode = $data['pincode'] ?? 'Not available';

if (empty($appointment_id)) {
    echo json_encode([
        'success' => false,
        'message' => 'Appointment ID is required'
    ]);
    $conn->close();
    exit;
}

if (empty($selected_slot)) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing field: selected_slot'
    ]);
    $conn->close();
    exit;
}

if (!isset($data['is_emergency'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing field: is_emergency'
    ]);
    $conn->close();
    exit;
}

// Prepare and execute SQL
$query = "UPDATE appointments SET selected_slot = ?, is_emergency = ?, appartment = ?, landmark = ?, area = ?, city = ?, pincode = ? WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param(
    "sisssssi",
    $selected_slot, $is_emergency, $appartment, $landmark,
    $area, $city, $pincode, $appointment_id
);

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