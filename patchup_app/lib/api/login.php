<?php

/**
 * API endpoint for user login.
 * Verifies email and password, returns success or error message.
 */

// Set response type to JSON
header("Content-Type: application/json");

// Include database connection
include_once("../database/db_connection.php");

// Parse and validate input
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';
$password = $data["PasswordHash"] ?? '';

// Check for missing fields
if (!$email || !$password) {
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit;
}

// Prepare SQL statement to fetch password hash for given email
$stmt = $conn->prepare("SELECT PasswordHash FROM user WHERE Email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

// Check if user exists
if ($stmt->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Invalid email or password"]);
    $stmt->close();
    $conn->close();
    exit;
}

// Retrieve password hash from database
$stmt->bind_result($hash);
$stmt->fetch();

// Verify password and respond accordingly
if (password_verify($password, $hash)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid email or password"]);
}

// Close statement and database connection
$stmt->close();
$conn->close();
