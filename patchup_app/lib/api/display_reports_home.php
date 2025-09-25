<?php

/**
 * Fetch the latest 5 pothole reports for the home page.
 * Includes report details, reporting user's name, and validation count.
 */

// Establish database connection
require_once("../database/db_connection.php");

// Set response header for JSON output
header('Content-Type: application/json');

// Query for latest 5 reports with user name and validation count
$sql = "SELECT p.*,
               u.Name AS UserName,
               (SELECT COUNT(*) FROM pothole_validation pv WHERE pv.ReportID = p.ReportID) AS ValidationCount
        FROM potholereport p
        LEFT JOIN user u ON p.UserID = u.UserID
        ORDER BY p.ReportID DESC
        LIMIT 5";
$result = $conn->query($sql);

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
