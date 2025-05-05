<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

// Validate the input data
if (!isset($data['physio_id']) || empty($data['physio_id'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Physiotherapist ID is required']);
    exit();
}

if (!isset($data['rating']) || !is_numeric($data['rating']) || $data['rating'] < 1 || $data['rating'] > 5) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Rating must be a number between 1 and 5']);
    exit();
}

$physio_id = $conn->real_escape_string($data['physio_id']);
$rating = floatval($data['rating']);
$feedback = isset($data['feedback']) ? $conn->real_escape_string($data['feedback']) : '';

// Query to fetch the physiotherapist details
$query = "SELECT id, username, email, gender, photo, appartment, landmark, area, city, pincode, qualification, qualification_photo, specialization, experience, name, feedback, rating 
          FROM physio_physiotherapist 
          WHERE id = '$physio_id'";

// For debugging, log the query
file_put_contents('debug.log', "Physio ID: $physio_id\nQuery: $query\n", FILE_APPEND);

$result = $conn->query($query);

if ($result && $result->num_rows > 0) {
    // Fetch the physiotherapist details
    $physio = $result->fetch_assoc();

    // Update rating and feedback
    $update_query = "UPDATE physio_physiotherapist 
                     SET rating = ?, feedback = ? 
                     WHERE id = ?";
    $stmt = $conn->prepare($update_query);
    
    if ($stmt === false) {
        file_put_contents('debug.log', "Prepare failed: " . $conn->error . "\n", FILE_APPEND);
        ob_end_clean();
        echo json_encode(['status' => 'error', 'message' => 'Error preparing statement']);
        exit();
    }

    // Bind parameters and execute
    $stmt->bind_param("dsi", $rating, $feedback, $physio_id);

    if ($stmt->execute()) {
        $response = array(
            "status" => "success",
            "message" => "Rating and feedback submitted successfully",
            "physio" => [
                "id" => $physio['id'],
                "name" => $physio['name'],
                "email" => $physio['email'],
                "gender" => $physio['gender'],
                "photo" => $physio['photo'] ?? 'N/A',
                "appartment" => $physio['appartment'] ?? 'N/A',
                "landmark" => $physio['landmark'] ?? 'N/A',
                "area" => $physio['area'] ?? 'N/A',
                "city" => $physio['city'] ?? 'N/A',
                "pincode" => $physio['pincode'] ?? 'N/A',
                "qualification" => $physio['qualification'] ?? 'N/A',
                "qualification_photo" => $physio['qualification_photo'] ?? 'N/A',
                "specialization" => $physio['specialization'] ?? 'N/A',
                "experience" => $physio['experience'] ?? 'N/A',
                "rating" => $rating,
                "feedback" => $feedback
            ]
        );
    } else {
        $response = array(
            "status" => "error",
            "message" => "Error: " . $stmt->error
        );
    }

    // Close statement
    $stmt->close();
} else {
    // Log the error if no matching physiotherapist is found
    file_put_contents('debug.log', "Query Failed: $query\nError: " . $conn->error . "\n", FILE_APPEND);
    $response = array(
        "status" => "error",
        "message" => "Physiotherapist not found or query failed"
    );
}

ob_end_clean();
echo json_encode($response);

$conn->close();
?>
