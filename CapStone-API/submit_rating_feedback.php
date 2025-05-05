<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

// Log received data for debugging
file_put_contents('debug.log', "Received data: " . json_encode($data) . "\n", FILE_APPEND);

// Validate input
$missing_fields = [];
if (!isset($data['appointment_id']) || empty($data['appointment_id']) || $data['appointment_id'] == 'N/A') {
    $missing_fields[] = 'appointment_id';
}
if (!isset($data['physio_name']) || empty($data['physio_name']) || $data['physio_name'] == 'Unknown') {
    $missing_fields[] = 'physio_name';
}
if (!isset($data['patient_name']) || empty($data['patient_name']) || $data['patient_name'] == 'N/A') {
    $missing_fields[] = 'patient_name';
}
if (!isset($data['rating']) || empty($data['rating'])) {
    $missing_fields[] = 'rating';
}

if (!empty($missing_fields)) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields: ' . implode(', ', $missing_fields)]);
    exit();
}

$appointment_id = $conn->real_escape_string($data['appointment_id']);
$physio_name = $conn->real_escape_string($data['physio_name']);
$patient_name = $conn->real_escape_string($data['patient_name']);
$rating = (int)$data['rating'];
$feedback = isset($data['feedback']) ? $conn->real_escape_string($data['feedback']) : '';

// Validate rating range
if ($rating < 1 || $rating > 5) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Rating must be between 1 and 5']);
    exit();
}

// Check if rating already exists for this appointment
$check_query = "SELECT id FROM ratings_feedback WHERE appointment_id = '$appointment_id'";
$check_result = $conn->query($check_query);
if ($check_result && $check_result->num_rows > 0) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'You have already Submitted Rating and Feedback']);
    exit();
}

// Insert rating and feedback
$insert_query = "INSERT INTO ratings_feedback (appointment_id, physio_name, patient_name, rating, feedback)
                 VALUES ('$appointment_id', '$physio_name', '$patient_name', '$rating', '$feedback')";
if ($conn->query($insert_query)) {
    // Update average rating in physio_physiotherapist
    $avg_query = "SELECT AVG(rating) as avg_rating FROM ratings_feedback WHERE physio_name = '$physio_name'";
    $avg_result = $conn->query($avg_query);
    if ($avg_result && $avg_row = $avg_result->fetch_assoc()) {
        $avg_rating = round($avg_row['avg_rating'], 2);
        $update_query = "UPDATE physio_physiotherapist SET average_rating = '$avg_rating' WHERE name = '$physio_name'";
        $conn->query($update_query);
    }

    ob_end_clean();
    echo json_encode(['status' => 'success', 'message' => 'Rating and feedback submitted successfully']);
} else {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Failed to submit rating: ' . $conn->error]);
}

$conn->close();
?>