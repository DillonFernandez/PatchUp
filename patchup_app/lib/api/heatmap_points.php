<?php

/**
 * API endpoint to fetch pothole report locations for heatmap visualization.
 * Returns latitude, longitude, and severity for all or filtered by user email.
 */

// Database connection
require_once("../database/db_connection.php");

// Parse input and extract user email if present
$input = json_decode(file_get_contents('php://input'), true);
$userEmail = isset($input['UserEmail']) ? $input['UserEmail'] : null;

// Fetch heatmap points, optionally filtered by user email
if ($userEmail) {
    $stmt = $conn->prepare(
        "SELECT p.Latitude, p.Longitude, p.SeverityLevel
         FROM potholereport p
         LEFT JOIN user u ON p.UserID = u.UserID
         WHERE u.Email = ? AND p.Latitude IS NOT NULL AND p.Longitude IS NOT NULL"
    );
    $stmt->bind_param("s", $userEmail);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    $result = $conn->query("SELECT Latitude, Longitude, SeverityLevel FROM potholereport WHERE Latitude IS NOT NULL AND Longitude IS NOT NULL");
}

// Collect query results into array for heatmap
$reports = [];
while ($row = $result->fetch_assoc()) {
    $reports[] = [
        'latitude' => floatval($row['Latitude']),
        'longitude' => floatval($row['Longitude']),
        'severity' => $row['SeverityLevel'],
    ];
}

// Close the database connection
$conn->close();

// Output heatmap points as JSON
header('Content-Type: application/json');
echo json_encode($reports);
