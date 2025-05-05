<?php
header('Content-Type: application/json');

// Include database configuration
require_once 'db_config.php';

// Include PHPMailer (assumes you have it installed via Composer or downloaded)
require 'vendor/autoload.php'; // If using Composer
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Get email from POST request
$data = json_decode(file_get_contents('php://input'), true);
$email = isset($data['email']) ? trim($data['email']) : '';

if (empty($email)) {
    echo json_encode(['status' => 'error', 'message' => 'Email is required']);
    exit();
}

// Connect to database
$conn = connectDB();

// Check if email exists in the patient_patient table
$stmt = $conn->prepare("SELECT * FROM patient_patient WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email not found']);
    $stmt->close();
    $conn->close();
    exit();
}

// Generate a 6-digit OTP
$otp = rand(100000, 999999);

// Store OTP in the database
$stmt = $conn->prepare("UPDATE patient_patient SET otp = ?, otp_expiry = DATE_ADD(NOW(), INTERVAL 10 MINUTE) WHERE email = ?");
$stmt->bind_param("ss", $otp, $email);
$stmt->execute();

// Send OTP via email using PHPMailer
$mail = new PHPMailer(true);

try {
    // Server settings
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com'; // Replace with your SMTP host
    $mail->SMTPAuth = true;
    $mail->Username = 'your_email@gmail.com'; // Replace with your email
    $mail->Password = 'your_app_password'; // Replace with your app-specific password
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    // Recipients
    $mail->setFrom('your_email@gmail.com', 'Heal with Physio');
    $mail->addAddress($email);

    // Content
    $mail->isHTML(true);
    $mail->Subject = 'Your OTP for Password Reset';
    $mail->Body    = "Your OTP is: <b>$otp</b>. It is valid for 10 minutes.";
    $mail->AltBody = "Your OTP is: $otp. It is valid for 10 minutes.";

    $mail->send();
    echo json_encode(['status' => 'success', 'message' => 'OTP sent to your email']);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send OTP: ' . $mail->ErrorInfo]);
}

// Close database connections
$stmt->close();
$conn->close();
?>