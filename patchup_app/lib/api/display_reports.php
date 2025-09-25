<?php

/**
 * Fetch pothole reports.
 * Returns all reports or filters by user email if provided.
 */

// Establish database connection
require_once("../database/db_connection.php");

// Set response header for JSON output
header('Content-Type: application/json');

// Parse input and extract user email if present
$input = json_decode(file_get_contents('php://input'), true);
$userEmail = isset($input['UserEmail']) ? $input['UserEmail'] : null;

// Query reports, optionally filtered by user email
if ($userEmail) {
    $stmt = $conn->prepare(
        "SELECT p.*, 
                u.Name AS UserName,
                (SELECT COUNT(*) FROM pothole_validation pv WHERE pv.ReportID = p.ReportID) AS ValidationCount
         FROM potholereport p
         LEFT JOIN user u ON p.UserID = u.UserID
         WHERE u.Email = ?
         ORDER BY p.ReportID DESC"
    );
    $stmt->bind_param("s", $userEmail);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    $sql = "SELECT p.*,
                   u.Name AS UserName,
                   (SELECT COUNT(*) FROM pothole_validation pv WHERE pv.ReportID = p.ReportID) AS ValidationCount
            FROM potholereport p
            LEFT JOIN user u ON p.UserID = u.UserID
            ORDER BY p.ReportID DESC";
    $result = $conn->query($sql);
}

// Collect query results
$reports = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

// Output reports as JSON
echo json_encode($reports);

// Close database connection
$conn->close();
