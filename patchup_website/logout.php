<?php

/**
 * Admin Logout
 * Terminates the admin session and redirects to the login page.
 */

// Terminate session
session_start();
$_SESSION = [];
session_unset();
session_destroy();

// Redirect to login page
header("Location: login.php");
exit;
