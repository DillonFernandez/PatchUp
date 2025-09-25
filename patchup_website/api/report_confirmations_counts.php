<?php
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden']);
    exit;
}
header('Content-Type: application/json');
require_once("../database/db_connection.php");

$idsParam = isset($_GET['report_ids']) ? $_GET['report_ids'] : '';
if ($idsParam === '') {
    echo json_encode(['counts' => []]);
    exit;
}

$ids = array_filter(array_map('intval', explode(',', $idsParam)), fn($v) => $v > 0);
$ids = array_values(array_unique($ids));
if (!count($ids)) {
    echo json_encode(['counts' => []]);
    exit;
}

$in = implode(',', $ids); // safe: ints only
$sql = "SELECT ReportID, COUNT(*) AS ConfirmationsCount 
        FROM pothole_validation 
        WHERE ReportID IN ($in)
        GROUP BY ReportID";
$res = $conn->query($sql);

$data = [];
if ($res) {
    while ($row = $res->fetch_assoc()) {
        $data[$row['ReportID']] = (int)$row['ConfirmationsCount'];
    }
}
echo json_encode(['counts' => $data]);
