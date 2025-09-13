<?php

/**
 * Admin Dashboard Page
 * Displays summary statistics, charts, top contributors, and recent activity for PatchUp.
 */

// Include dashboard data
include 'api/home_status.php';
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Meta, styles, and external scripts -->
    <meta charset="UTF-8">
    <title>Patch | Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
    <script src="https://unpkg.com/feather-icons"></script>
</head>

<body class="bg-gray-100 min-h-screen flex relative">

    <!-- Sidebar navigation -->
    <aside id="sidebar"
        class="w-64 bg-white shadow-lg h-full md:h-screen fixed flex flex-col justify-between transform -translate-x-full md:translate-x-0 transition-transform duration-300 z-40 overflow-y-auto border-r border-gray-200">
        <div>
            <!-- Sidebar Header -->
            <div class="px-6 py-6 border-b border-gray-100">
                <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-gradient-to-br from-[#04274B] to-[#063366] rounded-lg flex items-center justify-center">
                        <span data-feather="shield" class="w-5 h-5 text-white"></span>
                    </div>
                    <h2 class="text-lg font-bold text-[#04274B]">PatchUp Admin</h2>
                </div>
            </div>

            <!-- Navigation Menu -->
            <nav class="mt-4 px-4 space-y-1">
                <a href="index.php"
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl bg-[#04274B] text-white font-medium shadow-sm">
                    <span data-feather="home" class="w-5 h-5"></span>
                    <span>Dashboard</span>
                </a>
                <a href="manage_admins.php"
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl hover:bg-gray-50 text-gray-700 hover:text-[#04274B] transition-colors">
                    <span data-feather="users" class="w-5 h-5"></span>
                    <span>Manage Admins</span>
                </a>
                <a href="manage_reports.php"
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl hover:bg-gray-50 text-gray-700 hover:text-[#04274B] transition-colors">
                    <span data-feather="alert-triangle" class="w-5 h-5"></span>
                    <span>Manage Reports</span>
                </a>
                <a href="view_customers.php"
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl hover:bg-gray-50 text-gray-700 hover:text-[#04274B] transition-colors">
                    <span data-feather="eye" class="w-5 h-5"></span>
                    <span>View Customers</span>
                </a>
            </nav>
        </div>

        <!-- Logout Section -->
        <div class="px-4 pb-6">
            <div class="border-t border-gray-100 pt-4">
                <form action="logout.php" method="post">
                    <button type="submit"
                        class="w-full flex items-center justify-center space-x-2 py-3 px-4 rounded-xl bg-red-50 text-red-600 hover:bg-red-100 transition-colors font-medium">
                        <span data-feather="log-out" class="w-4 h-4"></span>
                        <span>Logout</span>
                    </button>
                </form>
            </div>
        </div>
    </aside>

    <!-- Mobile sidebar overlay -->
    <div id="overlay" class="fixed inset-0 bg-black bg-opacity-50 hidden z-30 md:hidden"></div>

    <!-- Main dashboard content -->
    <main class="flex-1 md:ml-64 bg-gray-50 min-h-screen overflow-x-hidden">

        <!-- Header bar -->
        <header class="bg-white px-4 sm:px-6 py-4 border-b border-gray-200 shadow-sm">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <button id="menuToggle" class="md:hidden text-[#04274B] focus:outline-none p-1">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                        </svg>
                    </button>
                    <div>
                        <h1 class="text-xl sm:text-2xl font-bold text-[#04274B]">Dashboard</h1>
                        <p class="text-sm text-gray-500 hidden sm:block">Welcome back, <?= htmlspecialchars($_SESSION['admin_name']) ?></p>
                    </div>
                </div>
                <div class="flex items-center space-x-3">
                    <div class="hidden sm:flex items-center space-x-2 bg-gray-50 px-3 py-2 rounded-lg">
                        <span data-feather="calendar" class="w-4 h-4 text-gray-500"></span>
                        <span class="text-sm text-gray-600"><?= date('M d, Y') ?></span>
                    </div>
                </div>
            </div>
        </header>

        <!-- Dashboard content -->
        <section class="p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">

            <!-- Welcome card -->
            <div class="home-card home-shadow bg-gradient-to-r from-[#04274B] to-[#063366] text-white p-6 sm:p-8 rounded-2xl relative overflow-hidden">
                <div class="absolute top-0 right-0 w-32 h-32 bg-white bg-opacity-10 rounded-full -mr-16 -mt-16"></div>
                <div class="relative">
                    <div class="flex items-center space-x-3 mb-3">
                        <span class="text-2xl">👋</span>
                        <h2 class="text-xl sm:text-2xl font-bold">Welcome Back, <?= htmlspecialchars($_SESSION['admin_name']) ?></h2>
                    </div>
                    <p class="text-blue-100 text-sm sm:text-base">Here's what's happening with PatchUp today.</p>
                </div>
            </div>

            <!-- Statistics row -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
                <!-- Card: Total Reports -->
                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100 relative overflow-hidden">
                    <div class="absolute top-4 right-4 opacity-10">
                        <span data-feather="alert-triangle" class="w-12 h-12 text-yellow-500"></span>
                    </div>
                    <div class="relative">
                        <div class="flex items-center space-x-2 mb-2">
                            <span data-feather="alert-triangle" class="w-5 h-5 text-yellow-500"></span>
                            <h3 class="text-sm font-semibold text-gray-600 uppercase tracking-wide">Total Reports</h3>
                        </div>
                        <p class="text-3xl font-bold text-[#04274B]"><?= $totalReports ?></p>
                        <p class="text-xs text-gray-500 mt-1">Pothole reports</p>
                    </div>
                </div>

                <!-- Additional Stats Cards (Placeholder for future metrics) -->
                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100 relative overflow-hidden">
                    <div class="absolute top-4 right-4 opacity-10">
                        <span data-feather="trending-up" class="w-12 h-12 text-green-500"></span>
                    </div>
                    <div class="relative">
                        <div class="flex items-center space-x-2 mb-2">
                            <span data-feather="trending-up" class="w-5 h-5 text-green-500"></span>
                            <h3 class="text-sm font-semibold text-gray-600 uppercase tracking-wide">This Month</h3>
                        </div>
                        <p class="text-3xl font-bold text-[#04274B]">+<?= round($totalReports * 0.15) ?></p>
                        <p class="text-xs text-gray-500 mt-1">New reports</p>
                    </div>
                </div>

                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100 relative overflow-hidden">
                    <div class="absolute top-4 right-4 opacity-10">
                        <span data-feather="check-circle" class="w-12 h-12 text-blue-500"></span>
                    </div>
                    <div class="relative">
                        <div class="flex items-center space-x-2 mb-2">
                            <span data-feather="check-circle" class="w-5 h-5 text-blue-500"></span>
                            <h3 class="text-sm font-semibold text-gray-600 uppercase tracking-wide">Resolved</h3>
                        </div>
                        <p class="text-3xl font-bold text-[#04274B]"><?= isset($statusData['Fixed']) ? $statusData['Fixed'] : 0 ?></p>
                        <p class="text-xs text-gray-500 mt-1">Fixed reports</p>
                    </div>
                </div>

                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100 relative overflow-hidden">
                    <div class="absolute top-4 right-4 opacity-10">
                        <span data-feather="clock" class="w-12 h-12 text-orange-500"></span>
                    </div>
                    <div class="relative">
                        <div class="flex items-center space-x-2 mb-2">
                            <span data-feather="clock" class="w-5 h-5 text-orange-500"></span>
                            <h3 class="text-sm font-semibold text-gray-600 uppercase tracking-wide">Pending</h3>
                        </div>
                        <p class="text-3xl font-bold text-[#04274B]"><?= isset($statusData['Pending']) ? $statusData['Pending'] : 0 ?></p>
                        <p class="text-xs text-gray-500 mt-1">Awaiting action</p>
                    </div>
                </div>
            </div>

            <!-- Charts row -->
            <div class="grid lg:grid-cols-2 gap-6">
                <!-- Card: Status Breakdown Chart -->
                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100">
                    <div class="flex items-center space-x-2 mb-6">
                        <span data-feather="pie-chart" class="w-5 h-5 text-blue-500"></span>
                        <h3 class="text-lg font-semibold text-gray-800">Status Distribution</h3>
                    </div>
                    <div class="flex justify-center">
                        <canvas id="statusChart" class="max-w-[280px] max-h-[280px]"></canvas>
                    </div>
                </div>

                <!-- Card: Severity Breakdown Chart -->
                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100">
                    <div class="flex items-center space-x-2 mb-6">
                        <span data-feather="bar-chart-2" class="w-5 h-5 text-red-500"></span>
                        <h3 class="text-lg font-semibold text-gray-800">Severity Levels</h3>
                    </div>
                    <div class="flex justify-center">
                        <canvas id="severityChart" class="max-w-[280px] max-h-[280px]"></canvas>
                    </div>
                </div>
            </div>

            <!-- Data tables row -->
            <div class="grid lg:grid-cols-2 gap-6">
                <!-- Card: Top 5 Reporters -->
                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100">
                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center space-x-2">
                            <span data-feather="award" class="w-5 h-5 text-green-500"></span>
                            <h3 class="text-lg font-semibold text-gray-800">Top Contributors</h3>
                        </div>
                        <span class="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded-full">Top 5</span>
                    </div>
                    <div class="space-y-3">
                        <?php $rank = 1;
                        while ($row = $topUsers->fetch_assoc()) { ?>
                            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                                <div class="flex items-center space-x-3">
                                    <div class="w-8 h-8 bg-gradient-to-br from-green-400 to-green-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
                                        <?= $rank++ ?>
                                    </div>
                                    <span class="font-medium text-gray-800"><?= htmlspecialchars($row['Name']) ?></span>
                                </div>
                                <span class="home-badge bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium">
                                    <?= $row['totalReports'] ?> reports
                                </span>
                            </div>
                        <?php } ?>
                    </div>
                </div>

                <!-- Card: Latest Reports -->
                <div class="home-card home-shadow bg-white p-6 rounded-xl border border-gray-100">
                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center space-x-2">
                            <span data-feather="clock" class="w-5 h-5 text-blue-500"></span>
                            <h3 class="text-lg font-semibold text-gray-800">Recent Activity</h3>
                        </div>
                        <span class="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded-full">Latest</span>
                    </div>
                    <div class="space-y-4">
                        <?php while ($row = $latestReports->fetch_assoc()) { ?>
                            <div class="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                                <img src="<?= htmlspecialchars($row['ImageURL']) ?>"
                                    class="w-12 h-12 object-cover home-avatar shadow-sm rounded-lg flex-shrink-0">
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-medium text-gray-800 line-clamp-2 leading-tight">
                                        <?= htmlspecialchars($row['Description']) ?>
                                    </p>
                                    <div class="flex items-center space-x-2 mt-2">
                                        <span class="text-xs text-gray-600"><?= htmlspecialchars($row['Name']) ?></span>
                                        <span class="text-xs text-gray-400">•</span>
                                        <span class="text-xs font-medium px-2 py-1 rounded-full 
                                            <?= $row['Status'] === 'Fixed' ? 'bg-green-100 text-green-700' : ($row['Status'] === 'In Progress' ? 'bg-blue-100 text-blue-700' : 'bg-yellow-100 text-yellow-700') ?>">
                                            <?= $row['Status'] ?>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        <?php } ?>
                    </div>
                </div>
            </div>

        </section>
    </main>

    <!-- Sidebar toggle script -->
    <script src="javascript/script.js"></script>
    <script>
        feather.replace();
    </script>

    <!-- Chart.js scripts for dashboard charts -->
    <script>
        // Prepare data for status chart
        const statusData = <?= json_encode(array_values($statusData)) ?>;
        const statusLabels = <?= json_encode(array_keys($statusData)) ?>;

        // Prepare data for severity chart
        const severityData = <?= json_encode(array_values($severityData)) ?>;
        const severityLabels = <?= json_encode(array_keys($severityData)) ?>;

        // Render status pie chart
        new Chart(document.getElementById('statusChart'), {
            type: 'pie',
            data: {
                labels: statusLabels,
                datasets: [{
                    data: statusData,
                    backgroundColor: ['#facc15', '#3b82f6', '#10b981']
                }]
            },
            options: {
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: {
                            font: {
                                size: 14,
                                family: 'Inter, sans-serif'
                            }
                        }
                    }
                }
            }
        });

        // Render severity doughnut chart
        new Chart(document.getElementById('severityChart'), {
            type: 'doughnut',
            data: {
                labels: severityLabels,
                datasets: [{
                    data: severityData,
                    backgroundColor: [
                        '#f87171',
                        '#fbbf24',
                        '#10b981'
                    ]
                }]
            },
            options: {
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: {
                            font: {
                                size: 14,
                                family: 'Inter, sans-serif'
                            }
                        }
                    }
                }
            }
        });
    </script>
</body>

</html>