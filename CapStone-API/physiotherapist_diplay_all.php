<?php
// get_physiotherapists.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'db_config.php';

try {
    $conn = connectDB();
    
    $query = "SELECT id, username, password, contact_no, email, gender, photo, appartment, 
                     landmark, area, city, pincode, clinic_start_time, clinic_end_time, 
                     home_visit_start_time, home_visit_end_time, qualification, 
                     qualification_photo, specialization, experience, name 
              FROM physio_physiotherapist";
    $result = $conn->query($query);
    
    if ($result) {
        $physiotherapists = [];
        
        while ($row = $result->fetch_assoc()) {
            $physiotherapists[] = [
                'id' => $row['id'],
                'name' => $row['name'],
                'specialization' => $row['specialization'],
                'photo' => $row['photo'],
                'email' => $row['email'],
                'gender' => $row['gender'],
                'qualification' => $row['qualification'],
                'experience' => $row['experience'],
                'contact_no' => $row['contact_no'],
                'appartment' => $row['appartment'],
                'city' => $row['city'],
                'clinic_start_time' => $row['clinic_start_time'],
                'clinic_end_time' => $row['clinic_end_time'],
                'home_visit_start_time' => $row['home_visit_start_time'],
                'home_visit_end_time' => $row['home_visit_end_time'],
            ];
        }
        
        echo json_encode([
            'status' => 'success',
            'data' => $physiotherapists
        ]);
        
        $result->free();
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Query failed: ' . $conn->error
        ]);
    }
    
    $conn->close();
    
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}
?>