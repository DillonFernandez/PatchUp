<?php

/**
 * Customer Reports Page
 * Displays all pothole reports submitted by a specific customer,
 * including filter controls, heatmap visualization, and report grid.
 */

// Session handling and admin authentication
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}
$userid = isset($_GET['userid']) ? intval($_GET['userid']) : 0;
$name = isset($_GET['name']) ? htmlspecialchars($_GET['name']) : '';
if (!$userid) {
    header("Location: view_customers.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Meta, styles, and external scripts -->
    <meta charset="UTF-8">
    <title>Patch | <?php echo $name ? $name : 'Customer'; ?>'s Reports</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
    <script src="https://unpkg.com/leaflet.heat/dist/leaflet-heat.js"></script>
    <script src="https://unpkg.com/feather-icons"></script>
</head>

<body class="bg-gray-100 min-h-screen flex flex-col">
    <!-- Header navigation -->
    <header class="bg-white px-4 sm:px-6 py-4 border-b border-gray-200 shadow-sm w-full">
        <div class="flex items-center justify-between max-w-7xl mx-auto">
            <div class="flex items-center space-x-4">
                <a href="view_customers.php">
                    <button type="button"
                        class="flex items-center justify-center px-3 py-2 rounded-lg bg-[#04274B] text-white hover:bg-[#063366] transition-colors shadow-sm"
                        title="Back to Customers">
                        <span data-feather="arrow-left" class="w-4 h-4 mr-2"></span>
                        <span class="hidden sm:inline">Back</span>
                    </button>
                </a>
                <div>
                    <h1 class="text-xl sm:text-2xl font-bold text-[#04274B]">
                        <?php echo $name ? $name : 'Customer'; ?>'s Reports
                    </h1>
                    <nav class="flex text-sm text-gray-500 space-x-2" aria-label="Breadcrumb">
                        <a href="index.php" class="hover:text-[#04274B]">Dashboard</a>
                        <span>/</span>
                        <a href="view_customers.php" class="hover:text-[#04274B]">Customers</a>
                        <span>/</span>
                        <span class="text-gray-800 font-medium"><?php echo $name ? $name : 'Customer'; ?></span>
                    </nav>
                </div>
            </div>
            <div class="flex items-center space-x-3">
                <div class="hidden sm:flex items-center space-x-2 bg-gray-50 px-3 py-2 rounded-lg">
                    <span data-feather="user" class="w-4 h-4 text-gray-500"></span>
                    <span class="text-sm text-gray-600">Customer Reports</span>
                </div>
            </div>
        </div>
    </header>

    <main class="flex-1 bg-gray-50 min-h-screen overflow-x-hidden">
        <section class="p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">

            <!-- Page header -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex items-center space-x-3 mb-2">
                    <span data-feather="file-text" class="w-6 h-6 text-[#04274B]"></span>
                    <h2 class="text-xl font-semibold text-gray-800">Reports by <?php echo $name ? $name : 'Customer'; ?></h2>
                </div>
                <p class="text-gray-600">View all reports submitted by this customer with interactive heatmap visualization.</p>
            </div>

            <!-- Filter controls for reports -->
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

            <!-- Heatmap visualization for customer reports -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center space-x-2">
                        <span data-feather="map" class="w-5 h-5 text-gray-500"></span>
                        <h3 class="text-lg font-semibold text-gray-800">Customer Heatmap</h3>
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

            <!-- Reports grid listing all reports -->
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <div class="p-6 border-b border-gray-200">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-2">
                            <span data-feather="grid" class="w-5 h-5 text-gray-500"></span>
                            <h3 class="text-lg font-semibold text-gray-800">Reports List</h3>
                        </div>
                        <div class="text-sm text-gray-500">
                            <span data-feather="info" class="w-4 h-4 inline mr-1"></span>
                            View report details
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

    <script src="javascript/script.js"></script>
    <script>
        // Initialize Leaflet heatmap for customer reports
        let map, heatCritical, heatModerate, heatSmall;

        function initMap() {
            if (map) return;
            const sriLankaBounds = L.latLngBounds([5.719, 79.521], [9.850, 81.881]);
            map = L.map('heatmap', {
                maxBounds: sriLankaBounds,
                maxBoundsViscosity: 1.0,
                minZoom: 7,
                maxZoom: 12,
                zoomControl: true
            }).setView([7.8731, 80.7718], 7);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(map);
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
            const critical = [],
                moderate = [],
                small = [];
            data.forEach(r => {
                if (r.Latitude && r.Longitude) {
                    const lat = parseFloat(r.Latitude);
                    const lng = parseFloat(r.Longitude);
                    if (r.SeverityLevel === 'Critical') critical.push([lat, lng, 1]);
                    else if (r.SeverityLevel === 'Moderate') moderate.push([lat, lng, 1]);
                    else if (r.SeverityLevel === 'Small') small.push([lat, lng, 1]);
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
            const userid = <?php echo json_encode($userid); ?>;
            fetch(`api/view_customers.php?action=reports&userid=${encodeURIComponent(userid)}&status=${encodeURIComponent(status)}&severity=${encodeURIComponent(severity)}&province=${encodeURIComponent(province)}`)
                .then(res => res.json())
                .then(async data => {
                    const reportsArr = data.reports || [];
                    // fetch confirmation counts -> now validations (pothole_validation)
                    let countsMap = {};
                    const ids = reportsArr.map(r => r.ReportID).filter(Boolean);
                    if (ids.length) {
                        try {
                            const cRes = await fetch('api/report_confirmations_counts.php?report_ids=' + ids.join(','));
                            const cJson = await cRes.json();
                            countsMap = cJson.counts || {};
                        } catch (e) {}
                    }
                    updateHeatmap(reportsArr);
                    const grid = document.getElementById('reportsGrid');
                    grid.innerHTML = '';
                    if (!reportsArr.length) {
                        grid.innerHTML = `
                            <div class="col-span-full text-center text-gray-500 py-12 bg-gray-50 rounded-xl border-2 border-dashed border-gray-200">
                                <div class="flex flex-col items-center space-y-2">
                                    <span data-feather="inbox" class="w-12 h-12 text-gray-300"></span>
                                    <p class="text-lg font-medium">No reports found</p>
                                    <p class="text-sm">This customer hasn't submitted any reports yet</p>
                                </div>
                            </div>
                        `;
                        feather.replace();
                        return;
                    }
                    reportsArr.forEach(report => {
                        const sevClass = report.SeverityLevel === 'Critical' ? 'bg-red-50 text-red-700 border-red-200' :
                            report.SeverityLevel === 'Moderate' ? 'bg-yellow-50 text-yellow-700 border-yellow-200' :
                            'bg-green-50 text-green-700 border-green-200';
                        const statusClass = report.Status === 'Resolved' ? 'bg-green-100 text-green-800' :
                            report.Status === 'In Progress' ? 'bg-blue-100 text-blue-800' :
                            'bg-gray-100 text-gray-800';
                        const img = report.ImageURL ?
                            `<img src="${report.ImageURL}" alt="Pothole Image" class="object-cover w-full h-32 rounded-lg">` :
                            `<div class="w-full h-32 bg-gray-100 rounded-lg flex items-center justify-center text-gray-400"><span data-feather="image" class="w-8 h-8"></span></div>`;
                        // Change confirmation text to "Validation(s)"
                        const cCount = Number(countsMap[report.ReportID] || 0);
                        const cText = cCount === 0 ? 'No validations' : (cCount === 1 ? '1 Validation' : cCount + ' Validations');
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
        <div class="flex items-start space-x-2">
            <span data-feather="file-text" class="w-4 h-4 text-gray-400 mt-0.5"></span>
            <p class="text-sm text-gray-600 line-clamp-2">${report.Description || '<span class="italic text-gray-400">(No description)</span>'}</p>
        </div>
        
        <div class="flex items-center space-x-2">
            <span data-feather="map-pin" class="w-4 h-4 text-gray-400"></span>
            <span class="text-sm text-gray-600">${report.Province}</span>
        </div>
        
        <div class="flex items-center space-x-2">
            <span data-feather="check-circle" class="w-4 h-4 text-gray-400"></span>
            <span class="text-sm text-gray-600">${cText}</span>
        </div>
        
        <div class="flex items-center space-x-2">
            <span data-feather="navigation" class="w-4 h-4 text-gray-400"></span>
            <span class="text-sm text-gray-600">Lat: ${report.Latitude}, Lng: ${report.Longitude}</span>
        </div>
        
        <div class="flex items-center space-x-2">
            <span data-feather="clock" class="w-4 h-4 text-gray-400"></span>
            <span class="text-xs text-gray-500">${report.Timestamp}</span>
        </div>
    </div>
    
    <div class="mt-4 pt-3 border-t border-gray-100">
        <a href="https://www.google.com/maps?q=${report.Latitude},${report.Longitude}" target="_blank"
           class="inline-flex items-center space-x-1 text-blue-600 text-sm hover:text-blue-800 transition-colors">
            <span data-feather="external-link" class="w-4 h-4"></span>
            <span>View on Map</span>
        </a>
    </div>
</div>
`;
                    });
                    feather.replace();
                });
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
        // Initial page load: setup map, fetch reports, and icons
        initMap();
        fetchReports();
        feather.replace();
    </script>
</body>

</html>