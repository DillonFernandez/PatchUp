<?php

/**
 * API endpoint to fetch chat messages for a pothole report.
 * Supports pagination, incremental fetch, and update polling.
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$input    = json_decode(file_get_contents("php://input"), true);
$reportID = isset($input['ReportID']) ? intval($input['ReportID']) : 0;
$limit    = isset($input['limit']) ? max(1, min(100, intval($input['limit']))) : 30;
$afterId  = isset($input['after_id']) ? intval($input['after_id']) : null;
$beforeId = isset($input['before_id']) ? intval($input['before_id']) : null;
$updatedSince = isset($input['updated_since']) ? $input['updated_since'] : null;

if ($reportID <= 0) {
    echo json_encode(["success" => false, "message" => "Invalid ReportID", "messages" => []]);
    exit;
}

// Build SQL query based on fetch mode
$params = [];
$sql = "";
$mode = "";

if ($afterId !== null && $afterId > 0) {
    // Fetch messages newer than a given ID
    $sql = "
        SELECT c.MessageID, c.ReportID, c.UserID, u.Name AS UserName,
               c.MessageText, c.CreatedAt, c.IsEdited, c.EditedAt, c.IsDeleted, c.IsAdmin
        FROM chat_messages c
        JOIN user u ON c.UserID = u.UserID
        WHERE c.ReportID = ?
          AND c.MessageID > ?
        ORDER BY c.MessageID ASC
        LIMIT ?
    ";
    $params = [$reportID, $afterId, $limit];
    $mode = "after";
} elseif ($beforeId !== null && $beforeId > 0) {
    // Fetch older messages (for upward scroll)
    $sql = "
        SELECT c.MessageID, c.ReportID, c.UserID, u.Name AS UserName,
               c.MessageText, c.CreatedAt, c.IsEdited, c.EditedAt, c.IsDeleted, c.IsAdmin
        FROM chat_messages c
        JOIN user u ON c.UserID = u.UserID
        WHERE c.ReportID = ?
          AND c.MessageID < ?
        ORDER BY c.MessageID DESC
        LIMIT ?
    ";
    $params = [$reportID, $beforeId, $limit];
    $mode = "before";
} elseif ($updatedSince !== null) {
    // Fetch messages updated or deleted since a timestamp
    $sql = "
        SELECT c.MessageID, c.ReportID, c.UserID, u.Name AS UserName,
               c.MessageText, c.CreatedAt, c.IsEdited, c.EditedAt, c.IsDeleted, c.IsAdmin
        FROM chat_messages c
        JOIN user u ON c.UserID = u.UserID
        WHERE c.ReportID = ?
          AND (
            (c.IsEdited = 1 AND c.EditedAt >= ?)
            OR 
            (c.IsDeleted = 1 AND GREATEST(COALESCE(c.EditedAt, c.CreatedAt), c.CreatedAt) >= ?)
          )
        ORDER BY c.MessageID ASC
    ";
    $params = [$reportID, $updatedSince, $updatedSince];
    $mode = "updates";
} else {
    // Fetch latest messages for initial window
    $sql = "
        SELECT c.MessageID, c.ReportID, c.UserID, u.Name AS UserName,
               c.MessageText, c.CreatedAt, c.IsEdited, c.EditedAt, c.IsDeleted, c.IsAdmin
        FROM chat_messages c
        JOIN user u ON c.UserID = u.UserID
        WHERE c.ReportID = ?
        ORDER BY c.MessageID DESC
        LIMIT ?
    ";
    $params = [$reportID, $limit];
    $mode = "latest";
}

// Prepare and execute SQL statement
$stmt = $conn->prepare($sql);

if ($mode === "after" || $mode === "before") {
    $stmt->bind_param("iii", $params[0], $params[1], $params[2]);
} elseif ($mode === "updates") {
    $stmt->bind_param("iss", $params[0], $params[1], $params[2]);
} else {
    $stmt->bind_param("ii", $params[0], $params[1]);
}

$stmt->execute();
$result = $stmt->get_result();
$rows = [];
while ($row = $result->fetch_assoc()) {
    $rows[] = $row;
}
$stmt->close();

// Reverse results for ascending order if needed
if ($mode === "before" || $mode === "latest") {
    $rows = array_reverse($rows);
}

// Get last message ID for pagination
$lastId = null;
if (!empty($rows)) {
    $lastId = end($rows)['MessageID'];
}

// Output messages as JSON
echo json_encode([
    "success" => true,
    "messages" => $rows,
    "last_id" => $lastId
]);

// Close the database connection
$conn->close();
