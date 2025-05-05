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

    // Log incoming request for debugging
    file_put_contents('php://stderr', "Request Data: " . json_encode($data) . "\n");

    if (!empty($data["username"])) {
        $input_username = trim($data["username"]); // Trim whitespace

        // Verify user exists
        $check = $conn->prepare("SELECT username FROM patient_patient WHERE username = ?");
        $check->bind_param("s", $input_username);
        $check->execute();
        $result = $check->get_result();

        if ($result->num_rows > 0) {
            // User found, proceed with update
            $name = isset($data["name"]) && $data["name"] !== "" ? $data["name"] : null;
            $contact_no = isset($data["contact_no"]) && $data["contact_no"] !== "" ? $data["contact_no"] : null;
            $email = isset($data["email"]) && $data["email"] !== "" ? $data["email"] : null;
            $gender = isset($data["gender"]) && $data["gender"] !== "" ? $data["gender"] : null;
            $appartment = isset($data["appartment"]) && $data["appartment"] !== "" ? $data["appartment"] : null;
            $landmark = isset($data["landmark"]) && $data["landmark"] !== "" ? $data["landmark"] : null;
            $area = isset($data["area"]) && $data["area"] !== "" ? $data["area"] : null;
            $city = isset($data["city"]) && $data["city"] !== "" ? $data["city"] : null;
            $pincode = isset($data["pincode"]) && $data["pincode"] !== "" ? $data["pincode"] : null;

            $sql = "UPDATE patient_patient SET ";
            $types = "";
            $values = [];

            if ($name !== null) { $sql .= "name = ?, "; $types .= "s"; $values[] = $name; }
            if ($contact_no !== null) { $sql .= "contact_no = ?, "; $types .= "s"; $values[] = $contact_no; }
            if ($email !== null) { $sql .= "email = ?, "; $types .= "s"; $values[] = $email; }
            if ($gender !== null) { $sql .= "gender = ?, "; $types .= "s"; $values[] = $gender; }
            if ($appartment !== null) { $sql .= "appartment = ?, "; $types .= "s"; $values[] = $appartment; }
            if ($landmark !== null) { $sql .= "landmark = ?, "; $types .= "s"; $values[] = $landmark; }
            if ($area !== null) { $sql .= "area = ?, "; $types .= "s"; $values[] = $area; }
            if ($city !== null) { $sql .= "city = ?, "; $types .= "s"; $values[] = $city; }
            if ($pincode !== null) { $sql .= "pincode = ?, "; $types .= "s"; $values[] = $pincode; }

            if (!empty($values)) {
                // Remove trailing comma and space, add WHERE clause
                $sql = rtrim($sql, ", ") . " WHERE username = ?";
                $types .= "s";
                $values[] = $input_username;

                $stmt = $conn->prepare($sql);
                if ($stmt === false) {
                    throw new Exception("Prepare failed: " . $conn->error);
                }

                $stmt->bind_param($types, ...$values);
                if ($stmt->execute()) {
                    http_response_code(200);
                    echo json_encode(["message" => "Profile updated successfully"]);
                } else {
                    http_response_code(503);
                    echo json_encode(["message" => "Unable to update profile: " . $stmt->error]);
                }
                $stmt->close();
            } else {
                http_response_code(400);
                echo json_encode(["message" => "No valid fields provided to update"]);
            }
        } else {
            http_response_code(404);
            echo json_encode(["message" => "User not found for username: '$input_username'"]);
        }
        $check->close();
    } else {
        http_response_code(400);
        echo json_encode(["message" => "Username is required"]);
    }
    $conn->close();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["message" => "Server error: " . $e->getMessage()]);
}
?>