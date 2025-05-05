<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include the database connection file
include 'db_config.php';

// Debugging: Check if function exists
if (!function_exists('connectDB')) {
    die(json_encode(["error" => "Database connection function not found! Check db_config.php"]));
}

// Get database connection
$conn = connectDB();
if (!$conn) {
    die(json_encode(["error" => "Database connection failed"]));
}

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Extract data from request
    $username = $data['username'] ?? null;
    $name = $data['name'] ?? null;
    $password = $data['password'] ?? null;
    $contact_no = $data['contact_no'] ?? null;
    $email = $data['email'] ?? null;
    $gender = $data['gender'] ?? null;
    $appartment = $data['appartment'] ?? null;
    $landmark = $data['landmark'] ?? null;
    $area = $data['area'] ?? null;
    $city = $data['city'] ?? null;
    $pincode = $data['pincode'] ?? null;

    // Validate required fields
    if (!$username || !$name || !$password || !$contact_no || !$email || !$gender || !$appartment || !$landmark || !$area || !$city || !$pincode) {
        echo json_encode(["error" => "All required fields must be filled"]);
        exit;
    }

    // Hash password
    // $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    // Prepare SQL query
    $query = "INSERT INTO patient_patient (username, name, password, contact_no, email, gender, appartment, landmark, area, city, pincode)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("sssssssssss", $username, $name, $password, $contact_no, $email, $gender, $appartment, $landmark, $area, $city, $pincode);

    if ($stmt->execute()) {
        echo json_encode(["message" => "Patient registered successfully!"]);
    } else {
        echo json_encode(["error" => "Database error: " . $stmt->error]);
    }

    // Close resources
    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}
?>
