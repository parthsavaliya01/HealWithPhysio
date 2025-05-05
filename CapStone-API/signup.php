<?php
// Include the database connection
include_once('db_config.php');

// Set Content-Type to JSON
header('Content-Type: application/json');

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // Debug: Log POST data
    error_log("Received POST data: " . json_encode($_POST));

    // Retrieve data from POST request
    $username = isset($_POST['username']) ? $_POST['username'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';
    $contact_no = isset($_POST['contact_no']) ? $_POST['contact_no'] : '';
    $email = isset($_POST['email']) ? $_POST['email'] : '';
    $gender = isset($_POST['gender']) ? $_POST['gender'] : '';
    $photo = isset($_POST['photo']) ? $_POST['photo'] : ''; // Handle photo separately for file upload
    $appartment = isset($_POST['appartment']) ? $_POST['appartment'] : '';
    $landmark = isset($_POST['landmark']) ? $_POST['landmark'] : '';
    $area = isset($_POST['area']) ? $_POST['area'] : '';
    $city = isset($_POST['city']) ? $_POST['city'] : '';
    $pincode = isset($_POST['pincode']) ? $_POST['pincode'] : '';
    $clinic_start_time = isset($_POST['clinic_start_time']) ? $_POST['clinic_start_time'] : '';
    $clinic_end_time = isset($_POST['clinic_end_time']) ? $_POST['clinic_end_time'] : '';
    $home_visit_start_time = isset($_POST['home_visit_start_time']) ? $_POST['home_visit_start_time'] : '';
    $home_visit_end_time = isset($_POST['home_visit_end_time']) ? $_POST['home_visit_end_time'] : '';
    $qualification = isset($_POST['qualification']) ? $_POST['qualification'] : '';
    $qualification_photo = isset($_POST['qualification_photo']) ? $_POST['qualification_photo'] : ''; // Handle file upload separately
    $specialization = isset($_POST['specialization']) ? $_POST['specialization'] : '';
    $experience = isset($_POST['experience']) ? $_POST['experience'] : '';

    // Debugging: Check if all required fields are present
    $required_fields = [
        'username', 'password', 'contact_no', 'email', 'gender', 'photo',
        'appartment', 'landmark', 'area', 'city', 'pincode', 'clinic_start_time',
        'clinic_end_time', 'home_visit_start_time', 'home_visit_end_time',
        'qualification', 'qualification_photo', 'specialization', 'experience'
    ];

    $missing_fields = [];
    foreach ($required_fields as $field) {
        if (empty($$field)) {
            $missing_fields[] = $field;
        }
    }

    if (!empty($missing_fields)) {
        $response = [
            "error" => true,
            "message" => "Missing fields: " . implode(", ", $missing_fields)
        ];
        error_log("Error: Missing fields: " . implode(", ", $missing_fields));
        echo json_encode($response);
        exit;
    }

    // Connect to the database using connectDB()
    $conn = connectDB();

    // Insert query
    $sql = "INSERT INTO physio_physiotherapist (username, password, contact_no, email, gender, photo, appartment, landmark, area, city, pincode, clinic_start_time, clinic_end_time, home_visit_start_time, home_visit_end_time, qualification, qualification_photo, specialization, experience)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    // Prepare statement
    if ($stmt = $conn->prepare($sql)) {
        // Bind parameters to the prepared statement
        $stmt->bind_param("ssssssssssssssssss", $username, $password, $contact_no, $email, $gender, $photo, $appartment, $landmark, $area, $city, $pincode, $clinic_start_time, $clinic_end_time, $home_visit_start_time, $home_visit_end_time, $qualification, $qualification_photo, $specialization, $experience);

        // Debugging: Log the query before execution
        error_log("SQL Query: " . $sql);
        
        // Execute the statement
        if ($stmt->execute()) {
            $response = [
                "error" => false,
                "message" => "Registration Successful"
            ];
            error_log("Registration Successful: " . json_encode($response));
        } else {
            $response = [
                "error" => true,
                "message" => "Error: " . $stmt->error
            ];
            // Log the error if the query execution fails
            error_log("Query execution failed: " . $stmt->error);
        }

        // Close the statement
        $stmt->close();
    } else {
        // Error preparing the statement
        $response = [
            "error" => true,
            "message" => "Error preparing statement: " . $conn->error
        ];
        error_log("Error preparing SQL statement: " . $conn->error);
    }

    // Close the connection
    $conn->close();

    // Return response in JSON format
    echo json_encode($response);
} else {
    // If the request method is not POST
    $response = [
        "error" => true,
        "message" => "Invalid request method. Please use POST."
    ];
    echo json_encode($response);
}
?>
