<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Import the db_config.php file
require_once 'db_config.php';

// Establish database connection using connectDB()
$conn = connectDB();

$appointment_id = isset($_GET['appointment_id']) ? $_GET['appointment_id'] : '';

if (empty($appointment_id)) {
    echo json_encode(["status" => "error", "message" => "Appointment ID is required"]);
    exit;
}

$sql = "SELECT 
            CAST(id AS CHAR) AS id,
            physio_name,
            CAST(contact_number AS CHAR) AS contact_number,
            email,
            appointment_date,
            consulting_type,
            selected_slot,
            CAST(is_emergency AS CHAR) AS is_emergency
        FROM appointments 
        WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $appointment_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $data = $result->fetch_assoc();
    echo json_encode(["status" => "success", "data" => $data]);
} else {
    echo json_encode(["status" => "error", "message" => "No appointment found for ID: $appointment_id"]);
}

$stmt->close();
$conn->close();
?>