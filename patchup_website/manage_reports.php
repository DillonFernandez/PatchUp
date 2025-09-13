<?php

/**
 * Manage Reports Page
 * Allows admins to filter, view, update, and chat about pothole reports with heatmap visualization.
 */

// Session start and admin authentication
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Meta, styles, and external scripts -->
    <meta charset="UTF-8">
    <title>Patch | Manage Reports</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
    <script src="https://unpkg.com/leaflet.heat/dist/leaflet-heat.js"></script>
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
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl hover:bg-gray-50 text-gray-700 hover:text-[#04274B] transition-colors">
                    <span data-feather="home" class="w-5 h-5"></span>
                    <span>Dashboard</span>
                </a>
                <a href="manage_admins.php"
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl hover:bg-gray-50 text-gray-700 hover:text-[#04274B] transition-colors">
                    <span data-feather="users" class="w-5 h-5"></span>
                    <span>Manage Admins</span>
                </a>
                <a href="manage_reports.php"
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl bg-[#04274B] text-white font-medium shadow-sm">
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

    <!-- Section: Mobile Sidebar Overlay -->
    <div id="overlay" class="fixed inset-0 bg-black bg-opacity-50 hidden z-30 md:hidden"></div>

    <!-- Section: Main Content -->
    <main class="flex-1 md:ml-64 bg-gray-50 min-h-screen overflow-x-hidden">

        <!-- Section: Header Bar -->
        <header class="bg-white px-4 sm:px-6 py-4 border-b border-gray-200 shadow-sm">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <button id="menuToggle" class="md:hidden text-[#04274B] focus:outline-none p-1">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                        </svg>
                    </button>
                    <div>
                        <h1 class="text-xl sm:text-2xl font-bold text-[#04274B]">Manage Reports</h1>
                        <nav class="flex text-sm text-gray-500 space-x-2" aria-label="Breadcrumb">
                            <a href="index.php" class="hover:text-[#04274B]">Dashboard</a>
                            <span>/</span>
                            <span class="text-gray-800 font-medium">Manage Reports</span>
                        </nav>
                    </div>
                </div>
                <div class="flex items-center space-x-3">
                    <div class="hidden sm:flex items-center space-x-2 bg-gray-50 px-3 py-2 rounded-lg">
                        <span data-feather="map" class="w-4 h-4 text-gray-500"></span>
                        <span class="text-sm text-gray-600">Live Map View</span>
                    </div>
                </div>
            </div>
        </header>

        <!-- Section: Reports Management Content -->
        <section class="p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">

            <!-- Section: Page Header -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex items-center space-x-3 mb-2">
                    <span data-feather="clipboard" class="w-6 h-6 text-[#04274B]"></span>
                    <h2 class="text-xl font-semibold text-gray-800">Report Management</h2>
                </div>
                <p class="text-gray-600">Monitor, filter, and manage pothole reports with interactive heatmap visualization.</p>
            </div>

            <!-- Section: Filter Controls -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex items-center space-x-2 mb-4">
                    <span data-feather="filter" class="w-5 h-5 text-gray-500"></span>
                    <h3 class="text-lg font-semibold text-gray-800">Filter Reports</h3>
                </div>
                <form id="filterForm" class="space-y-4">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div class="space-y-2">
                            <label class="block text-sm font-semibold text-gray-700">Status</label>
                            <div class="relative">
                                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                    <span data-feather="activity" class="w-4 h-4"></span>
                                </span>
                                <select name="status" id="statusFilter" class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white">
                                    <option value="All">All Status</option>
                                    <option value="Reported">Reported</option>
                                    <option value="In Progress">In Progress</option>
                                    <option value="Resolved">Resolved</option>
                                </select>
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label class="block text-sm font-semibold text-gray-700">Severity</label>
                            <div class="relative">
                                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                    <span data-feather="alert-circle" class="w-4 h-4"></span>
                                </span>
                                <select name="severity" id="severityFilter" class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white">
                                    <option value="All">All Severity</option>
                                    <option value="Small">Small</option>
                                    <option value="Moderate">Moderate</option>
                                    <option value="Critical">Critical</option>
                                </select>
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label class="block text-sm font-semibold text-gray-700">Province</label>
                            <div class="relative">
                                <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                    <span data-feather="map-pin" class="w-4 h-4"></span>
                                </span>
                                <select name="province" id="provinceFilter" class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white">
                                    <option value="All">All Provinces</option>
                                    <option value="Central Province">Central Province</option>
                                    <option value="Eastern Province">Eastern Province</option>
                                    <option value="North Central Province">North Central Province</option>
                                    <option value="Northern Province">Northern Province</option>
                                    <option value="North Western Province">North Western Province</option>
                                    <option value="Sabaragamuwa Province">Sabaragamuwa Province</option>
                                    <option value="Southern Province">Southern Province</option>
                                    <option value="Uva Province">Uva Province</option>
                                    <option value="Western Province">Western Province</option>
                                </select>
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label class="block text-sm font-semibold text-gray-700">Actions</label>
                            <div class="flex space-x-2">
                                <button type="submit"
                                    class="flex-1 flex items-center justify-center space-x-2 py-3 px-4 rounded-xl bg-[#04274B] text-white font-semibold hover:bg-[#063366] transition-colors shadow-sm">
                                    <span data-feather="search" class="w-4 h-4"></span>
                                    <span>Filter</span>
                                </button>
                                <button type="button" id="resetBtn"
                                    class="flex items-center justify-center px-4 py-3 rounded-xl border border-gray-300 text-gray-700 hover:bg-gray-50 transition-colors">
                                    <span data-feather="refresh-cw" class="w-4 h-4"></span>
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Section: Heatmap Visualization -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center space-x-2">
                        <span data-feather="map" class="w-5 h-5 text-gray-500"></span>
                        <h3 class="text-lg font-semibold text-gray-800">Live Heatmap</h3>
                    </div>
                    <div class="flex items-center space-x-4 text-sm">
                        <div class="flex items-center space-x-2">
                            <div class="w-3 h-3 bg-red-500 rounded-full"></div>
                            <span class="text-gray-600">Critical</span>
                        </div>
                        <div class="flex items-center space-x-2">
                            <div class="w-3 h-3 bg-yellow-500 rounded-full"></div>
                            <span class="text-gray-600">Moderate</span>
                        </div>
                        <div class="flex items-center space-x-2">
                            <div class="w-3 h-3 bg-green-500 rounded-full"></div>
                            <span class="text-gray-600">Small</span>
                        </div>
                    </div>
                </div>
                <div id="heatmap" class="w-full h-96 rounded-xl overflow-hidden border border-gray-200"></div>
            </div>

            <!-- Section: Reports Grid -->
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <div class="p-6 border-b border-gray-200">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-2">
                            <span data-feather="grid" class="w-5 h-5 text-gray-500"></span>
                            <h3 class="text-lg font-semibold text-gray-800">Reports List</h3>
                        </div>
                        <div class="text-sm text-gray-500">
                            <span data-feather="info" class="w-4 h-4 inline mr-1"></span>
                            Click to manage reports
                        </div>
                    </div>
                </div>
                <div class="p-6">
                    <div id="reportsGrid" class="grid gap-6 grid-cols-1 lg:grid-cols-2 xl:grid-cols-3">
                        <!-- Reports will be loaded here via JS -->
                    </div>
                </div>
            </div>

        </section>
    </main>

    <!-- Chat Modal -->
    <div id="chatModal" class="fixed inset-0 hidden items-center justify-center p-4" style="z-index:9999;">
        <div class="absolute inset-0 bg-black/50" id="chatBackdrop"></div>
        <div class="relative bg-white w-full max-w-md mx-auto rounded-2xl shadow-2xl flex flex-col max-h-[85vh] border border-gray-200">
            <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-gradient-to-br from-[#04274B] to-[#063366] rounded-lg flex items-center justify-center">
                        <span data-feather="message-circle" class="w-4 h-4 text-white"></span>
                    </div>
                    <h3 class="font-semibold text-[#04274B]" id="chatTitle">Chat</h3>
                </div>
                <button id="chatClose" class="text-gray-400 hover:text-gray-600 transition-colors">
                    <span data-feather="x" class="w-5 h-5"></span>
                </button>
            </div>
            <div id="chatMessages" class="p-4 space-y-3 overflow-y-auto flex-1 text-sm bg-gray-50">
                <!-- messages -->
            </div>
            <form id="chatForm" class="p-4 border-t border-gray-200 flex gap-3">
                <input type="text" id="chatInput"
                    class="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] transition-all"
                    placeholder="Type a message..." required />
                <button class="bg-[#04274B] text-white px-4 py-2 rounded-lg text-sm hover:bg-[#063366] transition-colors font-medium flex items-center space-x-1" type="submit">
                    <span data-feather="send" class="w-4 h-4"></span>
                    <span>Send</span>
                </button>
            </form>
        </div>
    </div>

    <script src="javascript/script.js"></script>
    <script>
        // Initialize Leaflet heatmap for reports
        let map, heatCritical, heatModerate, heatSmall;

        function initMap() {
            if (map) return;
            const sriLankaBounds = L.latLngBounds(
                [5.719, 79.521], // SW corner
                [9.850, 81.881] // NE corner
            );
            map = L.map('heatmap', {
                maxBounds: sriLankaBounds,
                maxBoundsViscosity: 1.0,
                minZoom: 7,
                maxZoom: 12,
                zoomControl: true
            }).setView([7.8731, 80.7718], 7); // Center on Sri Lanka
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(map);

            // --- Create three heat layers for severity ---
            heatCritical = L.heatLayer([], {
                radius: 25,
                blur: 18,
                maxZoom: 12,
                gradient: {
                    0.4: 'red',
                    0.7: 'red',
                    1.0: 'darkred'
                }
            }).addTo(map);
            heatModerate = L.heatLayer([], {
                radius: 25,
                blur: 18,
                maxZoom: 12,
                gradient: {
                    0.4: 'yellow',
                    0.7: 'orange',
                    1.0: 'gold'
                }
            }).addTo(map);
            heatSmall = L.heatLayer([], {
                radius: 25,
                blur: 18,
                maxZoom: 12,
                gradient: {
                    0.4: 'green',
                    0.7: 'lime',
                    1.0: 'darkgreen'
                }
            }).addTo(map);

            map.setMaxBounds(sriLankaBounds);
        }

        // Update heatmap data based on report severity
        function updateHeatmap(data) {
            if (!map) initMap();
            // Separate points by severity
            const critical = [];
            const moderate = [];
            const small = [];
            data.forEach(r => {
                if (r.Latitude && r.Longitude) {
                    const lat = parseFloat(r.Latitude);
                    const lng = parseFloat(r.Longitude);
                    if (r.SeverityLevel === 'Critical') {
                        critical.push([lat, lng, 1]);
                    } else if (r.SeverityLevel === 'Moderate') {
                        moderate.push([lat, lng, 1]);
                    } else if (r.SeverityLevel === 'Small') {
                        small.push([lat, lng, 1]);
                    }
                }
            });
            heatCritical.setLatLngs(critical);
            heatModerate.setLatLngs(moderate);
            heatSmall.setLatLngs(small);
        }

        // Fetch and render reports and heatmap based on filters
        function fetchReports() {
            const status = document.getElementById('statusFilter').value;
            const severity = document.getElementById('severityFilter').value;
            const province = document.getElementById('provinceFilter').value;
            fetch(`api/manage_reports.php?status=${encodeURIComponent(status)}&severity=${encodeURIComponent(severity)}&province=${encodeURIComponent(province)}`)
                .then(res => res.json())
                .then(data => {
                    // --- Heatmap Data ---
                    updateHeatmap(data);

                    // --- Reports Grid ---
                    const grid = document.getElementById('reportsGrid');
                    grid.innerHTML = '';
                    if (!data.length) {
                        grid.innerHTML = '<div class="col-span-full text-center text-gray-500 py-12 bg-gray-50 rounded-xl border-2 border-dashed border-gray-200"><div class="flex flex-col items-center space-y-2"><span data-feather="inbox" class="w-12 h-12 text-gray-300"></span><p class="text-lg font-medium">No reports found</p><p class="text-sm">Try adjusting your filters</p></div></div>';
                        feather.replace();
                        return;
                    }
                    data.forEach(report => {
                        const sevClass = report.SeverityLevel === 'Critical' ? 'bg-red-50 text-red-700 border-red-200' :
                            report.SeverityLevel === 'Moderate' ? 'bg-yellow-50 text-yellow-700 border-yellow-200' :
                            'bg-green-50 text-green-700 border-green-200';
                        const statusClass = report.Status === 'Resolved' ? 'bg-green-100 text-green-800' :
                            report.Status === 'In Progress' ? 'bg-blue-100 text-blue-800' :
                            'bg-gray-100 text-gray-800';
                        const img = report.ImageURL ?
                            `<img src="${report.ImageURL}" alt="Pothole Image" class="object-cover w-full h-32 rounded-lg">` :
                            `<div class="w-full h-32 bg-gray-100 rounded-lg flex items-center justify-center text-gray-400"><span data-feather="image" class="w-8 h-8"></span></div>`;
                        grid.innerHTML += `
<div class="bg-white border border-gray-200 rounded-xl p-5 hover:shadow-md transition-shadow">
  <div class="flex items-start justify-between mb-4">
    <div class="flex items-center space-x-2">
      <span class="text-xs text-gray-500 font-mono bg-gray-100 px-2 py-1 rounded">#${report.ReportID}</span>
      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${sevClass}">
        ${report.SeverityLevel}
      </span>
    </div>
    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusClass}">
      ${report.Status}
    </span>
  </div>
  
  ${img}
  
  <div class="mt-4 space-y-3">
    <div class="flex items-center space-x-2">
      <span data-feather="user" class="w-4 h-4 text-gray-400"></span>
      <span class="text-sm font-medium text-gray-800">${report.ReporterName}</span>
    </div>
    
    <div class="flex items-start space-x-2">
      <span data-feather="file-text" class="w-4 h-4 text-gray-400 mt-0.5"></span>
      <p class="text-sm text-gray-600 line-clamp-2">${report.Description}</p>
    </div>
    
    <div class="flex items-center space-x-2">
      <span data-feather="map-pin" class="w-4 h-4 text-gray-400"></span>
      <span class="text-sm text-gray-600">${report.Province}</span>
    </div>
    
    <div class="flex items-center space-x-2">
      <span data-feather="clock" class="w-4 h-4 text-gray-400"></span>
      <span class="text-xs text-gray-500">${report.Timestamp}</span>
    </div>
  </div>
  
  <form class="statusForm mt-4 p-3 bg-gray-50 rounded-lg" data-id="${report.ReportID}">
    <div class="flex space-x-2">
      <select name="new_status" class="flex-1 text-sm border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] outline-none">
        <option value="Reported" ${report.Status === 'Reported' ? 'selected' : ''}>Reported</option>
        <option value="In Progress" ${report.Status === 'In Progress' ? 'selected' : ''}>In Progress</option>
        <option value="Resolved" ${report.Status === 'Resolved' ? 'selected' : ''}>Resolved</option>
      </select>
      <button type="submit" class="px-4 py-2 bg-[#04274B] text-white rounded-lg text-sm hover:bg-[#063366] transition-colors font-medium">
        Update
      </button>
    </div>
  </form>
  
  <div class="mt-4 flex items-center justify-between pt-3 border-t border-gray-100">
    <a href="https://www.google.com/maps?q=${report.Latitude},${report.Longitude}" target="_blank"
       class="inline-flex items-center space-x-1 text-blue-600 text-sm hover:text-blue-800 transition-colors">
      <span data-feather="external-link" class="w-4 h-4"></span>
      <span>View on Map</span>
    </a>
    <button type="button"
       class="chatBtn relative inline-flex items-center space-x-1 text-sm px-3 py-1.5 bg-[#04274B] text-white rounded-lg hover:bg-[#063366] transition-colors"
       data-report="${report.ReportID}"
       data-report-label="#${report.ReportID} (${report.SeverityLevel})">
      <span data-feather="message-circle" class="w-4 h-4"></span>
      <span>Chat</span>
      <span class="chatCount hidden absolute -top-1 -right-1 bg-red-600 text-white text-[10px] leading-none px-1.5 py-0.5 rounded-full font-semibold"></span>
    </button>
  </div>
</div>
`;
                    });
                    // Re-initialize feather icons for new content
                    feather.replace();

                    // Attach status update handlers
                    document.querySelectorAll('.statusForm').forEach(form => {
                        form.onsubmit = function(e) {
                            e.preventDefault();
                            const report_id = form.getAttribute('data-id');
                            const new_status = form.querySelector('select').value;
                            fetch('api/manage_reports.php', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded'
                                },
                                body: `report_id=${encodeURIComponent(report_id)}&new_status=${encodeURIComponent(new_status)}`
                            }).then(() => fetchReports());
                        };
                    });

                    // Attach chat handlers
                    document.querySelectorAll('.chatBtn').forEach(btn => {
                        btn.onclick = () => {
                            openChat(btn.getAttribute('data-report'), btn.getAttribute('data-report-label'));
                        };
                    });

                    // NEW: load message counts for all reports
                    updateChatCounts(data);
                });
        }

        // NEW: Batch fetch message counts for displayed reports
        function updateChatCounts(reports) {
            const ids = reports.map(r => r.ReportID).filter(Boolean);
            if (!ids.length) return;
            fetch('api/chat_messages.php?report_ids=' + ids.join(','))
                .then(r => r.json())
                .then(rows => {
                    rows.forEach(c => {
                        const btn = document.querySelector(`.chatBtn[data-report="${c.ReportID}"]`);
                        if (!btn) return;
                        const badge = btn.querySelector('.chatCount');
                        if (!badge) return;
                        if (c.MessageCount > 0) {
                            badge.textContent = c.MessageCount > 99 ? '99+' : c.MessageCount;
                            badge.classList.remove('hidden');
                        } else {
                            badge.classList.add('hidden');
                        }
                    });
                }).catch(() => {});
        }

        document.getElementById('filterForm').onsubmit = function(e) {
            e.preventDefault();
            fetchReports();
        };
        document.getElementById('resetBtn').onclick = function(e) {
            e.preventDefault();
            document.getElementById('statusFilter').value = 'All';
            document.getElementById('severityFilter').value = 'All';
            document.getElementById('provinceFilter').value = 'All';
            fetchReports();
        };
        // Initial page load: setup map and fetch reports
        initMap();
        fetchReports();

        // --- Chat Logic ---
        let chatReportId = null;
        let chatPollTimer = null;
        const chatModal = document.getElementById('chatModal');
        const chatMessagesEl = document.getElementById('chatMessages');
        const chatTitleEl = document.getElementById('chatTitle');
        const chatInput = document.getElementById('chatInput');
        const chatForm = document.getElementById('chatForm');

        function openChat(reportId, label) {
            chatReportId = reportId;
            chatTitleEl.textContent = 'Chat for ' + label;
            chatMessagesEl.innerHTML = '<div class="text-gray-400 text-center py-6 text-xs">Loading…</div>';
            chatModal.classList.remove('hidden');
            chatModal.classList.add('flex');
            loadMessages(true);
            if (chatPollTimer) clearInterval(chatPollTimer);
            chatPollTimer = setInterval(loadMessages, 5000);
        }

        function closeChat() {
            chatModal.classList.add('hidden');
            chatModal.classList.remove('flex');
            if (chatPollTimer) clearInterval(chatPollTimer);
            chatReportId = null;
        }

        document.getElementById('chatClose').onclick = closeChat;
        document.getElementById('chatBackdrop').onclick = closeChat;

        function escHandler(e) {
            if (e.key === 'Escape') closeChat();
        }
        document.addEventListener('keydown', escHandler);

        function loadMessages(scrollToBottom = false) {
            if (!chatReportId) return;
            fetch(`api/chat_messages.php?report_id=${encodeURIComponent(chatReportId)}`)
                .then(r => r.json())
                .then(rows => {
                    chatMessagesEl.innerHTML = '';
                    if (!rows.length) {
                        chatMessagesEl.innerHTML = '<div class="text-gray-400 text-center py-6 text-xs">No messages yet.</div>';
                        return;
                    }
                    rows.forEach(m => {
                        const isAdmin = Number(m.IsAdmin) === 1;
                        const isReportOwner = !isAdmin && Number(m.UserID) === Number(m.ReportOwnerID);
                        const wrapper = document.createElement('div');

                        let messageClass, nameClass, alignment;
                        if (isAdmin) {
                            messageClass = 'bg-red-50 border-red-300 text-red-700';
                            nameClass = 'text-red-700';
                            alignment = 'items-end';
                        } else if (isReportOwner) {
                            messageClass = 'bg-blue-50 border-blue-300 text-blue-700';
                            nameClass = 'text-blue-700';
                            alignment = 'items-start';
                        } else {
                            messageClass = 'bg-gray-50 border-gray-200 text-gray-800';
                            nameClass = 'text-[#04274B]';
                            alignment = 'items-start';
                        }

                        wrapper.className = `flex flex-col ${alignment}`;
                        wrapper.innerHTML = `
  <div class="max-w-[85%] rounded-lg px-3 py-2 shadow-sm border text-xs leading-snug ${messageClass}">
      <div class="font-semibold mb-1 ${nameClass}">
          ${escapeHtml(m.SenderName || (isAdmin ? 'Admin' : isReportOwner ? 'Report Owner' : 'User'))}
      </div>
      <div class="whitespace-pre-wrap break-words">${escapeHtml(m.MessageText)}</div>
      <div class="mt-1 text-[10px] opacity-60">${m.CreatedAt}</div>
  </div>`;
                        chatMessagesEl.appendChild(wrapper);
                    });
                    if (scrollToBottom) {
                        chatMessagesEl.scrollTop = chatMessagesEl.scrollHeight;
                    } else {
                        // Keep near bottom auto-scroll
                        if (chatMessagesEl.scrollHeight - chatMessagesEl.scrollTop - chatMessagesEl.clientHeight < 120) {
                            chatMessagesEl.scrollTop = chatMessagesEl.scrollHeight;
                        }
                    }
                }).catch(() => {
                    // basic fallback
                });
        }

        // NEW: update badge count for this report
        function updateChatBadge() {
            if (!chatReportId) return;
            fetch(`api/chat_messages.php?report_id=${encodeURIComponent(chatReportId)}`)
                .then(r => r.json())
                .then(rows => {
                    const btn = document.querySelector(`.chatBtn[data-report="${chatReportId}"]`);
                    if (btn) {
                        const badge = btn.querySelector('.chatCount');
                        if (badge) {
                            if (rows.length > 0) {
                                badge.textContent = rows.length > 99 ? '99+' : rows.length;
                                badge.classList.remove('hidden');
                            } else {
                                badge.classList.add('hidden');
                            }
                        }
                    }
                }).catch(() => {});
        }

        chatForm.onsubmit = function(e) {
            e.preventDefault();
            if (!chatReportId) return;
            const msg = chatInput.value.trim();
            if (!msg) return;
            const formData = new URLSearchParams();
            formData.append('report_id', chatReportId);
            formData.append('message', msg);
            fetch('api/chat_messages.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: formData.toString()
                }).then(r => r.json())
                .then(resp => {
                    if (resp.success) {
                        chatInput.value = '';
                        loadMessages(true); // will also refresh badge
                    } else {
                        alert(resp.error || 'Send failed');
                    }
                });
        };

        function escapeHtml(s) {
            return s.replace(/[&<>"']/g, c => ({
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;'
            } [c]));
        }
    </script>
</body>

</html>