<?php

/**
 * View Customers Page
 * Displays all registered customers and allows viewing their report history.
 */

// Session handling and admin authentication
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
    <title>Patch | View Customers</title>
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
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl hover:bg-gray-50 text-gray-700 hover:text-[#04274B] transition-colors">
                    <span data-feather="alert-triangle" class="w-5 h-5"></span>
                    <span>Manage Reports</span>
                </a>
                <a href="view_customers.php"
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl bg-[#04274B] text-white font-medium shadow-sm">
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

    <!-- Main content area for customer directory -->
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
                        <h1 class="text-xl sm:text-2xl font-bold text-[#04274B]">View Customers</h1>
                        <nav class="flex text-sm text-gray-500 space-x-2" aria-label="Breadcrumb">
                            <a href="index.php" class="hover:text-[#04274B]">Dashboard</a>
                            <span>/</span>
                            <span class="text-gray-800 font-medium">View Customers</span>
                        </nav>
                    </div>
                </div>
                <div class="flex items-center space-x-3">
                    <div class="hidden sm:flex items-center space-x-2 bg-gray-50 px-3 py-2 rounded-lg">
                        <span data-feather="users" class="w-4 h-4 text-gray-500"></span>
                        <span class="text-sm text-gray-600">Customer Directory</span>
                    </div>
                </div>
            </div>
        </header>

        <!-- Customers content -->
        <section class="p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">

            <!-- Page header -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex items-center space-x-3 mb-2">
                    <span data-feather="users" class="w-6 h-6 text-[#04274B]"></span>
                    <h2 class="text-xl font-semibold text-gray-800">Customer Directory</h2>
                </div>
                <p class="text-gray-600">View and manage all registered customers and their report history.</p>
            </div>

            <!-- Table controls for customer list -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div class="flex items-center space-x-4">
                        <div class="flex items-center space-x-2">
                            <span data-feather="list" class="w-5 h-5 text-gray-500"></span>
                            <h3 class="text-lg font-semibold text-gray-800">Customer List</h3>
                        </div>
                        <div class="flex items-center space-x-2">
                            <label class="text-sm font-medium text-gray-600">Show:</label>
                            <select id="rowsPerPage" class="border border-gray-300 rounded-lg px-3 py-1 text-sm focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] outline-none">
                                <option value="10">10</option>
                                <option value="20">20</option>
                                <option value="50">50</option>
                            </select>
                            <span class="text-sm text-gray-600">entries</span>
                        </div>
                    </div>
                    <div class="flex items-center space-x-2 text-sm text-gray-500">
                        <span data-feather="info" class="w-4 h-4"></span>
                        <span>Click to view customer reports</span>
                    </div>
                </div>
            </div>

            <!-- Customers table with pagination -->
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50 border-b border-gray-200">
                            <tr>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Customer</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Email</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Points</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="customersTableBody" class="divide-y divide-gray-200">
                            <!-- Customer rows will be inserted here by JS -->
                        </tbody>
                    </table>
                </div>

                <!-- Section: Pagination -->
                <div class="px-6 py-4 border-t border-gray-200 bg-gray-50">
                    <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
                        <div class="text-sm text-gray-600">
                            Showing <span id="showingFrom">0</span> to <span id="showingTo">0</span> of <span id="totalEntries">0</span> entries
                        </div>
                        <div class="flex items-center space-x-2">
                            <button id="prevPage"
                                class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                <span data-feather="chevron-left" class="w-4 h-4"></span>
                            </button>
                            <div id="pageNumbers" class="flex items-center space-x-1">
                                <!-- Page numbers will be inserted here -->
                            </div>
                            <button id="nextPage"
                                class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                <span data-feather="chevron-right" class="w-4 h-4"></span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

        </section>
    </main>

    <script>
        // Pagination variables and logic
        let currentPage = 1;
        let rowsPerPage = 10;
        let totalCustomers = 0;
        let allCustomers = [];

        // Fetch and display customers
        function loadCustomers() {
            fetch('api/view_customers.php?action=list')
                .then(res => res.json())
                .then(data => {
                    // Defensive filter: remove emails starting with admin+
                    allCustomers = (data.customers || []).filter(c => !/^admin\+/.test(c.Email));
                    totalCustomers = allCustomers.length;
                    currentPage = 1; // Reset to first page
                    displayCustomers();
                    updatePagination();
                });
        }

        // Display customers in table
        function displayCustomers() {
            const tbody = document.getElementById('customersTableBody');
            tbody.innerHTML = '';

            if (totalCustomers === 0) {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td colspan="4" class="px-6 py-12 text-center">
                        <div class="flex flex-col items-center space-y-2 text-gray-500">
                            <span data-feather="user-x" class="w-12 h-12 text-gray-300"></span>
                            <p class="text-lg font-medium">No customers found</p>
                            <p class="text-sm">No customers have registered yet</p>
                        </div>
                    </td>
                `;
                tbody.appendChild(row);
                feather.replace();
                return;
            }

            const startIndex = (currentPage - 1) * rowsPerPage;
            const endIndex = Math.min(startIndex + rowsPerPage, totalCustomers);
            const pageCustomers = allCustomers.slice(startIndex, endIndex);

            pageCustomers.forEach(customer => {
                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50 transition-colors';
                row.innerHTML = `
                    <td class="px-6 py-4">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-gradient-to-br from-[#04274B] to-[#063366] rounded-full flex items-center justify-center text-white font-semibold">
                                ${customer.Name.charAt(0).toUpperCase()}
                            </div>
                            <div>
                                <div class="font-semibold text-gray-800">${customer.Name}</div>
                                <div class="text-sm text-gray-500">ID: ${customer.UserID}</div>
                            </div>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center space-x-2 text-sm text-gray-600">
                            <span data-feather="mail" class="w-4 h-4"></span>
                            <span>${customer.Email}</span>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                            ${customer.Points} points
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <a href="customer_reports.php?userid=${customer.UserID}&name=${encodeURIComponent(customer.Name)}"
                           class="inline-flex items-center space-x-1 px-3 py-1.5 text-xs font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors">
                            <span data-feather="file-text" class="w-3 h-3"></span>
                            <span>View Reports</span>
                        </a>
                    </td>
                `;
                tbody.appendChild(row);
            });

            // Re-initialize feather icons for new content
            feather.replace();

            // Update showing info
            document.getElementById('showingFrom').textContent = totalCustomers === 0 ? 0 : startIndex + 1;
            document.getElementById('showingTo').textContent = endIndex;
            document.getElementById('totalEntries').textContent = totalCustomers;
        }

        // Update pagination controls
        function updatePagination() {
            const totalPages = Math.ceil(totalCustomers / rowsPerPage);
            const prevBtn = document.getElementById('prevPage');
            const nextBtn = document.getElementById('nextPage');
            const pageNumbers = document.getElementById('pageNumbers');

            // Update prev/next buttons
            prevBtn.disabled = currentPage === 1;
            nextBtn.disabled = currentPage === totalPages || totalPages === 0;

            // Generate page numbers
            pageNumbers.innerHTML = '';
            const maxVisiblePages = 5;
            let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
            let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

            // Adjust startPage if we're near the end
            if (endPage - startPage + 1 < maxVisiblePages) {
                startPage = Math.max(1, endPage - maxVisiblePages + 1);
            }

            for (let i = startPage; i <= endPage; i++) {
                const pageBtn = document.createElement('button');
                pageBtn.className = `px-3 py-2 border text-sm font-medium transition-colors ${
                    i === currentPage 
                        ? 'bg-[#04274B] text-white border-[#04274B]' 
                        : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'
                } rounded-lg`;
                pageBtn.textContent = i;
                pageBtn.onclick = () => goToPage(i);
                pageNumbers.appendChild(pageBtn);
            }

            // Add ellipsis and last page if needed
            if (endPage < totalPages) {
                if (endPage < totalPages - 1) {
                    const ellipsis = document.createElement('span');
                    ellipsis.textContent = '...';
                    ellipsis.className = 'px-3 py-2 text-gray-500';
                    pageNumbers.appendChild(ellipsis);
                }

                const lastPageBtn = document.createElement('button');
                lastPageBtn.className = 'px-3 py-2 border bg-white text-gray-700 border-gray-300 hover:bg-gray-50 rounded-lg text-sm font-medium transition-colors';
                lastPageBtn.textContent = totalPages;
                lastPageBtn.onclick = () => goToPage(totalPages);
                pageNumbers.appendChild(lastPageBtn);
            }
        }

        // Pagination functions
        function goToPage(page) {
            currentPage = page;
            displayCustomers();
            updatePagination();
        }

        function goToPrevPage() {
            if (currentPage > 1) {
                goToPage(currentPage - 1);
            }
        }

        function goToNextPage() {
            const totalPages = Math.ceil(totalCustomers / rowsPerPage);
            if (currentPage < totalPages) {
                goToPage(currentPage + 1);
            }
        }

        // Event listeners for pagination and rows per page
        document.getElementById('rowsPerPage').addEventListener('change', function() {
            rowsPerPage = parseInt(this.value);
            currentPage = 1; // Reset to first page
            displayCustomers();
            updatePagination();
        });

        document.getElementById('prevPage').addEventListener('click', goToPrevPage);
        document.getElementById('nextPage').addEventListener('click', goToNextPage);

        // Initial customers load
        loadCustomers();
    </script>

    <!-- Sidebar toggle script -->
    <script src="javascript/script.js"></script>
    <script>
        feather.replace();
    </script>
</body>

</html>