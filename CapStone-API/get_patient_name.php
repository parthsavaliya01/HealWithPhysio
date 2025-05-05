<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['username']) || empty($data['username'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Username is required']);
    exit();
}

$username = $conn->real_escape_string($data['username']);

$query = "SELECT name FROM patient_patient WHERE username = '$username'";
$result = $conn->query($query);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    ob_end_clean();
    echo json_encode(['status' => 'success', 'name' => $row['name']]);
} else {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Patient not found']);
}

$conn->close();
?>