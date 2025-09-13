<?php

/**
 * API endpoint to soft-delete a chat message for a given user.
 * Expects JSON input: { "Email": "...", "MessageID": 123 }
 * Returns the updated message details or an error.
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$input     = json_decode(file_get_contents("php://input"), true);
$email     = isset($input['Email']) ? trim($input['Email']) : '';
$messageID = isset($input['MessageID']) ? intval($input['MessageID']) : 0;

if ($email === '' || $messageID <= 0) {
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit;
}

// Resolve user by email
$stmt = $conn->prepare("SELECT UserID FROM user WHERE LOWER(Email)=LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($userID);
if (!$stmt->fetch()) {
    $stmt->close();
    $conn->close();
    echo json_encode(["success" => false, "message" => "User not found"]);
    exit;
}
$stmt->close();

// Soft delete the chat message and update EditedAt timestamp
$stmt = $conn->prepare("
    UPDATE chat_messages
       SET IsDeleted = 1, EditedAt = NOW()
     WHERE MessageID = ? AND UserID = ? AND IsDeleted = 0
    LIMIT 1
");
$stmt->bind_param("ii", $messageID, $userID);
$stmt->execute();

if ($stmt->affected_rows === 1) {
    $stmt->close();
    // Fetch and return the updated message details
    $stmt = $conn->prepare("
        SELECT c.MessageID, c.ReportID, c.UserID, u.Name AS UserName,
               c.MessageText, c.CreatedAt, c.IsEdited, c.EditedAt, c.IsDeleted, c.IsAdmin
        FROM chat_messages c
        JOIN user u ON c.UserID = u.UserID
        WHERE c.MessageID = ?
        LIMIT 1
    ");
    $stmt->bind_param("i", $messageID);
    $stmt->execute();
    $res = $stmt->get_result();
    $row = $res->fetch_assoc();
    $stmt->close();
    echo json_encode(["success" => true, "message" => $row]);
} else {
    echo json_encode(["success" => false, "message" => "Delete failed"]);
}
$stmt->close();

// Close the database connection
$conn->close();
