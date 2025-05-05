<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db_config.php';
  
try {
    $conn = connectDB();
    $data = json_decode(file_get_contents("php://input"), true);

    if (!empty($data["username"]) && !empty($data["password"])) {
        $input_username = $data["username"];
        $input_password = $data["password"];

        $stmt = $conn->prepare("SELECT * FROM patient_patient WHERE username = ?");
        $stmt->bind_param("s", $input_username);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            // Compare plain-text passwords directly
            if ($input_password === $row['password']) {
                unset($row['password']); // Remove password from response
                echo json_encode(["message" => "Profile retrieved successfully", "data" => $row]);
            } else {
                http_response_code(401);
                echo json_encode(["message" => "Invalid password"]);
            }
        } else {
            http_response_code(404);
            echo json_encode(["message" => "User not found"]);
        }
        $stmt->close();
    } else {
        http_response_code(400);
        echo json_encode(["message" => "Username and password required"]);
    }
    $conn->close();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["message" => "Server error: " . $e->getMessage()]);
}
?>