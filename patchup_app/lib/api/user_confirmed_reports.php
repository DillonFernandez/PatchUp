<?php

/**
 * API endpoint to fetch report IDs confirmed by a user.
 * Returns an array of ReportIDs for the given user email.
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$input = json_decode(file_get_contents("php://input"), true);
$userEmail = isset($input['UserEmail']) ? $input['UserEmail'] : null;

if (!$userEmail) {
    echo json_encode([]);
    exit;
}

// Fetch confirmed report IDs for the user
$stmt = $conn->prepare(
    "SELECT pc.ReportID
     FROM pothole_confirmation pc
     JOIN user u ON pc.UserID = u.UserID
     WHERE u.Email = ?"
);
$stmt->bind_param("s", $userEmail);
$stmt->execute();
$result = $stmt->get_result();

$reportIds = [];
while ($row = $result->fetch_assoc()) {
    $reportIds[] = (int)$row['ReportID'];
}

// Output report IDs as JSON
echo json_encode($reportIds);

$stmt->close();
$conn->close();
