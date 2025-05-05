<?php
include 'db_config.php'; // Include database connection

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

error_reporting(E_ALL);
ini_set('display_errors', 1);

$response = ["status" => "error", "message" => "Something went wrong"];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    if (empty($username) || empty($password)) {
        $response["message"] = "Username and password required";
        echo json_encode($response);
        exit;
    }

    $conn = connectDB(); // Establish database connection

    // Check if the physiotherapist exists
    $query = "SELECT * FROM physio_physiotherapist WHERE username = ? AND password = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ss", $username, $password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Delete physiotherapist
        $deleteQuery = "DELETE FROM physio_physiotherapist WHERE username = ? AND password = ?";
        $deleteStmt = $conn->prepare($deleteQuery);
        $deleteStmt->bind_param("ss", $username, $password);

        if ($deleteStmt->execute()) {
            $response = ["status" => "success", "message" => "Account deleted successfully"];
        } else {
            $response["message"] = "Failed to delete account";
        }
    } else {
        $response["message"] = "Invalid username or password";
    }

    $stmt->close();
    $conn->close();
} else {
    $response["message"] = "Invalid request method";
}

// **Always return JSON**
echo json_encode($response);
exit;

?>
