<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

// Log received data
file_put_contents('debug.log', "get_physio_name.php - Received data: " . json_encode($data) . "\n", FILE_APPEND);

if (!isset($data['username']) || empty($data['username'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Username is required']);
    exit();
}

$username = $conn->real_escape_string($data['username']);

$query = "SELECT name, average_rating FROM physio_physiotherapist WHERE username = '$username'";
$result = $conn->query($query);

if ($result && $row = $result->fetch_assoc()) {
    ob_end_clean();
    echo json_encode(['status' => 'success', 'name' => $row['name'], 'average_rating' => $row['average_rating']]);
} else {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Physiotherapist not found']);
}

$conn->close();
?>