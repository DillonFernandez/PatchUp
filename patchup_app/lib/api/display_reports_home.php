<?php

/**
 * API endpoint to fetch the latest 5 pothole reports for the home page.
 * Returns report details along with the reporting user's name.
 */

// Connect to the database
require_once("../database/db_connection.php");

// Set response header for JSON
header('Content-Type: application/json');

// Fetch latest 5 pothole reports with user names
$sql = "SELECT p.*, u.Name AS UserName
        FROM potholereport p
        LEFT JOIN user u ON p.UserID = u.UserID
        ORDER BY p.ReportID DESC
        LIMIT 5";
$result = $conn->query($sql);

// Collect query results into an array
$reports = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

// Output reports as JSON
echo json_encode($reports);

// Close the database connection
$conn->close();
