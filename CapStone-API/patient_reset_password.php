<?php
header('Content-Type: application/json');

// Include database configuration
require_once 'db_config.php';

// Get email and new password from POST request
$data = json_decode(file_get_contents('php://input'), true);
$email = isset($data['email']) ? trim($data['email']) : '';
$new_password = isset($data['password']) ? $data['password'] : '';

if (empty($email) || empty($new_password)) {
    echo json_encode(['status' => 'error', 'message' => 'Email and new password are required']);
    exit();
}

// Connect to database
$conn = connectDB();

// Hash the new password (using password_hash for security)
$hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

// Update the password in the database
$stmt = $conn->prepare("UPDATE patient_patient SET password = ? WHERE email = ?");
$stmt->bind_param("ss", $hashed_password, $email);
$stmt->execute();

if ($stmt->affected_rows > 0) {
    echo json_encode(['status' => 'success', 'message' => 'Password changed successfully']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to reset password or email not found']);
}

// Close database connections
$stmt->close();
$conn->close();
?>