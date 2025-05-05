<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';
$conn = connectDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uploadDir = 'uploads/';
    if (!file_exists($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $photoPath = null;
    $qualPhotoPath = null;

    if (isset($_FILES['photo']) && $_FILES['photo']['error'] == UPLOAD_ERR_OK) {
        $photoName = time() . '_' . basename($_FILES['photo']['name']);
        $photoPath = $uploadDir . $photoName;
        if (!move_uploaded_file($_FILES['photo']['tmp_name'], $photoPath)) {
            echo json_encode(['error' => 'Failed to upload profile photo']);
            exit;
        }
    }

    if (isset($_FILES['qualification_photo']) && $_FILES['qualification_photo']['error'] == UPLOAD_ERR_OK) {
        $qualPhotoName = time() . '_' . basename($_FILES['qualification_photo']['name']);
        $qualPhotoPath = $uploadDir . $qualPhotoName;
        if (!move_uploaded_file($_FILES['qualification_photo']['tmp_name'], $qualPhotoPath)) {
            echo json_encode(['error' => 'Failed to upload qualification photo']);
            exit;
        }
    }

    $data = [
        'name' => $_POST['name'] ?? '',
        'username' => $_POST['username'] ?? '',
        'password' => $_POST['password'] ?? '',
        'contact_no' => $_POST['contact_no'] ?? '',
        'email' => $_POST['email'] ?? '',
        'gender' => $_POST['gender'] ?? '',
        'appartment' => $_POST['appartment'] ?? null,
        'landmark' => $_POST['landmark'] ?? null,
        'area' => $_POST['area'] ?? '',
        'city' => $_POST['city'] ?? '',
        'pincode' => $_POST['pincode'] ?? '',
        'clinic_start_time' => $_POST['clinic_start_time'] ?? '',
        'clinic_end_time' => $_POST['clinic_end_time'] ?? '',
        // 'home_visit_start_time' => $_POST['home_visit_start_time'] ?? null,
        // 'home_visit_end_time' => $_POST['home_visit_end_time'] ?? null,
        'qualification' => $_POST['qualification'] ?? '',
        'specialization' => $_POST['specialization'] ?? '',
        'experience' => $_POST['experience'] ?? '',
        'photo' => $photoPath,
        'qualification_photo' => $qualPhotoPath
    ];

    if (empty($data['name']) || empty($data['username']) || empty($_POST['password']) || empty($data['qualification_photo'])) {
        echo json_encode(['error' => 'Required fields are missing']);
        exit;
    }

    $query = "INSERT INTO physio_physiotherapist (name, username, password, contact_no, email, gender, photo, appartment, landmark, area, city, pincode, clinic_start_time, clinic_end_time,  qualification, qualification_photo, specialization, experience) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        echo json_encode(['error' => 'Prepare failed: ' . $conn->error]);
        exit;
    }

    // Bind parameters using MySQLi (20 parameters, all strings 's')
    $stmt->bind_param(
        "ssssssssssssssssss",
        $data['name'],
        $data['username'],
        $data['password'],
        $data['contact_no'],
        $data['email'],
        $data['gender'],
        $data['photo'],
        $data['appartment'],
        $data['landmark'],
        $data['area'],
        $data['city'],
        $data['pincode'],
        $data['clinic_start_time'],
        $data['clinic_end_time'],
        // $data['home_visit_start_time'],
        // $data['home_visit_end_time'],
        $data['qualification'],
        $data['qualification_photo'],
        $data['specialization'],
        $data['experience']
    );

    if ($stmt->execute()) {
        echo json_encode(['message' => 'Signup successful']);
    } else {
        echo json_encode(['error' => 'Database error: ' . $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(['error' => 'Invalid request method']);
}

$conn->close();
?>