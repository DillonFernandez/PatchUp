<?php

/**
 * Fetch user information by email.
 * Returns user ID, name, and email if found.
 */

// Set response type and connect to database
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';

if (!$email) {
    echo json_encode(["user_id" => null, "name" => "", "email" => ""]);
    exit;
}

// Query user ID, name, and email by email
$stmt = $conn->prepare("SELECT UserID, Name, Email FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($userId, $name, $emailResult);

// Output user info if found, otherwise return empty values
if ($stmt->fetch()) {
    echo json_encode(["user_id" => $userId, "name" => $name, "email" => $emailResult]);
} else {
    echo json_encode(["user_id" => null, "name" => "", "email" => ""]);
}

// Close resources
$stmt->close();
$conn->close();
