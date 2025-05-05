<?php
session_start();

// Unset all session variables
session_unset();

// Destroy session
session_destroy();

echo json_encode(["message" => "Logged out successfully"]);
?>
