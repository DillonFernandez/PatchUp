<?php

/**
 * API endpoint to fetch confirmation counts for each pothole report.
 * Returns a mapping of ReportID to confirmation count.
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Query confirmation counts grouped by report
$sql = "SELECT ReportID, COUNT(*) as count FROM pothole_confirmation GROUP BY ReportID";
$result = $conn->query($sql);

$counts = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $counts[$row['ReportID']] = (int)$row['count'];
    }
}

// Output counts as JSON
echo json_encode($counts);

// Close the database connection
$conn->close();
