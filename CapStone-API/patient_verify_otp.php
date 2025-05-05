<?php
header('Content-Type: application/json');

// Include database configuration
require_once 'db_config.php';

// Get email and OTP from POST request
$data = json_decode(file_get_contents('php://input'), true);
$email = isset($data['email']) ? trim($data['email']) : '';
$otp = isset($data['otp']) ? trim($data['otp']) : '';

if (empty($email) || empty($otp)) {
    echo json_encode(['status' => 'error', 'message' => 'Email and OTP are required']);
    exit();
}

// Connect to database
$conn = connectDB();

// Verify OTP
$stmt = $conn->prepare("SELECT otp, otp_expiry FROM patient_patient WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email not found']);
    $stmt->close();
    $conn->close();
    exit();
}

$row = $result->fetch_assoc();
$stored_otp = $row['otp'];
$otp_expiry = $row['otp_expiry'];

if ($stored_otp !== $otp) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid OTP']);
    $stmt->close();
    $conn->close();
    exit();
}

// Check if OTP has expired
$current_time = date('Y-m-d H:i:s');
if ($current_time > $otp_expiry) {
    echo json_encode(['status' => 'error', 'message' => 'OTP has expired']);
    $stmt->close();
    $conn->close();
    exit();
}

// OTP is valid, optionally clear it after successful verification
$stmt = $conn->prepare("UPDATE patient_patient SET otp = NULL, otp_expiry = NULL WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();

echo json_encode(['status' => 'success', 'message' => 'OTP verified successfully']);

// Close database connections
$stmt->close();
$conn->close();
?>