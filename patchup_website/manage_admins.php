<?php

/**
 * Manage Admins Page
 * Provides UI for listing, adding, editing, and deleting PatchUp admin accounts.
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
    <title>Patch | Manage Admins</title>
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
                    class="flex items-center space-x-3 py-3 px-4 rounded-xl bg-[#04274B] text-white font-medium shadow-sm">
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

    <!-- Main content area for admin management -->
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
                        <h1 class="text-xl sm:text-2xl font-bold text-[#04274B]">Manage Admins</h1>
                        <nav class="flex text-sm text-gray-500 space-x-2" aria-label="Breadcrumb">
                            <a href="index.php" class="hover:text-[#04274B]">Dashboard</a>
                            <span>/</span>
                            <span class="text-gray-800 font-medium">Manage Admins</span>
                        </nav>
                    </div>
                </div>
                <div class="flex items-center space-x-3">
                    <button id="showAddAdminBtn"
                        class="flex items-center space-x-2 bg-[#04274B] text-white px-4 py-2 rounded-lg shadow-sm hover:bg-[#063366] transition-colors font-medium">
                        <span data-feather="user-plus" class="w-4 h-4"></span>
                        <span>Add Admin</span>
                    </button>
                </div>
            </div>
        </header>

        <!-- Admin management content -->
        <section class="p-4 sm:p-6 lg:p-8 space-y-6 max-w-7xl mx-auto">

            <!-- Page header -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex items-center space-x-3 mb-2">
                    <span data-feather="users" class="w-6 h-6 text-[#04274B]"></span>
                    <h2 class="text-xl font-semibold text-gray-800">Administrator Management</h2>
                </div>
                <p class="text-gray-600">Manage system administrators and their access permissions.</p>
            </div>

            <!-- Message display area -->
            <div id="message"></div>

            <!-- Table controls for admin list -->
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div class="flex items-center space-x-4">
                        <div class="flex items-center space-x-2">
                            <span data-feather="list" class="w-5 h-5 text-gray-500"></span>
                            <h3 class="text-lg font-semibold text-gray-800">Admin List</h3>
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
                </div>
            </div>

            <!-- Admins table with pagination -->
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50 border-b border-gray-200">
                            <tr>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Admin</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Email</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="adminsTableBody" class="divide-y divide-gray-200">
                            <!-- Admin rows will be inserted here by JS -->
                        </tbody>
                    </table>
                </div>

                <!-- Pagination controls -->
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

            <!-- Add admin modal -->
            <div id="addAdminModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden p-4">
                <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md relative transform transition-all">
                    <div class="p-6 border-b border-gray-200">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-3">
                                <div class="w-10 h-10 bg-gradient-to-br from-[#04274B] to-[#063366] rounded-lg flex items-center justify-center">
                                    <span data-feather="user-plus" class="w-5 h-5 text-white"></span>
                                </div>
                                <h2 class="text-xl font-bold text-[#04274B]">Add New Admin</h2>
                            </div>
                            <button id="closeAddAdminModal" class="text-gray-400 hover:text-gray-600 transition-colors">
                                <span data-feather="x" class="w-6 h-6"></span>
                            </button>
                        </div>
                    </div>
                    <div class="p-6">
                        <form id="addAdminForm" class="space-y-5">
                            <div id="addAdminFormMsg"></div>
                            <div class="space-y-2">
                                <label class="block text-sm font-semibold text-gray-700">Full Name</label>
                                <div class="relative">
                                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                        <span data-feather="user" class="w-4 h-4"></span>
                                    </span>
                                    <input type="text" name="name"
                                        class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white"
                                        placeholder="Enter full name" required>
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label class="block text-sm font-semibold text-gray-700">Email Address</label>
                                <div class="relative">
                                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                        <span data-feather="mail" class="w-4 h-4"></span>
                                    </span>
                                    <input type="email" name="email"
                                        class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white"
                                        placeholder="Enter email address" required>
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label class="block text-sm font-semibold text-gray-700">Password</label>
                                <div class="relative">
                                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                        <span data-feather="lock" class="w-4 h-4"></span>
                                    </span>
                                    <input type="text" name="password"
                                        class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white"
                                        placeholder="Enter password" required>
                                </div>
                            </div>
                            <div class="flex space-x-3 pt-4">
                                <button type="button" id="cancelAddBtn"
                                    class="flex-1 py-3 px-4 rounded-xl border border-gray-300 text-gray-700 font-medium hover:bg-gray-50 transition-colors">
                                    Cancel
                                </button>
                                <button type="submit"
                                    class="flex-1 py-3 px-4 rounded-xl bg-[#04274B] text-white font-semibold hover:bg-[#063366] transition-colors shadow-sm">
                                    Add Admin
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Edit admin modal -->
            <div id="editAdminModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden p-4">
                <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md relative transform transition-all">
                    <div class="p-6 border-b border-gray-200">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-3">
                                <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                                    <span data-feather="edit" class="w-5 h-5 text-white"></span>
                                </div>
                                <h2 class="text-xl font-bold text-[#04274B]">Edit Admin</h2>
                            </div>
                            <button id="closeEditAdminModal" class="text-gray-400 hover:text-gray-600 transition-colors">
                                <span data-feather="x" class="w-6 h-6"></span>
                            </button>
                        </div>
                    </div>
                    <div class="p-6">
                        <form id="editAdminForm" class="space-y-5">
                            <div id="editAdminFormMsg"></div>
                            <input type="hidden" name="id" id="editAdminId">
                            <div class="space-y-2">
                                <label class="block text-sm font-semibold text-gray-700">Full Name</label>
                                <div class="relative">
                                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                        <span data-feather="user" class="w-4 h-4"></span>
                                    </span>
                                    <input type="text" name="name" id="editAdminName"
                                        class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white"
                                        required>
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label class="block text-sm font-semibold text-gray-700">Email Address</label>
                                <div class="relative">
                                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                        <span data-feather="mail" class="w-4 h-4"></span>
                                    </span>
                                    <input type="email" name="email" id="editAdminEmail"
                                        class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white"
                                        required>
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label class="block text-sm font-semibold text-gray-700">
                                    Password
                                    <span class="text-xs text-gray-500 font-normal">(leave blank to keep unchanged)</span>
                                </label>
                                <div class="relative">
                                    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                        <span data-feather="lock" class="w-4 h-4"></span>
                                    </span>
                                    <input type="text" name="password" id="editAdminPassword"
                                        class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-4 focus:ring-blue-50 focus:border-[#04274B] transition-all outline-none bg-gray-50 hover:bg-white"
                                        placeholder="Enter new password">
                                </div>
                            </div>
                            <div class="flex space-x-3 pt-4">
                                <button type="button" id="cancelEditBtn"
                                    class="flex-1 py-3 px-4 rounded-xl border border-gray-300 text-gray-700 font-medium hover:bg-gray-50 transition-colors">
                                    Cancel
                                </button>
                                <button type="submit"
                                    class="flex-1 py-3 px-4 rounded-xl bg-[#04274B] text-white font-semibold hover:bg-[#063366] transition-colors shadow-sm">
                                    Save Changes
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Delete confirmation modal -->
            <div id="deleteConfirmModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden p-4">
                <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm relative transform transition-all">
                    <div class="p-6 border-b border-gray-200">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-3">
                                <div class="w-10 h-10 bg-gradient-to-br from-red-500 to-red-600 rounded-lg flex items-center justify-center">
                                    <span data-feather="trash-2" class="w-5 h-5 text-white"></span>
                                </div>
                                <h2 class="text-lg font-bold text-red-600">Delete Admin</h2>
                            </div>
                            <button id="closeDeleteConfirmModal" class="text-gray-400 hover:text-gray-600 transition-colors">
                                <span data-feather="x" class="w-5 h-5"></span>
                            </button>
                        </div>
                    </div>
                    <div class="p-6">
                        <p class="text-gray-700 mb-6">Are you sure you want to delete this admin? This action cannot be undone.</p>
                        <div class="flex space-x-3">
                            <button id="cancelDeleteBtn"
                                class="flex-1 py-3 px-4 rounded-xl border border-gray-300 text-gray-700 font-medium hover:bg-gray-50 transition-colors">
                                Cancel
                            </button>
                            <button id="confirmDeleteBtn"
                                class="flex-1 py-3 px-4 rounded-xl bg-red-500 text-white font-semibold hover:bg-red-600 transition-colors">
                                Delete
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
        let totalAdmins = 0;
        let allAdmins = [];

        // Fetch and display admins
        function loadAdmins() {
            fetch('api/manage_admins.php?action=list')
                .then(res => res.json())
                .then(data => {
                    allAdmins = data.admins;
                    totalAdmins = allAdmins.length;
                    currentPage = 1; // Reset to first page
                    displayAdmins();
                    updatePagination();
                });
        }

        // Display admins in table
        function displayAdmins() {
            const tbody = document.getElementById('adminsTableBody');
            tbody.innerHTML = '';

            const startIndex = (currentPage - 1) * rowsPerPage;
            const endIndex = Math.min(startIndex + rowsPerPage, totalAdmins);
            const pageAdmins = allAdmins.slice(startIndex, endIndex);

            pageAdmins.forEach(admin => {
                let badge = '';
                let actions = '';

                if (admin.is_current) {
                    badge = '<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">Current User</span>';
                    actions = '<span class="text-gray-400 text-sm">No actions available</span>';
                } else {
                    badge = '<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">Admin</span>';
                    actions = `
                        <div class="flex space-x-2">
                            <button onclick="showEditAdminModal(${admin.AdminID}, '${encodeURIComponent(admin.Name)}', '${encodeURIComponent(admin.Email)}');return false;"
                                class="flex items-center space-x-1 px-3 py-1.5 text-xs font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors">
                                <span data-feather="edit" class="w-3 h-3"></span>
                                <span>Edit</span>
                            </button>
                            <button onclick="deleteAdmin(${admin.AdminID});return false;"
                                class="flex items-center space-x-1 px-3 py-1.5 text-xs font-medium text-red-600 bg-red-50 rounded-lg hover:bg-red-100 transition-colors">
                                <span data-feather="trash-2" class="w-3 h-3"></span>
                                <span>Delete</span>
                            </button>
                        </div>
                    `;
                }

                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50 transition-colors';
                row.innerHTML = `
                    <td class="px-6 py-4">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-gradient-to-br from-[#04274B] to-[#063366] rounded-full flex items-center justify-center text-white font-semibold">
                                ${admin.Name.charAt(0).toUpperCase()}
                            </div>
                            <div>
                                <div class="font-semibold text-gray-800">${admin.Name}</div>
                                <div class="text-sm text-gray-500">ID: ${admin.AdminID}</div>
                            </div>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center space-x-2 text-sm text-gray-600">
                            <span data-feather="mail" class="w-4 h-4"></span>
                            <span>${admin.Email}</span>
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        ${badge}
                    </td>
                    <td class="px-6 py-4">
                        ${actions}
                    </td>
                `;
                tbody.appendChild(row);
            });

            // Re-initialize feather icons for new content
            feather.replace();

            // Update showing info
            document.getElementById('showingFrom').textContent = totalAdmins === 0 ? 0 : startIndex + 1;
            document.getElementById('showingTo').textContent = endIndex;
            document.getElementById('totalEntries').textContent = totalAdmins;
        }

        // Update pagination controls
        function updatePagination() {
            const totalPages = Math.ceil(totalAdmins / rowsPerPage);
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
            displayAdmins();
            updatePagination();
        }

        function goToPrevPage() {
            if (currentPage > 1) {
                goToPage(currentPage - 1);
            }
        }

        function goToNextPage() {
            const totalPages = Math.ceil(totalAdmins / rowsPerPage);
            if (currentPage < totalPages) {
                goToPage(currentPage + 1);
            }
        }

        // Event listeners for pagination and rows per page
        document.getElementById('rowsPerPage').addEventListener('change', function() {
            rowsPerPage = parseInt(this.value);
            currentPage = 1; // Reset to first page
            displayAdmins();
            updatePagination();
        });

        document.getElementById('prevPage').addEventListener('click', goToPrevPage);
        document.getElementById('nextPage').addEventListener('click', goToNextPage);

        // Show message helper
        function showMessage(msg, type) {
            const div = document.getElementById('message');
            div.innerHTML = `<div class="px-4 py-3 rounded-lg mb-4 ${type === 'error' ? 'bg-red-100 text-red-700 border border-red-200' : 'bg-green-100 text-green-700 border border-green-200'}">${msg}</div>`;
            setTimeout(() => {
                div.innerHTML = '';
            }, 5000);
        }

        // Add admin modal logic
        const modal = document.getElementById('addAdminModal');
        document.getElementById('showAddAdminBtn').onclick = () => {
            modal.classList.remove('hidden');
        };
        document.getElementById('closeAddAdminModal').onclick = () => {
            modal.classList.add('hidden');
        };

        // Add admin form submission
        document.getElementById('addAdminForm').onsubmit = function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const msgDiv = document.getElementById('addAdminFormMsg');
            msgDiv.innerHTML = '';
            fetch('api/manage_admins.php?action=add', {
                    method: 'POST',
                    body: formData
                }).then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        this.reset();
                        modal.classList.add('hidden');
                        msgDiv.innerHTML = '';
                        loadAdmins();
                    } else {
                        msgDiv.innerHTML = `<div class="bg-red-100 text-red-700 px-4 py-2 rounded mb-2">${data.message}</div>`;
                    }
                });
        };

        // Edit admin modal logic
        const editModal = document.getElementById('editAdminModal');
        document.getElementById('closeEditAdminModal').onclick = () => {
            editModal.classList.add('hidden');
        };

        function showEditAdminModal(id, name, email) {
            document.getElementById('editAdminId').value = id;
            document.getElementById('editAdminName').value = decodeURIComponent(name);
            document.getElementById('editAdminEmail').value = decodeURIComponent(email);
            document.getElementById('editAdminPassword').value = '';
            document.getElementById('editAdminFormMsg').innerHTML = '';
            editModal.classList.remove('hidden');
        }

        // Edit admin form submission
        document.getElementById('editAdminForm').onsubmit = function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const msgDiv = document.getElementById('editAdminFormMsg');
            msgDiv.innerHTML = '';
            fetch('api/manage_admins.php?action=edit', {
                    method: 'POST',
                    body: formData
                }).then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        this.reset();
                        editModal.classList.add('hidden');
                        msgDiv.innerHTML = '';
                        loadAdmins();
                    } else {
                        msgDiv.innerHTML = `<div class="bg-red-100 text-red-700 px-4 py-2 rounded mb-2">${data.message}</div>`;
                    }
                });
        };

        // Delete confirmation modal logic
        let deleteAdminId = null;
        const deleteModal = document.getElementById('deleteConfirmModal');
        const closeDeleteBtn = document.getElementById('closeDeleteConfirmModal');
        const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
        const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');

        function deleteAdmin(id) {
            deleteAdminId = id;
            deleteModal.classList.remove('hidden');
        }

        closeDeleteBtn.onclick = () => {
            deleteModal.classList.add('hidden');
            deleteAdminId = null;
        };
        cancelDeleteBtn.onclick = () => {
            deleteModal.classList.add('hidden');
            deleteAdminId = null;
        };
        confirmDeleteBtn.onclick = () => {
            if (!deleteAdminId) return;
            fetch('api/manage_admins.php?action=delete', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'id=' + encodeURIComponent(deleteAdminId)
                }).then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        loadAdmins();
                    } else {
                        showMessage(data.message, 'error');
                    }
                    deleteModal.classList.add('hidden');
                    deleteAdminId = null;
                });
        };

        // Close modal when clicking outside
        window.addEventListener('click', function(event) {
            if (event.target === deleteModal) {
                deleteModal.classList.add('hidden');
                deleteAdminId = null;
            }
            if (event.target === modal) modal.classList.add('hidden');
            if (event.target === editModal) editModal.classList.add('hidden');
        });

        // Initial load of admins
        loadAdmins();
    </script>

    <!-- Sidebar toggle script -->
    <script src="javascript/script.js"></script>
    <script>
        feather.replace();
    </script>
</body>

</html>