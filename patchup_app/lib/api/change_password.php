<?php

/**
 * Change user password.
 * Validates current password, checks user, and updates password hash.
 */

// Set response type and connect to database
header('Content-Type: application/json');
require_once('../database/db_connection.php');

// Parse and validate input
$input = json_decode(file_get_contents('php://input'), true);
$email = trim($input['Email'] ?? '');
$current = $input['CurrentPassword'] ?? '';
$new = $input['NewPassword'] ?? '';

if (!$email || !$current || !$new) {
    echo json_encode(['success' => false, 'message' => 'Missing fields']);
    exit;
}

// Fetch user and current hash
$stmt = $conn->prepare("SELECT UserID, PasswordHash FROM user WHERE Email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'User not found']);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->bind_result($userId, $hash);
$stmt->fetch();
$stmt->close();

if (!password_verify($current, $hash)) {
    echo json_encode(['success' => false, 'message' => 'Current password incorrect']);
    $conn->close();
    exit;
}

// Update password
$newHash = password_hash($new, PASSWORD_DEFAULT);
$stmt = $conn->prepare("UPDATE user SET PasswordHash = ? WHERE UserID = ?");
$stmt->bind_param("si", $newHash, $userId);
if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Failed to update password']);
}
$stmt->close();
$conn->close();
