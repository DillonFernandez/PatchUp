<?php

/**
 * API endpoint to fetch all badges earned by a user.
 * Returns badge details and earned timestamps.
 */

require_once("../database/db_connection.php");

header('Content-Type: application/json');

// Parse and validate user ID from GET parameters
$userId = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
if ($userId <= 0) {
    echo json_encode(['error' => 'Invalid user ID']);
    exit;
}

// Fetch badges earned by the user
$sql = "SELECT b.BadgeID, b.BadgeName, b.Description, b.BadgeType, b.ImagePath, ub.EarnedAt
        FROM userbadge ub
        JOIN badge b ON ub.BadgeID = b.BadgeID
        WHERE ub.UserID = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();

// Collect badges into array
$badges = [];
while ($row = $result->fetch_assoc()) {
    $badges[] = $row;
}

// Output badges as JSON
echo json_encode(['badges' => $badges]);
$stmt->close();
$conn->close();
