<?php

/**
 * Database Connection
 * Establishes a connection to the PatchUp MySQL database.
 */

// Database connection configuration
$host = "localhost";
$user = "root";
$password = "";
$dbname = "patchup";

// Create database connection
$conn = new mysqli($host, $user, $password, $dbname);

// Check for connection errors
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
