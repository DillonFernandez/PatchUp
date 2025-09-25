<?php

/**
 * API endpoint for fetching pothole report locations for heatmap visualization.
 * Supports filtering by user's own reports, reports validated by the user, or all reports.
 */

// Establish database connection
require_once("../database/db_connection.php");

// Parse input JSON for user email and mode
$input = json_decode(file_get_contents('php://input'), true);
$userEmail = isset($input['UserEmail']) ? trim($input['UserEmail']) : null;
$mode = isset($input['mode']) ? trim($input['mode']) : null;

// Query database for heatmap points based on mode and user email
if ($userEmail && $mode === 'my_reports') {
    // Fetch reports submitted by this user
    $stmt = $conn->prepare(
        "SELECT Latitude, Longitude, SeverityLevel
         FROM potholereport
         INNER JOIN user ON potholereport.UserID = user.UserID
         WHERE user.Email = ?
           AND Latitude IS NOT NULL
           AND Longitude IS NOT NULL"
    );
    $stmt->bind_param("s", $userEmail);
    $stmt->execute();
    $result = $stmt->get_result();
} else if ($userEmail && $mode === 'validated') {
    // Fetch reports validated by this user
    $stmt = $conn->prepare(
        "SELECT p.Latitude, p.Longitude, p.SeverityLevel
         FROM pothole_validation pv
         INNER JOIN user uv ON pv.UserID = uv.UserID
         INNER JOIN potholereport p ON pv.ReportID = p.ReportID
         WHERE uv.Email = ?
           AND p.Latitude IS NOT NULL
           AND p.Longitude IS NOT NULL
         GROUP BY p.ReportID, p.Latitude, p.Longitude, p.SeverityLevel"
    );
    $stmt->bind_param("s", $userEmail);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    // Fetch all reports with coordinates
    $result = $conn->query(
        "SELECT Latitude, Longitude, SeverityLevel
         FROM potholereport
         WHERE Latitude IS NOT NULL
           AND Longitude IS NOT NULL"
    );
}

// Format query results for heatmap output
$reports = [];
while ($row = $result->fetch_assoc()) {
    $reports[] = [
        'latitude' => (float)$row['Latitude'],
        'longitude' => (float)$row['Longitude'],
        'severity' => $row['SeverityLevel'],
    ];
}

// Close database resources
if (isset($stmt)) $stmt->close();
$conn->close();

// Output results as JSON
header('Content-Type: application/json');
echo json_encode($reports);
