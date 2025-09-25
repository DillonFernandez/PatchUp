<?php

/**
 * API endpoint for fetching pothole reports validated by a specific user.
 * Returns report details, validation count, and report owner's name.
 */

// Establish database connection
require_once("../database/db_connection.php");
header('Content-Type: application/json');

// Parse input JSON for user email
$input = json_decode(file_get_contents('php://input'), true);
$userEmail = isset($input['UserEmail']) ? trim($input['UserEmail']) : null;

// Return empty array if user email is not provided
if (!$userEmail) {
    echo json_encode([]);
    exit;
}

// Query database for reports validated by the user
$stmt = $conn->prepare(
    "SELECT 
        p.ReportID,
        p.Description,
        p.SeverityLevel,
        p.ImageURL,
        p.Timestamp,
        p.Status,
        p.Province,
        p.Latitude,
        p.Longitude,
        owner.Name AS UserName,
        COUNT(DISTINCT allv.ValidationID) AS ValidationCount,
        MAX(userV.Timestamp) AS UserValidatedAt
     FROM pothole_validation userV
     INNER JOIN user validator ON userV.UserID = validator.UserID
     INNER JOIN potholereport p ON userV.ReportID = p.ReportID
     INNER JOIN user owner ON p.UserID = owner.UserID
     LEFT JOIN pothole_validation allv ON allv.ReportID = p.ReportID
     WHERE validator.Email = ?
     GROUP BY p.ReportID
     ORDER BY p.Timestamp DESC"
);
$stmt->bind_param("s", $userEmail);
$stmt->execute();
$res = $stmt->get_result();

// Collect query results
$out = [];
while ($row = $res->fetch_assoc()) {
    $out[] = $row;
}

// Close database resources
$stmt->close();
$conn->close();

// Output results as JSON
echo json_encode($out);
