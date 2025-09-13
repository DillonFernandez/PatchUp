<?php

/**
 * API endpoint to increment user points.
 * Accepts UserEmail and Points via POST and updates the user's points.
 */

require_once("../database/db_connection.php");

// Parse and validate input
$userEmail = $_POST['UserEmail'] ?? '';
$points = intval($_POST['Points'] ?? '0');

if ($userEmail !== '' && $points > 0) {
    // Resolve user by email
    $stmtUser = $conn->prepare("SELECT UserID FROM user WHERE LOWER(Email) = LOWER(?)");
    if ($stmtUser) {
        $stmtUser->bind_param("s", $userEmail);
        $stmtUser->execute();
        $stmtUser->bind_result($userId);
        if ($stmtUser->fetch()) {
            $stmtUser->close();
            // Increment user points
            $stmtPoints = $conn->prepare("UPDATE user SET Points = Points + ? WHERE UserID = ?");
            if ($stmtPoints) {
                $stmtPoints->bind_param("ii", $points, $userId);
                $stmtPoints->execute();
                $stmtPoints->close();
            }
        } else {
            $stmtUser->close();
        }
    }
}

// Close the database connection
$conn->close();
