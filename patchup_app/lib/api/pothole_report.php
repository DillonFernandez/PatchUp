<?php

/**
 * API endpoint to submit a new pothole report.
 * Handles image upload, user lookup, duplicate detection, validation, and report creation.
 */

// Enable error reporting (development only)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
require_once("../database/db_connection.php");

// Extract and validate input
$province  = trim($_POST['Province'] ?? '');
$latRaw    = trim($_POST['Latitude'] ?? '');
$lngRaw    = trim($_POST['Longitude'] ?? '');
$desc      = $_POST['Description'] ?? '';
$severity  = $_POST['SeverityLevel'] ?? '';
$userEmail = trim($_POST['UserEmail'] ?? '');

if ($province === '' || $latRaw === '' || $lngRaw === '' || $userEmail === '') {
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'message' => 'Missing required fields.']);
    exit;
}

$lat = floatval($latRaw);
$lng = floatval($lngRaw);

// Handle image upload
$imageUrl = '';
if (isset($_FILES['Image']) && $_FILES['Image']['error'] == UPLOAD_ERR_OK) {
    $uploadDir = '../../uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    $filename   = uniqid('img_') . '_' . basename($_FILES['Image']['name']);
    $targetFile = $uploadDir . $filename;
    if (move_uploaded_file($_FILES['Image']['tmp_name'], $targetFile)) {
        $imageUrl = '/patchup_app/uploads/' . $filename;
    }
}

// Debug log for received POST data
file_put_contents("php://stderr", "Received: Province=$province, Latitude=$lat, Longitude=$lng, Description=$desc, SeverityLevel=$severity, UserEmail=$userEmail\n");

// Set JSON header for response
header('Content-Type: application/json');

// Helper: send JSON response and exit
function respond($arr)
{
    echo json_encode($arr);
    exit;
}

// User lookup
$DUP_DISTANCE_METERS = 12.0;
$stmtUser = $conn->prepare("SELECT UserID FROM user WHERE LOWER(Email) = LOWER(?)");
if ($stmtUser === false) {
    respond(['success' => false, 'message' => 'User lookup prepare failed']);
}
$stmtUser->bind_param("s", $userEmail);
$stmtUser->execute();
$stmtUser->bind_result($userId);
if (!$stmtUser->fetch()) {
    $stmtUser->close();
    $conn->close();
    respond(['success' => false, 'message' => 'User not found']);
}
$stmtUser->close();

// Duplicate detection and validation
$dupStmt = $conn->prepare("
    SELECT 
        ReportID,
        UserID AS OwnerUserID,
        Province,
        Latitude,
        Longitude,
        Description,
        SeverityLevel,
        ImageURL,
        Status,
        Timestamp,
        (
          6371000 * 2 * ASIN(
            SQRT(
              POWER(SIN(RADIANS(? - Latitude)/2),2) +
              COS(RADIANS(Latitude))*COS(RADIANS(?))*
              POWER(SIN(RADIANS(? - Longitude)/2),2)
            )
          )
        ) AS distance
    FROM potholereport
    WHERE (Status IS NULL OR Status NOT IN ('Resolved','Closed','Completed'))
    HAVING distance <= ?
    ORDER BY distance ASC
    LIMIT 1
");
if ($dupStmt) {
    $dupStmt->bind_param("dddd", $lat, $lat, $lng, $DUP_DISTANCE_METERS);
    $dupStmt->execute();
    $dupResult = $dupStmt->get_result();
    if ($dupResult && $dupResult->num_rows > 0) {
        $existing = $dupResult->fetch_assoc();
        file_put_contents("php://stderr", "Duplicate found: ReportID={$existing['ReportID']}, distance={$existing['distance']}\n");
        $dupStmt->close();

        $existingReportId = (int)$existing['ReportID'];
        $existingOwnerId  = (int)$existing['OwnerUserID'];
        $action = 'validated_existing';
        $validationInserted = false;
        $alreadyValidated = false;

        // If another user's report, check if already validated
        if ($existingOwnerId !== $userId) {
            $checkValStmt = $conn->prepare("SELECT 1 FROM pothole_validation WHERE ReportID = ? AND UserID = ?");
            if ($checkValStmt) {
                $checkValStmt->bind_param("ii", $existingReportId, $userId);
                $checkValStmt->execute();
                $checkValStmt->store_result();
                if ($checkValStmt->num_rows > 0) {
                    $alreadyValidated = true;
                }
                $checkValStmt->close();
            }

            if (!$alreadyValidated) {
                $valStmt = $conn->prepare("INSERT IGNORE INTO pothole_validation (ReportID, UserID) VALUES (?, ?)");
                if ($valStmt) {
                    $valStmt->bind_param("ii", $existingReportId, $userId);
                    $valStmt->execute();
                    $validationInserted = $valStmt->affected_rows > 0;
                    $valStmt->close();
                }
            }
        } else {
            $action = 'duplicate_own_report';
        }

        if ($alreadyValidated) {
            respond([
                'success' => true,
                'action' => 'validated_existing',
                'existing_report_id' => $existingReportId,
                'existing_report' => [
                    'ReportID'      => $existing['ReportID'],
                    'Province'      => $existing['Province'],
                    'Latitude'      => (float)$existing['Latitude'],
                    'Longitude'     => (float)$existing['Longitude'],
                    'Description'   => $existing['Description'],
                    'SeverityLevel' => $existing['SeverityLevel'],
                    'ImageURL'      => $existing['ImageURL'],
                    'Status'        => $existing['Status'],
                    'Timestamp'     => $existing['Timestamp'],
                ],
                'validation_inserted' => false,
                'message' => 'You have already validated this pothole report.'
            ]);
        }

        respond([
            'success' => true,
            'action' => $action,
            'existing_report_id' => $existingReportId,
            'existing_report' => [
                'ReportID'      => $existing['ReportID'],
                'Province'      => $existing['Province'],
                'Latitude'      => (float)$existing['Latitude'],
                'Longitude'     => (float)$existing['Longitude'],
                'Description'   => $existing['Description'],
                'SeverityLevel' => $existing['SeverityLevel'],
                'ImageURL'      => $existing['ImageURL'],
                'Status'        => $existing['Status'],
                'Timestamp'     => $existing['Timestamp'],
            ],
            'validation_inserted' => $validationInserted,
            'message' => $action === 'validated_existing'
                ? ($validationInserted
                    ? 'Existing pothole confirmed.'
                    : 'Existing pothole already validated previously.')
                : 'You have already reported this pothole (status still ' . $existing['Status'] . ').'
        ]);
    }
    $dupStmt->close();
}

// Insert new report if no duplicate
$stmt = $conn->prepare("INSERT INTO potholereport (UserID, Province, Latitude, Longitude, Description, SeverityLevel, ImageURL) VALUES (?, ?, ?, ?, ?, ?, ?)");
if ($stmt === false) {
    respond(['success' => false, 'message' => 'Prepare failed: ' . $conn->error]);
}
$stmt->bind_param("isddsss", $userId, $province, $lat, $lng, $desc, $severity, $imageUrl);
if (!$stmt->execute()) {
    $err = $stmt->error;
    $stmt->close();
    respond(['success' => false, 'message' => 'Execute failed: ' . $err]);
}
$newReportId = $stmt->insert_id;
$stmt->close();

// Success response
respond([
    'success' => true,
    'action' => 'created_new',
    'report_id' => $newReportId,
    'image_url' => $imageUrl,
    'message' => 'Pothole reported successfully.'
]);

// Cleanup
$conn->close();
