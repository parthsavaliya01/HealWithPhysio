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
    $uploadDir = 'uploads/';
    if (!file_exists($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $photoPath = null;
    $qualPhotoPath = null;

    // Handle profile photo upload
    if (isset($_FILES['photo']) && $_FILES['photo']['error'] == UPLOAD_ERR_OK) {
        $photoName = time() . '_' . basename($_FILES['photo']['name']);
        $photoPath = $uploadDir . $photoName;
        if (!move_uploaded_file($_FILES['photo']['tmp_name'], $photoPath)) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to upload profile photo']);
            error_log("Failed to upload profile photo for username: " . ($_POST['username'] ?? 'unknown'));
            exit;
        }
    }

    // Handle qualification photo upload
    if (isset($_FILES['qualification_photo']) && $_FILES['qualification_photo']['error'] == UPLOAD_ERR_OK) {
        $qualPhotoName = time() . '_' . basename($_FILES['qualification_photo']['name']);
        $qualPhotoPath = $uploadDir . $qualPhotoName;
        if (!move_uploaded_file($_FILES['qualification_photo']['tmp_name'], $qualPhotoPath)) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to upload qualification photo']);
            error_log("Failed to upload qualification photo for username: " . ($_POST['username'] ?? 'unknown'));
            exit;
        }
    }

    // Collect data from POST request
    $data = [
        'username' => $_POST['username'] ?? '',
        'password' => $_POST['password'] ?? '', // Plain text password
        'name' => $_POST['name'] ?? null,
        'contact_no' => $_POST['contact_no'] ?? null,
        'email' => $_POST['email'] ?? null,
        'gender' => $_POST['gender'] ?? null,
        'appartment' => $_POST['appartment'] ?? null,
        'landmark' => $_POST['landmark'] ?? null,
        'area' => $_POST['area'] ?? null,
        'city' => $_POST['city'] ?? null,
        'pincode' => $_POST['pincode'] ?? null,
        'clinic_start_time' => $_POST['clinic_start_time'] ?? null,
        'clinic_end_time' => $_POST['clinic_end_time'] ?? null,
        'qualification' => $_POST['qualification'] ?? null,
        'specialization' => $_POST['specialization'] ?? null,
        'experience' => $_POST['experience'] ?? null,
        'photo' => $photoPath,
        'qualification_photo' => $qualPhotoPath
    ];

    // Required fields for identification
    if (empty($data['username']) || empty($data['password'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Username and password are required']);
        error_log("Update failed: Username or password missing");
        exit;
    }

    // Verify user exists and password matches (plain text comparison)
    $checkUser = $conn->prepare("SELECT password FROM physio_physiotherapist WHERE username = ?");
    if (!$checkUser) {
        http_response_code(500);
        echo json_encode(['error' => 'Prepare failed: ' . $conn->error]);
        error_log("Check user prepare failed: " . $conn->error);
        exit;
    }
    $checkUser->bind_param("s", $data['username']);
    $checkUser->execute();
    $result = $checkUser->get_result();
    $row = $result->fetch_assoc();

    if (!$row || $row['password'] !== $data['password']) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid username or password']);
        error_log("Update failed: Invalid username or password for username: " . $data['username']);
        exit;
    }
    $checkUser->close();

    // Build dynamic UPDATE query based on provided fields
    $setClause = [];
    $params = [];
    $types = '';

    foreach ($data as $key => $value) {
        if ($key !== 'username' && $key !== 'password' && $value !== null) {
            $setClause[] = "$key = ?";
            $params[] = $value;
            $types .= 's'; // Assuming all fields are strings for simplicity
        }
    }

    if (empty($setClause)) {
        http_response_code(400);
        echo json_encode(['error' => 'No fields provided to update']);
        error_log("Update failed: No fields provided for username: " . $data['username']);
        exit;
    }

    $query = "UPDATE physio_physiotherapist SET " . implode(', ', $setClause) . " WHERE username = ? AND password = ?";
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['error' => 'Prepare failed: ' . $conn->error]);
        error_log("Update prepare failed: " . $conn->error);
        exit;
    }

    // Add username and password to params for WHERE clause
    $params[] = $data['username'];
    $params[] = $data['password'];
    $types .= 'ss';

    // Bind parameters dynamically
    $stmt->bind_param($types, ...$params);

    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(['message' => 'Update successful']);
        error_log("Update successful for username: " . $data['username'] . " - City: " . ($data['city'] ?? 'not provided') . ", Specialization: " . ($data['specialization'] ?? 'not provided'));
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $stmt->error]);
        error_log("Update failed for username: " . $data['username'] . " - Error: " . $stmt->error);
    }

    $stmt->close();
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Invalid request method']);
    error_log("Update failed: Invalid request method - " . $_SERVER['REQUEST_METHOD']);
}

$conn->close();
?>