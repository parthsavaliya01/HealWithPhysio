<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Include the database configuration
require_once 'db_config.php';

try {
    // Get database connection
    $conn = connectDB();

    // Get the raw POST data
    $data = json_decode(file_get_contents("php://input"), true);

    // Check if required fields are present
    if (!isset($data['email']) || !isset($data['new_password'])) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Email and new password are required'
        ]);
        exit;
    }

    $email = $conn->real_escape_string($data['email']);
    $new_password = $data['new_password'];// Hash the password

    // Prepare and execute the update query
    $sql = "UPDATE patient_patient SET password = '$new_password' WHERE email = '$email'";
    $result = $conn->query($sql);

    if ($result === TRUE) {
        if ($conn->affected_rows > 0) {
            echo json_encode([
                'status' => 'success',
                'message' => 'Password updated successfully'
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'No account found with this email'
            ]);
        }
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to update password: ' . $conn->error
        ]);
    }

    // Close the connection
    $conn->close();

} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>