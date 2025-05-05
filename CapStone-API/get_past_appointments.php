<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['patient_name']) || empty($data['patient_name'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Patient name is required']);
    exit();
}

$patient_name = $conn->real_escape_string($data['patient_name']);
$current_date = date('Y-m-d'); // Current date: 2025-04-17

// Include id in the query
$query = "SELECT id, physio_name, email, gender, appointment_date, selected_slot, consulting_type, status, is_emergency, appartment, landmark, area, city, pincode, patient_email, rejection_reason
          FROM appointments 
          WHERE LOWER(patient_name) = LOWER('$patient_name')
          ORDER BY appointment_date DESC";

// For debugging, log the query and current date
file_put_contents('debug.log', "Current Date: $current_date\nPatient Name: $patient_name\nQuery: $query\n", FILE_APPEND);

$result = $conn->query($query);

$appointments = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        // Map status to match UI expectations
        $status = $row['status'];
        if (strtolower($status) == 'cancelled' || strtolower($status) == 'rejected') {
            $status = 'Rejected';
        } elseif (strtolower($status) == 'confirmed' || strtolower($status) == 'accepted') {
            $status = 'Accepted';
        } else {
            $status = ucfirst($status);
        }

        $appointments[] = [
            'id' => $row['id'] ?? 'N/A', // Include id
            'doctor' => $row['physio_name'] ?? 'Unknown Doctor',
            'date' => date('d M Y', strtotime($row['appointment_date'])),
            'time' => $row['selected_slot'] ?? 'N/A',
            'typeOfVisit' => $row['consulting_type'] ?? 'N/A',
            'emergency' => ($row['is_emergency'] == 1) ? 'Yes' : 'No',
            'status' => $status,
            'email' => $row['email'] ?? 'N/A',
            'gender' => $row['gender'] ?? 'N/A',
            'appartment' => $row['appartment'] ?? 'N/A',
            'landmark' => $row['landmark'] ?? 'N/A',
            'area' => $row['area'] ?? 'N/A',
            'city' => $row['city'] ?? 'N/A',
            'pincode' => $row['pincode'] ?? 'N/A',
            'patient_email' => $row['patient_email'] ?? 'N/A',
            'rejection_reason' => $row['rejection_reason'] ?? 'No',
        ];
    }
    file_put_contents('debug.log', "Appointments Fetched: " . json_encode($appointments) . "\n", FILE_APPEND);
    ob_end_clean();
    echo json_encode(['status' => 'success', 'appointments' => $appointments]);
} else {
    file_put_contents('debug.log', "Query Failed: $query\nError: " . $conn->error . "\n", FILE_APPEND);
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Failed to fetch appointments: ' . $conn->error]);
}

$conn->close();
?>