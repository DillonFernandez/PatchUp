<?php

/**
 * API endpoint to confirm a pothole report by a user.
 * Awards points for confirmation and prevents duplicate confirmations.
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$input = json_decode(file_get_contents("php://input"), true);
$userEmail = isset($input['UserEmail']) ? $input['UserEmail'] : null;
$reportId = isset($input['ReportID']) ? intval($input['ReportID']) : 0;

if (!$userEmail || !$reportId) {
    echo json_encode(["success" => false, "message" => "Missing parameters"]);
    exit;
}

// Resolve user by email
$stmt = $conn->prepare("SELECT UserID FROM user WHERE Email = ?");
$stmt->bind_param("s", $userEmail);
$stmt->execute();
$stmt->bind_result($userId);
if (!$stmt->fetch()) {
    echo json_encode(["success" => false, "message" => "User not found"]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Check if user has already confirmed this report
$stmt = $conn->prepare("SELECT 1 FROM pothole_confirmation WHERE ReportID = ? AND UserID = ?");
$stmt->bind_param("ii", $reportId, $userId);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Already confirmed"]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Insert confirmation record
$stmt = $conn->prepare("INSERT INTO pothole_confirmation (ReportID, UserID) VALUES (?, ?)");
$stmt->bind_param("ii", $reportId, $userId);
if ($stmt->execute()) {
    // Award points to the user for confirming
    $stmtPoints = $conn->prepare("UPDATE user SET Points = Points + 5 WHERE UserID = ?");
    if ($stmtPoints) {
        $stmtPoints->bind_param("i", $userId);
        $stmtPoints->execute();
        $stmtPoints->close();
    }
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$stmt->close();

// Close the database connection
$conn->close();
