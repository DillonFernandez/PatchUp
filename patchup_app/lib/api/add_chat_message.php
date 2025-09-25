<?php

/**
 * Add a chat message to a pothole report.
 * Only the report owner or an admin can send messages.
 * Admin messages are flagged with IsAdmin=1.
 * Expects JSON: { "Email": "...", "ReportID": 123, "Message": "text" }
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$input    = json_decode(file_get_contents("php://input"), true);
$email    = isset($input['Email'])    ? trim($input['Email']) : '';
$reportID = isset($input['ReportID']) ? intval($input['ReportID']) : 0;
$message  = isset($input['Message'])  ? trim($input['Message']) : '';

if ($email === '' || $reportID <= 0 || $message === '') {
    echo json_encode(["success" => false, "message" => "Missing or invalid fields"]);
    exit;
}

// Enforce message length limit
if (mb_strlen($message) > 2000) {
    echo json_encode(["success" => false, "message" => "Message too long (max 2000 chars)"]);
    exit;
}

// Identify sender as user or admin
$isAdmin   = 0;
$actorId   = null;
$actorName = null;

// Check if sender is a normal user
$stmt = $conn->prepare("SELECT UserID, Name FROM user WHERE LOWER(Email)=LOWER(?) LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($uid, $uname);
if ($stmt->fetch()) {
    $actorId   = (int)$uid;
    $actorName = $uname;
    $isAdmin   = 0;
}
$stmt->close();

// If not a user, check if sender is an admin
if ($actorId === null) {
    $stmt = $conn->prepare("SELECT AdminID, Name FROM admin WHERE LOWER(Email)=LOWER(?) LIMIT 1");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->bind_result($aid, $aname);
    if ($stmt->fetch()) {
        $actorId   = (int)$aid;
        $actorName = $aname;
        $isAdmin   = 1;
    }
    $stmt->close();
}

// Reject if sender is neither user nor admin
if ($actorId === null) {
    $conn->close();
    echo json_encode(["success" => false, "message" => "User/Admin not found"]);
    exit;
}

// Verify report exists and check ownership if sender is user
$stmt = $conn->prepare("SELECT UserID FROM potholereport WHERE ReportID = ? LIMIT 1");
$stmt->bind_param("i", $reportID);
$stmt->execute();
$stmt->bind_result($reportOwnerId);
if (!$stmt->fetch()) {
    $stmt->close();
    $conn->close();
    echo json_encode(["success" => false, "message" => "Report not found"]);
    exit;
}
$stmt->close();

// Enforce ownership for normal users
if ($isAdmin === 0 && (int)$reportOwnerId !== $actorId) {
    $conn->close();
    echo json_encode([
        "success" => false,
        "message" => "Not authorized to chat on this report"
    ]);
    exit;
}

// Insert chat message into database
if ($isAdmin) {
    $stmt = $conn->prepare("
        INSERT INTO chat_messages (ReportID, UserID, MessageText, IsAdmin)
        VALUES (?, ?, ?, 1)
    ");
} else {
    $stmt = $conn->prepare("
        INSERT INTO chat_messages (ReportID, UserID, MessageText, IsAdmin)
        VALUES (?, ?, ?, 0)
    ");
}

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
    $conn->close();
    exit;
}

$stmt->bind_param("iis", $reportID, $actorId, $message);

if ($stmt->execute()) {
    $newId = $stmt->insert_id;
    $stmt->close();

    // Retrieve the inserted message for response
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
    $stmt->bind_param("i", $newId);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $stmt->close();

    // Supply admin name if needed for UI consistency
    if ($row && intval($row['IsAdmin']) === 1 && (empty($row['UserName']))) {
        $row['UserName'] = $actorName ?? 'Admin';
    }

    echo json_encode([
        "success" => true,
        "message" => $row
    ]);
} else {
    $err = $stmt->error;
    $stmt->close();
    echo json_encode(["success" => false, "message" => $err]);
}

$conn->close();
