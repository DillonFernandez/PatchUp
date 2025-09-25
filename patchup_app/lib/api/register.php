<?php

/**
 * User registration API.
 * Validates input, checks for duplicates, enforces password rules, and creates a new user.
 */

// Set response type and connect to database
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and sanitize input
$data = json_decode(file_get_contents("php://input"), true);
$name = trim($data["Name"] ?? '');
$email = trim($data["Email"] ?? '');
$password = $data["PasswordHash"] ?? '';

// Validate name format
if (!$name || !preg_match("/^[a-zA-Z][a-zA-Z\s'-]{1,99}$/", $name)) {
    echo json_encode(["success" => false, "message" => "Invalid name format"]);
    exit;
}

// Validate email format
if (!$email || !preg_match("/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/", $email)) {
    echo json_encode(["success" => false, "message" => "Invalid email format"]);
    exit;
}

// Check if email is already registered
$stmt = $conn->prepare("SELECT 1 FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Email already registered"]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Validate password strength and format
if (
    !$password ||
    strlen($password) < 8 ||
    !preg_match("/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/", $password)
) {
    echo json_encode(["success" => false, "message" => "Password must be at least 8 characters and include uppercase, lowercase, number, and special character"]);
    exit;
}

// Check password against denylist of common passwords
$common_passwords = [
    "password",
    "123456",
    "12345678",
    "qwerty",
    "abc123",
    "111111",
    "123456789",
    "12345",
    "123123",
    "admin"
];
if (in_array(strtolower($password), $common_passwords)) {
    echo json_encode(["success" => false, "message" => "Password is too common"]);
    exit;
}

// Hash the password for secure storage
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

// Insert new user into database
$stmt = $conn->prepare("INSERT INTO user (Name, Email, PasswordHash) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $name, $email, $passwordHash);

// Respond with success or error message
if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}

// Close resources
$stmt->close();
$conn->close();
