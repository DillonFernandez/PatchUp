<?php

/**
 * Home Status API
 * Provides summary statistics and data for the admin dashboard:
 * - Total reports, status breakdown, severity breakdown,
 *   top users, and latest reports.
 */

session_start();

// Admin authentication: Redirect to login if not logged in
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

// Connect to the database
include 'database/db_connection.php';

// Get total number of pothole reports
$totalReports = $conn->query("SELECT COUNT(*) as total FROM potholereport")->fetch_assoc()['total'];

// Get report count grouped by status
$statusData = [];
$statusResult = $conn->query("SELECT Status, COUNT(*) as count FROM potholereport GROUP BY Status");
while ($row = $statusResult->fetch_assoc()) {
    $statusData[$row['Status']] = $row['count'];
}

// Get report count grouped by severity level
$severityData = [];
$severityResult = $conn->query("SELECT SeverityLevel, COUNT(*) as count FROM potholereport GROUP BY SeverityLevel");
while ($row = $severityResult->fetch_assoc()) {
    $severityData[$row['SeverityLevel']] = $row['count'];
}

// Get top 5 users by number of report submissions
$topUsers = $conn->query("SELECT u.Name, COUNT(p.ReportID) as totalReports 
    FROM user u 
    JOIN potholereport p ON u.UserID = p.UserID 
    GROUP BY u.UserID 
    ORDER BY totalReports DESC LIMIT 5");

// Get 5 most recent pothole reports
$latestReports = $conn->query("SELECT p.ReportID, p.Description, p.Status, p.ImageURL, u.Name 
    FROM potholereport p 
    JOIN user u ON p.UserID = u.UserID 
    ORDER BY p.Timestamp DESC LIMIT 5");
