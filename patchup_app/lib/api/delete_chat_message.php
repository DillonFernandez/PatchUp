<?php

/**
 * Soft-delete a chat message.
 * Admins can delete any message; users can delete their own message only if they own the report.
 * Soft delete sets IsDeleted=1 and EditedAt=NOW().
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

// Identify actor as user or admin
$isAdmin = 0;
$actorId = null;

// Check if actor is a user
$stmt = $conn->prepare("SELECT UserID FROM user WHERE LOWER(Email)=LOWER(?) LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($uid);
if ($stmt->fetch()) {
    $actorId = (int)$uid;
    $isAdmin = 0;
}
$stmt->close();

// If not a user, check if actor is an admin
if ($actorId === null) {
    $stmt = $conn->prepare("SELECT AdminID FROM admin WHERE LOWER(Email)=LOWER(?) LIMIT 1");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->bind_result($aid);
    if ($stmt->fetch()) {
        $actorId = (int)$aid;
        $isAdmin = 1;
    }
    $stmt->close();
}

// Reject if actor is neither user nor admin
if ($actorId === null) {
    echo json_encode(["success" => false, "message" => "User/Admin not found"]);
    $conn->close();
    exit;
}

// Perform soft-delete based on role
if ($isAdmin) {
    $stmt = $conn->prepare("
        UPDATE chat_messages
           SET IsDeleted = 1, EditedAt = NOW()
         WHERE MessageID = ? AND IsDeleted = 0
         LIMIT 1
    ");
    $stmt->bind_param("i", $messageID);
} else {
    $stmt = $conn->prepare("
        UPDATE chat_messages c
        JOIN potholereport p ON p.ReportID = c.ReportID
           SET c.IsDeleted = 1, c.EditedAt = NOW()
         WHERE c.MessageID = ?
           AND c.UserID = ?
           AND p.UserID = ?
           AND c.IsDeleted = 0
         LIMIT 1
    ");
    $stmt->bind_param("iii", $messageID, $actorId, $actorId);
}

$stmt->execute();
if ($stmt->affected_rows !== 1) {
    $stmt->close();
    echo json_encode(["success" => false, "message" => "Not authorized or delete failed"]);
    $conn->close();
    exit;
}
$stmt->close();

// Return the updated message for response
$stmt = $conn->prepare("
    SELECT c.MessageID, c.ReportID, c.UserID,
           u.Name AS UserName,
           c.MessageText, c.CreatedAt, c.IsEdited, c.EditedAt,
           c.IsDeleted, c.IsAdmin
      FROM chat_messages c
      LEFT JOIN user u ON c.UserID = u.UserID
     WHERE c.MessageID = ?
     LIMIT 1
");
$stmt->bind_param("i", $messageID);
$stmt->execute();
$res = $stmt->get_result();
$row = $res->fetch_assoc();
$stmt->close();

echo json_encode(["success" => true, "message" => $row]);
$conn->close();
