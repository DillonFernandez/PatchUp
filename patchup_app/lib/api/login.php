<?php

/**
 * User login API.
 * Verifies email and password, returns success or error message.
 */

// Set response type and connect to database
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';
$password = $data["PasswordHash"] ?? '';

if (!$email || !$password) {
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit;
}

// Fetch password hash for given email
$stmt = $conn->prepare("SELECT PasswordHash FROM user WHERE Email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Invalid email or password"]);
    $stmt->close();
    $conn->close();
    exit;
}

// Verify password and respond
$stmt->bind_result($hash);
$stmt->fetch();

if (password_verify($password, $hash)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid email or password"]);
}

// Close resources
$stmt->close();
$conn->close();
