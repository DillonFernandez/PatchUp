<?php

/**
 * API endpoint to fetch the points for a user by email.
 * Returns 0 points if email is missing or user not found.
 */

header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse and validate input
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';

if (!$email) {
    echo json_encode(["points" => 0]);
    exit;
}

// Fetch user points by email
$stmt = $conn->prepare("SELECT Points FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($points);

// Output points if user found, otherwise return 0
if ($stmt->fetch()) {
    echo json_encode(["points" => intval($points)]);
} else {
    echo json_encode(["points" => 0]);
}

// Close resources
$stmt->close();
$conn->close();
