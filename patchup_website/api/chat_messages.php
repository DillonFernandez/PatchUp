<?php

/**
 * Chat Messages API
 * Handles fetching and posting chat messages related to pothole reports.
 * - GET: Returns all messages for a given report or batch message counts.
 * - POST: Allows admin to post a message to a report.
 */

session_start();

// Check if the current session is an admin (required for posting messages)
$isAdmin = isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true;

header('Content-Type: application/json');

// Connect to the database
$mysqli = new mysqli('localhost', 'root', '', 'patchup');
if ($mysqli->connect_errno) {
    http_response_code(500);
    echo json_encode(['error' => 'DB connect failed']);
    exit;
}
$mysqli->set_charset('utf8mb4');

// Safely convert value to integer
function clean_int($v)
{
    return (int)($v ?? 0);
}

// Respond with JSON and exit
function respond($data)
{
    echo json_encode($data);
    exit;
}

// Check if a report exists by ReportID
function report_exists($mysqli, $rid)
{
    $stmt = $mysqli->prepare("SELECT 1 FROM potholereport WHERE ReportID=?");
    $stmt->bind_param('i', $rid);
    $stmt->execute();
    $stmt->store_result();
    $ok = $stmt->num_rows > 0;
    $stmt->close();
    return $ok;
}

// Handle GET requests: batch message counts for multiple reports
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['report_ids'])) {
    $raw = $_GET['report_ids'];
    $parts = array_filter(array_map('trim', explode(',', $raw)));
    $ids = [];
    foreach ($parts as $p) {
        if (ctype_digit($p)) {
            $ids[] = (int)$p;
        }
        if (count($ids) >= 500) break; // safety cap
    }
    if (!$ids) {
        respond([]);
    }
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $types = str_repeat('i', count($ids));
    $sql = "SELECT ReportID, COUNT(*) AS MessageCount
            FROM chat_messages
            WHERE ReportID IN ($placeholders) AND IsDeleted=0
            GROUP BY ReportID";
    $stmt = $mysqli->prepare($sql);
    $stmt->bind_param($types, ...$ids);
    $stmt->execute();
    $res = $stmt->get_result();
    $rows = [];
    while ($row = $res->fetch_assoc()) {
        $row['MessageCount'] = (int)$row['MessageCount'];
        $rows[] = $row;
    }
    $stmt->close();
    respond($rows);
}

// Handle GET requests: fetch all chat messages for a report
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $report_id = clean_int($_GET['report_id'] ?? null);
    if (!$report_id || !report_exists($mysqli, $report_id)) {
        respond([]);
    }
    $sql = "
        SELECT c.MessageID,
               c.ReportID,
               c.MessageText,
               DATE_FORMAT(c.CreatedAt,'%Y-%m-%d %H:%i:%s') AS CreatedAt,
               c.IsAdmin,
               c.UserID,
               u.Name AS SenderName,
               pr.UserID AS ReportOwnerID,
               c.IsDeleted,
               c.IsEdited,
               DATE_FORMAT(c.EditedAt,'%Y-%m-%d %H:%i:%s') AS EditedAt
        FROM chat_messages c
        LEFT JOIN user u ON u.UserID = c.UserID
        LEFT JOIN potholereport pr ON pr.ReportID = c.ReportID
        WHERE c.ReportID=?
        ORDER BY c.MessageID ASC";
    $stmt = $mysqli->prepare($sql);
    $stmt->bind_param('i', $report_id);
    $stmt->execute();
    $res = $stmt->get_result();
    $rows = [];
    while ($row = $res->fetch_assoc()) {
        if ($row['IsDeleted']) {
            $row['MessageText'] = null;
            $row['Deleted'] = true;
        } else {
            $row['Deleted'] = false;
        }
        // IsEdited is already in the row
        $rows[] = $row;
    }
    $stmt->close();
    respond($rows);
}

// Handle POST requests: admin posts a new chat message to a report
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$isAdmin) {
        http_response_code(403);
        respond(['success' => false, 'error' => 'Unauthorized']);
    }
    $report_id = clean_int($_POST['report_id'] ?? null);
    $message = trim($_POST['message'] ?? '');
    if (!$report_id || $message === '') {
        respond(['success' => false, 'error' => 'Invalid input']);
    }
    if (!report_exists($mysqli, $report_id)) {
        respond(['success' => false, 'error' => 'Report not found']);
    }

    // Map admin to a user account (create shadow user if needed)
    $adminName  = $_SESSION['admin_name']  ?? 'Admin';
    $adminEmail = $_SESSION['admin_email'] ?? null;

    $userId = null;
    if ($adminEmail) {
        $stmt = $mysqli->prepare("SELECT UserID FROM user WHERE Email=?");
        $stmt->bind_param('s', $adminEmail);
        $stmt->execute();
        $stmt->bind_result($uid);
        if ($stmt->fetch()) {
            $userId = $uid;
        }
        $stmt->close();
    }

    if (!$userId) {
        // Create a shadow user for the admin if not found
        $shadowEmail = $adminEmail ?: ('admin+' . uniqid() . '@local');
        $pwd = password_hash(bin2hex(random_bytes(8)), PASSWORD_BCRYPT);
        $stmt = $mysqli->prepare("INSERT INTO user(Name,Email,PasswordHash) VALUES(?,?,?)");
        $stmt->bind_param('sss', $adminName, $shadowEmail, $pwd);
        if ($stmt->execute()) {
            $userId = $stmt->insert_id;
        }
        $stmt->close();
        if (!$userId) {
            respond(['success' => false, 'error' => 'Shadow user create failed']);
        }
    }

    // Insert the new chat message
    $stmt = $mysqli->prepare("INSERT INTO chat_messages(ReportID,UserID,MessageText,IsAdmin) VALUES (?,?,?,1)");
    $stmt->bind_param('iis', $report_id, $userId, $message);
    if (!$stmt->execute()) {
        $err = $stmt->error;
        $stmt->close();
        respond(['success' => false, 'error' => 'Insert failed: ' . $err]);
    }
    $id = $stmt->insert_id;
    $stmt->close();

    respond(['success' => true, 'message_id' => $id]);
}

// Handle unsupported HTTP methods
http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
