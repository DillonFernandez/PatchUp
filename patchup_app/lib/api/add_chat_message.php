<?php

/**
 * API endpoint to add a chat message to a pothole report.
 * Expects JSON input: { "Email": "...", "ReportID": 123, "Message": "text" }
 * Returns the inserted message details or an error.
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$input = json_decode(file_get_contents("php://input"), true);
$email    = isset($input['Email'])    ? trim($input['Email']) : '';
$reportID = isset($input['ReportID']) ? intval($input['ReportID']) : 0;
$message  = isset($input['Message'])  ? trim($input['Message']) : '';

if ($email === '' || $reportID <= 0 || $message === '') {
    echo json_encode(["success" => false, "message" => "Missing or invalid fields"]);
    exit;
}

// Resolve user by email
$stmt = $conn->prepare("SELECT UserID, Name FROM user WHERE LOWER(Email)=LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($userID, $userName);
if (!$stmt->fetch()) {
    $stmt->close();
    $conn->close();
    echo json_encode(["success" => false, "message" => "User not found"]);
    exit;
}
$stmt->close();

// Verify that the report exists
$stmt = $conn->prepare("SELECT 1 FROM potholereport WHERE ReportID = ?");
$stmt->bind_param("i", $reportID);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows === 0) {
    $stmt->close();
    $conn->close();
    echo json_encode(["success" => false, "message" => "Report not found"]);
    exit;
}
$stmt->close();

// Guard against excessively long messages
if (mb_strlen($message) > 2000) {
    echo json_encode(["success" => false, "message" => "Message too long (max 2000 chars)"]);
    $conn->close();
    exit;
}

// Insert the chat message into the database
$stmt = $conn->prepare("
    INSERT INTO chat_messages (ReportID, UserID, MessageText)
    VALUES (?, ?, ?)
");
$stmt->bind_param("iis", $reportID, $userID, $message);

if ($stmt->execute()) {
    $newId = $stmt->insert_id;
    $stmt->close();

    // Fetch and return the inserted message details
    $stmt = $conn->prepare("
        SELECT c.MessageID, c.ReportID, c.UserID, u.Name AS UserName,
               c.MessageText, c.CreatedAt, c.IsEdited, c.EditedAt, c.IsDeleted, c.IsAdmin
        FROM chat_messages c
        JOIN user u ON c.UserID = u.UserID
        WHERE c.MessageID = ?
        LIMIT 1
    ");
    $stmt->bind_param("i", $newId);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $stmt->close();

    echo json_encode([
        "success" => true,
        "message" => $row
    ]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
    $stmt->close();
}

// Close the database connection
$conn->close();
