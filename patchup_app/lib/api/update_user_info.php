<?php

/**
 * Update user profile information (name and email).
 * Validates input, checks for duplicates, and updates user record.
 */

// Set response type and connect to database
header('Content-Type: application/json');
require_once('../database/db_connection.php');

// Parse and validate input
$input = json_decode(file_get_contents('php://input'), true);
if (!$input || !isset($input['OldEmail'], $input['Name'], $input['Email'])) {
    echo json_encode(['success' => false, 'message' => 'Invalid input']);
    exit;
}

$oldEmail = trim($input['OldEmail']);
$newName = trim($input['Name']);
$newEmail = trim($input['Email']);

if ($newName === '' || $newEmail === '') {
    echo json_encode(['success' => false, 'message' => 'Name and Email required']);
    exit;
}

// Check if user exists
$stmt = $conn->prepare("SELECT UserID FROM user WHERE Email = ?");
$stmt->bind_param("s", $oldEmail);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'User not found']);
    exit;
}
$stmt->bind_result($userId);
$stmt->fetch();
$stmt->close();

// If email changed, check for duplicate
if ($oldEmail !== $newEmail) {
    $stmt = $conn->prepare("SELECT UserID FROM user WHERE Email = ?");
    $stmt->bind_param("s", $newEmail);
    $stmt->execute();
    $stmt->store_result();
    if ($stmt->num_rows > 0) {
        echo json_encode(['success' => false, 'message' => 'Email already in use']);
        exit;
    }
    $stmt->close();
}

// Update user info
$stmt = $conn->prepare("UPDATE user SET Name = ?, Email = ? WHERE UserID = ?");
$stmt->bind_param("ssi", $newName, $newEmail, $userId);
if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Update failed']);
}
$stmt->close();
$conn->close();
