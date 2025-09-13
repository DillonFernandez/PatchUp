<?php

/**
 * Admin Login Page
 * Provides a login form for PatchUp admins to access the dashboard.
 */

// Session start and redirect if already logged in
session_start();
if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header("Location: index.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Meta, styles, and external scripts -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PatchUp | Admin Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://unpkg.com/@fortawesome/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>

<body class="bg-gray-100">
    <!-- Login page container -->
    <div class="min-h-screen flex items-center justify-center px-4 py-6 sm:py-8">
        <div class="w-full max-w-sm sm:max-w-md lg:max-w-lg">
            <!-- Login card -->
            <div class="login-card bg-white rounded-2xl login-shadow overflow-hidden">
                <!-- Header with logo -->
                <div class="bg-gradient-to-br from-gray-50 to-white px-6 sm:px-8 pt-8 pb-6 text-center border-b border-gray-100">
                    <div class="inline-flex items-center justify-center w-20 h-20 sm:w-24 sm:h-24 bg-white rounded-full shadow-lg mb-4">
                        <img src="images/Logo 1.webp" alt="PatchUp Logo"
                            class="w-16 h-16 sm:w-20 sm:h-20 object-contain rounded-full">
                    </div>
                    <h1 class="text-xl sm:text-2xl font-bold text-gray-800 mb-2">Admin Login</h1>
                    <p class="text-gray-500 text-sm">Access your PatchUp dashboard</p>
                </div>

                <!-- Login form -->
                <div class="px-6 sm:px-8 py-6 sm:py-8">
                    <form id="loginForm" class="space-y-5">
                        <!-- Name input -->
                        <div class="space-y-2">
                            <label for="name" class="block text-sm font-semibold text-gray-700">Full Name</label>
                            <div class="relative group">
                                <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                    <i class="fas fa-user text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                                </div>
                                <input type="text" id="name" name="name" required
                                    class="login-input w-full pl-10 pr-4 py-3 rounded-xl border border-gray-200 bg-gray-50 
                                           focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-50 
                                           transition-all duration-200 outline-none text-gray-800 placeholder-gray-400
                                           hover:border-gray-300"
                                    placeholder="Enter your full name">
                            </div>
                        </div>

                        <!-- Email input -->
                        <div class="space-y-2">
                            <label for="email" class="block text-sm font-semibold text-gray-700">Email Address</label>
                            <div class="relative group">
                                <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                    <i class="fas fa-envelope text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                                </div>
                                <input type="email" id="email" name="email" required
                                    class="login-input w-full pl-10 pr-4 py-3 rounded-xl border border-gray-200 bg-gray-50 
                                           focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-50 
                                           transition-all duration-200 outline-none text-gray-800 placeholder-gray-400
                                           hover:border-gray-300"
                                    placeholder="Enter your email address">
                            </div>
                        </div>

                        <!-- Password input -->
                        <div class="space-y-2">
                            <label for="password" class="block text-sm font-semibold text-gray-700">Password</label>
                            <div class="relative group">
                                <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                    <i class="fas fa-lock text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                                </div>
                                <input type="password" id="password" name="password" required
                                    class="login-input w-full pl-10 pr-4 py-3 rounded-xl border border-gray-200 bg-gray-50 
                                           focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-50 
                                           transition-all duration-200 outline-none text-gray-800 placeholder-gray-400
                                           hover:border-gray-300"
                                    placeholder="Enter your password">
                            </div>
                        </div>

                        <!-- Submit button -->
                        <div class="pt-2">
                            <button type="submit"
                                class="login-btn w-full py-3 px-4 rounded-xl bg-[#04274B] hover:bg-[#063366] 
                                       text-white font-semibold text-base shadow-lg hover:shadow-xl 
                                       transform hover:-translate-y-0.5 transition-all duration-200 
                                       focus:outline-none focus:ring-4 focus:ring-blue-100">
                                <i class="fas fa-sign-in-alt mr-2"></i>
                                Sign In to Dashboard
                            </button>
                        </div>

                        <!-- Login message display -->
                        <div id="loginMessage" class="text-center text-red-500 text-sm font-medium min-h-[20px]"></div>
                    </form>
                </div>
            </div>

            <!-- Footer -->
            <div class="text-center mt-6 sm:mt-8">
                <p class="text-gray-400 text-xs sm:text-sm">
                    &copy; <?php echo date('Y'); ?> PatchUp. All rights reserved.
                </p>
            </div>
        </div>
    </div>

    <!-- Custom JavaScript -->
    <script src="javascript/script.js"></script>
</body>

</html>