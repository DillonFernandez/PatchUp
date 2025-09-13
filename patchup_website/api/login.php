<?php

/**
 * Admin Login API
 * Authenticates admin users and starts a session if credentials are valid.
 */

// Set JSON Response Header
header('Content-Type: application/json');

// Connect to the database
require_once("../database/db_connection.php");

// Retrieve and sanitize POST input
$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

// Validate required fields
if (!$name || !$email || !$password) {
    echo json_encode(['success' => false, 'message' => 'All fields are required.']);
    exit;
}

// Query admin table for matching user
$stmt = $conn->prepare("SELECT * FROM admin WHERE Name=? AND Email=?");
$stmt->bind_param("ss", $name, $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

// Validate credentials and manage session
if ($user && $user['PasswordHash'] === $password) {
    session_start();
    session_regenerate_id(true);
    $_SESSION['admin_logged_in'] = true;
    $_SESSION['admin_name'] = $user['Name'];
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid credentials.']);
}

// Clean up resources
$stmt->close();
$conn->close();
