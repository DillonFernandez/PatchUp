<?php

/**
 * View Customers API
 * Allows admins to list all customers and view reports for a specific customer.
 */

session_start();
header('Content-Type: application/json');

// Authenticate admin session
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

// Connect to the database
require_once "../database/db_connection.php";

// Get action parameter to determine operation
$action = $_GET['action'] ?? '';

// List all customers
if ($action === 'list') {
    $customers = [];
    // Exclude emails that start with 'admin+' (admin aliases)
    $result = $conn->query("SELECT UserID, Name, Email, Points FROM user WHERE Email NOT LIKE 'admin+%@%' ORDER BY UserID ASC");
    while ($row = $result->fetch_assoc()) {
        $customers[] = $row;
    }
    echo json_encode(['customers' => $customers]);
    exit;
}

// List reports for a specific customer with optional filters
if ($action === 'reports' && isset($_GET['userid'])) {
    $userid = intval($_GET['userid']);
    $status = $_GET['status'] ?? 'All';
    $severity = $_GET['severity'] ?? 'All';
    $province = $_GET['province'] ?? 'All';

    $query = "SELECT ReportID, Description, SeverityLevel, ImageURL, Timestamp, Status, Province, Latitude, Longitude FROM potholereport WHERE UserID = ?";
    $params = [$userid];
    $types = "i";

    if ($status !== 'All') {
        $query .= " AND Status = ?";
        $params[] = $status;
        $types .= "s";
    }
    if ($severity !== 'All') {
        $query .= " AND SeverityLevel = ?";
        $params[] = $severity;
        $types .= "s";
    }
    if ($province !== 'All') {
        $query .= " AND Province = ?";
        $params[] = $province;
        $types .= "s";
    }
    $query .= " ORDER BY Timestamp DESC";

    $stmt = $conn->prepare($query);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();
    $reports = [];
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
    echo json_encode(['reports' => $reports]);
    exit;
}

// Handle invalid action requests
echo json_encode(['success' => false, 'message' => 'Invalid action']);
