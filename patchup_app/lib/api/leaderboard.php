<?php

/**
 * API endpoint to fetch leaderboard data.
 * Returns top users with points and badges, and the requesting user's position.
 */

header('Content-Type: application/json');
require_once('../database/db_connection.php');

// Parse optional email parameter from POST or GET
$email = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['email'])) {
        $email = $input['email'];
    }
} elseif (isset($_GET['email'])) {
    $email = $_GET['email'];
}

// Fetch all users with points > 0, ordered by points descending
$sql = "SELECT UserID, Name, Points FROM user WHERE Points > 0 ORDER BY Points DESC";
$result = $conn->query($sql);

$leaderboard = [];
if ($result && $result->num_rows > 0) {
    $rowIndex = 0;
    while ($row = $result->fetch_assoc()) {
        $user_id = $row['UserID'];
        // Limit: top 3 get 3 badges, rest get 6
        $badge_limit = ($rowIndex < 3) ? 3 : 6;
        $badge_sql = "
            SELECT b.BadgeName, b.Description, b.ImagePath, ub.EarnedAt
            FROM userbadge ub
            JOIN badge b ON ub.BadgeID = b.BadgeID
            WHERE ub.UserID = ?
            ORDER BY ub.EarnedAt DESC
            LIMIT $badge_limit
        ";
        $badge_stmt = $conn->prepare($badge_sql);
        $badge_stmt->bind_param("i", $user_id);
        $badge_stmt->execute();
        $badge_result = $badge_stmt->get_result();
        $badges = [];
        while ($badge_row = $badge_result->fetch_assoc()) {
            $badges[] = [
                'BadgeName' => $badge_row['BadgeName'],
                'Description' => $badge_row['Description'],
                'ImagePath' => $badge_row['ImagePath'],
                'EarnedAt' => $badge_row['EarnedAt']
            ];
        }
        $badge_stmt->close();

        $leaderboard[] = [
            'user_id' => $user_id,
            'name' => $row['Name'],
            'points' => (int)$row['Points'],
            'badges' => $badges
        ];
        $rowIndex++;
    }
}

// Initialize user position and info
$user_position = null;
$user_points = null;
$user_name = null;

if (!empty($email)) {
    // Find user by email and fetch points and name
    $stmt = $conn->prepare("SELECT Name, Points FROM user WHERE Email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();
    if ($stmt->num_rows > 0) {
        $stmt->bind_result($name, $points);
        $stmt->fetch();
        $user_name = $name;
        $user_points = (int)$points;

        // Find user's rank based on points
        $rank_sql = "SELECT COUNT(*) + 1 AS position FROM user WHERE Points > ?";
        $rank_stmt = $conn->prepare($rank_sql);
        $rank_stmt->bind_param("i", $user_points);
        $rank_stmt->execute();
        $rank_stmt->bind_result($position);
        $rank_stmt->fetch();
        $user_position = $position;
        $rank_stmt->close();
    }
    $stmt->close();
}

// Output leaderboard and user info as JSON
echo json_encode([
    'leaderboard' => $leaderboard,
    'user_position' => $user_position,
    'user_points' => $user_points,
    'user_name' => $user_name
]);
$conn->close();
