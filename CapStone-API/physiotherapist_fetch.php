<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Enable error logging for debugging
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'php_errors.log');

require_once 'db_config.php';
$conn = connectDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? ''; // Plain text password

    // Required fields for identification
    if (empty($username) || empty($password)) {
        http_response_code(400);
        echo json_encode(['error' => 'Username and password are required']);
        error_log("Fetch failed: Username or password missing");
        exit;
    }

    
    $query = "SELECT name, contact_no, email, gender, appartment, landmark, area, city, pincode, 
              clinic_start_time, clinic_end_time, 
              qualification, specialization, experience, photo, qualification_photo 
              FROM physio_physiotherapist 
              WHERE username = ? AND password = ?";
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['error' => 'Database prepare failed: ' . $conn->error]);
        error_log("Database prepare failed: " . $conn->error);
        exit;
    }

    $stmt->bind_param("ss", $username, $password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        // Ensure photo paths are relative to the server
        if (!empty($row['photo'])) {
            $row['photo'] = 'uploads/' . basename($row['photo']);
        }
        if (!empty($row['qualification_photo'])) {
            $row['qualification_photo'] = 'uploads/' . basename($row['qualification_photo']);
        }

        // Explicitly handle city and specialization to ensure they’re included
        $row['city'] = $row['city'] ?? ''; // Default to empty string if NULL
        $row['specialization'] = $row['specialization'] ?? ''; // Default to empty string if NULL

        http_response_code(200);
        echo json_encode([
            'message' => 'Data fetched successfully',
            'data' => $row
        ]);
        error_log("Data fetched for username: $username - City: {$row['city']}, Specialization: {$row['specialization']}");
    } else {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid username or password']);
        error_log("Fetch failed: Invalid username or password for username: $username");
    }

    $stmt->close();
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Invalid request method']);
    error_log("Fetch failed: Invalid request method - " . $_SERVER['REQUEST_METHOD']);
}

$conn->close();
?>