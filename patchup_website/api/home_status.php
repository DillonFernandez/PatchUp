<?php

/**
 * Home Status API
 * Provides summary statistics and data for the admin dashboard.
 */

session_start();

// Admin authentication
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

// FIX: always resolve from this file's directory
require_once(__DIR__ . '/../database/db_connection.php');

// Total reports
$totalReports = $conn->query("SELECT COUNT(*) AS total FROM potholereport")->fetch_assoc()['total'] ?? 0;

// NEW: real count for current month
$reportsThisMonth = $conn->query("
    SELECT COUNT(*) AS c
    FROM potholereport
    WHERE YEAR(Timestamp) = YEAR(CURDATE())
      AND MONTH(Timestamp) = MONTH(CURDATE())
")->fetch_assoc()['c'] ?? 0;

// Status breakdown
$statusData = [];
$statusResult = $conn->query("SELECT Status, COUNT(*) AS count FROM potholereport GROUP BY Status");
while ($row = $statusResult->fetch_assoc()) {
    $statusData[$row['Status']] = (int)$row['count'];
}

// Severity breakdown
$severityData = [];
$severityResult = $conn->query("SELECT SeverityLevel, COUNT(*) AS count FROM potholereport GROUP BY SeverityLevel");
while ($row = $severityResult->fetch_assoc()) {
    $severityData[$row['SeverityLevel']] = (int)$row['count'];
}

// Top users (by report submissions)
$topUsers = $conn->query("
    SELECT u.Name, COUNT(p.ReportID) AS totalReports 
    FROM user u 
    JOIN potholereport p ON u.UserID = p.UserID 
    GROUP BY u.UserID 
    ORDER BY totalReports DESC 
    LIMIT 5
");

// Latest reports
$latestReports = $conn->query("
    SELECT p.ReportID, p.Description, p.Status, p.ImageURL, u.Name 
    FROM potholereport p 
    JOIN user u ON p.UserID = u.UserID 
    ORDER BY p.Timestamp DESC 
    LIMIT 5
");

// Top 5 provinces by report count and percentage
$provinceStats = [];
$provinceResult = $conn->query("
    SELECT Province, COUNT(*) AS reportCount
    FROM potholereport
    GROUP BY Province
    ORDER BY reportCount DESC
    LIMIT 5
");
$totalReportsFloat = $totalReports > 0 ? $totalReports : 1; // avoid division by zero
while ($row = $provinceResult->fetch_assoc()) {
    $row['percent'] = round(($row['reportCount'] / $totalReportsFloat) * 100, 1);
    $provinceStats[] = $row;
}
