<?php
ob_start();
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['physio_name']) || empty($data['physio_name'])) {
    ob_end_clean();
    echo json_encode(['status' => 'error', 'message' => 'Physiotherapist name is required']);
    exit();
}

$physio_name = $conn->real_escape_string($data['physio_name']);

// Initialize counts
$counts = [
    'all' => 0,
    'pending' => 0,
    'confirmed' => 0,
    'rejected' => 0
];

// Count all appointments
$query_all = "SELECT COUNT(*) as count FROM appointments WHERE physio_name = '$physio_name'";
$result_all = $conn->query($query_all);
if ($result_all) {
    $row = $result_all->fetch_assoc();
    $counts['all'] = (int)$row['count'];
}

// Count pending appointments (status = '')
$query_pending = "SELECT COUNT(*) as count FROM appointments WHERE physio_name = '$physio_name' AND status IS NULL";
$result_pending = $conn->query($query_pending);
if ($result_pending) {
    $row = $result_pending->fetch_assoc();
    $counts['pending'] = (int)$row['count'];
}

// Count confirmed appointments (status = 'Accepted')
$query_confirmed = "SELECT COUNT(*) as count FROM appointments WHERE physio_name = '$physio_name' AND status = 'Accepted'";
$result_confirmed = $conn->query($query_confirmed);
if ($result_confirmed) {
    $row = $result_confirmed->fetch_assoc();
    $counts['confirmed'] = (int)$row['count'];
}

// Count rejected appointments (status = 'Rejected')
$query_rejected = "SELECT COUNT(*) as count FROM appointments WHERE physio_name = '$physio_name' AND status = 'Rejected'";
$result_rejected = $conn->query($query_rejected);
if ($result_rejected) {
    $row = $result_rejected->fetch_assoc();
    $counts['rejected'] = (int)$row['count'];
}

file_put_contents('debug.log', "Counts for $physio_name: " . json_encode($counts) . "\n", FILE_APPEND);

ob_end_clean();
echo json_encode(['status' => 'success', 'counts' => $counts], JSON_UNESCAPED_UNICODE);

$conn->close();
?>