<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // Added CORS header
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
// Include the database configuration file
require_once 'db_config.php';

$conn = connectDB();

// Base query
$query = "SELECT * FROM physio_physiotherapist WHERE 1=1";
$params = array();
$types = "";

// Gender filter
if (isset($_GET['gender']) && !empty($_GET['gender'])) {
    $query .= " AND gender = ?";
    $params[] = $_GET['gender'];
    $types .= "s";
}

// Location filter (mapped to 'appartment')
if (isset($_GET['location']) && !empty($_GET['location'])) {
    $query .= " AND appartment LIKE ?";
    $params[] = "%" . $_GET['location'] . "%";
    $types .= "s";
}

// Speciality filter (mapped to 'specialization')
if (isset($_GET['speciality']) && !empty($_GET['speciality'])) {
    $query .= " AND specialization = ?";
    $params[] = $_GET['speciality'];
    $types .= "s";
}

// Experience filter
if (isset($_GET['min_experience']) && !empty($_GET['min_experience'])) {
    $query .= " AND experience >= ?";
    $params[] = (int)$_GET['min_experience'];
    $types .= "i";
}

// City filter (new)
if (isset($_GET['city']) && !empty($_GET['city'])) {
    $query .= " AND city = ?";
    $params[] = $_GET['city'];
    $types .= "s";
}

// Rating filter (updated to use average_rating)
if (isset($_GET['min_rating']) && !empty($_GET['min_rating'])) {
    $query .= " AND average_rating >= ?";
    $params[] = (float)$_GET['min_rating'];
    $types .= "d";
}

// Debug: Log request parameters and query
file_put_contents('debug.log', "Request: " . json_encode($_GET) . "\nQuery: $query\nParams: " . json_encode($params) . "\n", FILE_APPEND);

try {
    // Prepare and execute the query
    $stmt = $conn->prepare($query);
    
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    $results = $result->fetch_all(MYSQLI_ASSOC);

    // Return success response
    echo json_encode([
        "status" => "success",
        "data" => $results,
        "message" => "Physiotherapists retrieved successfully"
    ]);

} catch (Exception $e) {
    // Return error response
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}

$stmt->close();
$conn->close(); // Close connection
?>