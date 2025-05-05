<?php
header('Content-Type: application/json');

require_once 'db_config.php'; $conn = connectDB();

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Database connection failed']));
}

$data = json_decode(file_get_contents('php://input'), true);
$appointment_date = $data['appointment_date'];
$physio_name = $data['physio_name'];

$query = "SELECT selected_slot FROM appointments WHERE appointment_date = ? AND physio_name = ? AND status = 'booked'";
$stmt = $conn->prepare($query);
$stmt->bind_param("ss", $appointment_date, $physio_name);
$stmt->execute();
$result = $stmt->get_result();

$booked_slots = [];
while ($row = $result->fetch_assoc()) {
    $booked_slots[] = $row['selected_slot'];
}

$stmt->close();
$conn->close();

echo json_encode(['success' => true, 'booked_slots' => $booked_slots]);
?>
