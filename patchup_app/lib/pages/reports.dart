//
// ReportsPage: Displays community pothole reports, heatmap, filters, and confirmation actions.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat/chat_page.dart';
import '../components/appbar.dart';
import '../localization/app_localizations.dart';

// Fetches heatmap points for pothole density visualization
Future<List<WeightedLatLng>> fetchHeatmapPoints() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.2/patchup_app/lib/api/heatmap_points.php'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) {
      double weight;
      switch (item['severity']) {
        case 'Critical':
          weight = 1.0;
          break;
        case 'Moderate':
          weight = 0.7;
          break;
        case 'Small':
          weight = 0.4;
          break;
        default:
          weight = 0.5;
      }
      return WeightedLatLng(
        LatLng(item['latitude'], item['longitude']),
        weight,
      );
    }).toList();
  }
  return [];
}

// Fetches all pothole reports from backend
Future<List<Map<String, dynamic>>> fetchReports() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.2/patchup_app/lib/api/display_reports.php'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}

// Fetches confirmation counts for all reports
Future<Map<int, int>> fetchConfirmationCounts() async {
  final response = await http.get(
    Uri.parse(
      'http://192.168.1.2/patchup_app/lib/api/report_confirmation_counts.php',
    ),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    // Convert keys to int
    return data.map((k, v) => MapEntry(int.parse(k), v as int));
  }
  return {};
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Filter selections
  String? selectedStatus;
  String? selectedSeverity;
  String? selectedProvince;
  DateTimeRange? selectedDateRange;

  // Filter options
  final List<String> statusOptions = [
    'All',
    'Resolved',
    'In Progress',
    'Reported',
  ];
  final List<String> severityOptions = ['All', 'Critical', 'Moderate', 'Small'];
  final List<String> provinceOptions = [
    'All',
    'Central Province',
    'Eastern Province',
    'North Central Province',
    'Northern Province',
    'North Western Province',
    'Sabaragamuwa Province',
    'Southern Province',
    'Uva Province',
    'Western Province',
  ];

  // Checks if app is offline
  bool get _isOffline =>
      !(WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);

  // Formats report date/time for display
  String _formatDateTime(String raw) {
    DateTime? dt;
    try {
      dt = DateTime.parse(raw);
    } catch (_) {
      return raw;
    }
    String daySuffix(int d) {
      if (d >= 11 && d <= 13) return 'th';
      switch (d % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    final day = dt.day;
    final suffix = daySuffix(day);
    final month =
        [
          '',
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ][dt.month];
    int hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm =
        hour >= 12
            ? AppLocalizations.of(context).translate('PM')
            : AppLocalizations.of(context).translate('AM');
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return '$day$suffix $month - $hour:$minute $ampm';
  }

  // Tracks confirmed reports for the current user
  Set<int> confirmedReports = {};

  // Stores confirmation counts for each report
  Map<int, int> confirmationCounts = {};

  // Current user email and ID
  String? currentUserEmail;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadConfirmedReports();
    _loadConfirmationCounts();
    _loadCurrentUserId();
  }

  // Loads current user ID from backend
  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null) {
      final resp = await http.post(
        Uri.parse('http://192.168.1.2/patchup_app/lib/api/get_user_info.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          currentUserId = data['user_id'];
        });
      }
    }
  }

  // Loads confirmed report IDs for current user
  Future<void> _loadConfirmedReports() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('user_email');
    });
    if (currentUserEmail != null) {
      // Fetch confirmed report IDs for this user
      final url =
          'http://192.168.1.2/patchup_app/lib/api/user_confirmed_reports.php';
      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserEmail': currentUserEmail}),
      );
      if (resp.statusCode == 200) {
        final List<dynamic> ids = jsonDecode(resp.body);
        setState(() {
          confirmedReports = ids.map((e) => e as int).toSet();
        });
      }
    }
  }

  // Loads confirmation counts for all reports
  Future<void> _loadConfirmationCounts() async {
    final counts = await fetchConfirmationCounts();
    setState(() {
      confirmationCounts = counts;
    });
  }

  // Confirms a pothole report for the current user
  Future<void> _confirmPothole(int reportId) async {
    if (currentUserEmail == null) return;
    final url = 'http://192.168.1.2/patchup_app/lib/api/confirm_pothole.php';
    final resp = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'UserEmail': currentUserEmail, 'ReportID': reportId}),
    );
    if (resp.statusCode == 200) {
      final result = jsonDecode(resp.body);
      if (result['success'] == true) {
        setState(() {
          confirmedReports.add(reportId);
          // Increment confirmation count locally for instant feedback
          confirmationCounts[reportId] =
              (confirmationCounts[reportId] ?? 0) + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('Pothole confirmed!'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  AppLocalizations.of(context).translate('Error'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const UserAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heatmap section
              _buildHeatmapSection(context, appLoc),
              const SizedBox(height: 24),

              // Filter section
              _buildFilterSection(context, appLoc),
              const SizedBox(height: 24),

              // Reports section
              _buildReportsSection(context, appLoc),
            ],
          ),
        ),
      ),
    );
  }

  // Builds heatmap section for all reports
  Widget _buildHeatmapSection(BuildContext context, AppLocalizations appLoc) {
    return Column(
      children: [
        // Section Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF04274B), Color(0xFF1e40af)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF04274B).withOpacity(0.12),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.map_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLoc.translate('Heatmap Overview'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Interactive pothole density map'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Heatmap Container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 250,
              child: FutureBuilder<List<WeightedLatLng>>(
                future: fetchHeatmapPoints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildHeatmapLoading();
                  }
                  if (_isOffline) {
                    return _buildHeatmapOffline(appLoc);
                  }
                  if (snapshot.hasError) {
                    return _buildHeatmapError(appLoc);
                  }
                  final points = snapshot.data ?? [];
                  if (points.isEmpty) {
                    return _buildHeatmapEmpty(appLoc);
                  }
                  return FlutterMap(
                    options: MapOptions(
                      center: LatLng(7.8731, 80.7718),
                      zoom: 7.0,
                      minZoom: 6.0,
                      maxZoom: 12.0,
                      interactiveFlags: InteractiveFlag.all,
                      maxBounds: LatLngBounds(
                        LatLng(5.7, 79.5),
                        LatLng(9.9, 81.9),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.patchup_app',
                      ),
                      HeatMapLayer(
                        heatMapDataSource: InMemoryHeatMapDataSource(
                          data: points,
                        ),
                        heatMapOptions: HeatMapOptions(
                          radius: 50.0,
                          minOpacity: 0.1,
                          gradient: {
                            0.0: Colors.green,
                            0.5: Colors.yellow,
                            1.0: Colors.red,
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Builds filter section for reports
  Widget _buildFilterSection(BuildContext context, AppLocalizations appLoc) {
    return Column(
      children: [
        // Filter Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFF04274B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFF04274B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      appLoc.translate("Filter Reports"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF04274B),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _ModernDropdown(
                        label: appLoc.translate("Status"),
                        value: selectedStatus ?? appLoc.translate('All'),
                        items: statusOptions.map(appLoc.translate).toList(),
                        icon: Icons.flag_rounded,
                        onChanged: (val) {
                          setState(() {
                            selectedStatus =
                                val == appLoc.translate('All') ? null : val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ModernDropdown(
                        label: appLoc.translate("Severity"),
                        value: selectedSeverity ?? appLoc.translate('All'),
                        items: severityOptions.map(appLoc.translate).toList(),
                        icon: Icons.warning_amber_rounded,
                        onChanged: (val) {
                          setState(() {
                            selectedSeverity =
                                val == appLoc.translate('All') ? null : val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ModernDropdown(
                        label: appLoc.translate("Province"),
                        value: selectedProvince ?? appLoc.translate('All'),
                        items: provinceOptions.map(appLoc.translate).toList(),
                        icon: Icons.map_rounded,
                        onChanged: (val) {
                          setState(() {
                            selectedProvince =
                                val == appLoc.translate('All') ? null : val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDateRangeSelector(context, appLoc)),
                  ],
                ),
                if ((selectedStatus != null ||
                    selectedSeverity != null ||
                    selectedProvince != null ||
                    selectedDateRange != null))
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.clear_rounded, size: 18),
                        label: Text(
                          appLoc.translate('Clear All Filters'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[300]!, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.red[50],
                        ),
                        onPressed: () {
                          setState(() {
                            selectedStatus = null;
                            selectedSeverity = null;
                            selectedProvince = null;
                            selectedDateRange = null;
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Builds reports section with list and actions
  Widget _buildReportsSection(BuildContext context, AppLocalizations appLoc) {
    return Column(
      children: [
        // Section Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF04274B), Color(0xFF1e40af)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF04274B).withOpacity(0.12),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.list_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLoc.translate('All Reports'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Community pothole reports'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Reports List
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildReportsLoading();
            }
            if (_isOffline) {
              return _buildReportsOffline(appLoc);
            }
            if (snapshot.hasError) {
              return _buildReportsError(appLoc);
            }
            final reports = snapshot.data ?? [];
            final filteredReports =
                reports.where((report) {
                  if (selectedStatus != null &&
                      (report['Status'] == null ||
                          appLoc.translate((report['Status'] as String)) !=
                              selectedStatus)) {
                    return false;
                  }
                  if (selectedSeverity != null &&
                      (report['SeverityLevel'] == null ||
                          appLoc.translate(
                                (report['SeverityLevel'] as String),
                              ) !=
                              selectedSeverity)) {
                    return false;
                  }
                  if (selectedProvince != null &&
                      (report['Province'] == null ||
                          appLoc.translate(report['Province']) !=
                              selectedProvince)) {
                    return false;
                  }
                  if (selectedDateRange != null &&
                      report['Timestamp'] != null &&
                      report['Timestamp'].toString().isNotEmpty) {
                    try {
                      final reportDate = DateTime.parse(report['Timestamp']);
                      if (reportDate.isBefore(selectedDateRange!.start) ||
                          reportDate.isAfter(selectedDateRange!.end)) {
                        return false;
                      }
                    } catch (_) {}
                  }
                  return true;
                }).toList();

            if (filteredReports.isEmpty) {
              return _buildReportsEmpty(appLoc);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredReports.length,
              separatorBuilder: (_, __) => SizedBox(height: 5),
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                final reportId =
                    report['ReportID'] is int
                        ? report['ReportID']
                        : int.tryParse(report['ReportID'].toString()) ?? 0;
                final int confirmCount = confirmationCounts[reportId] ?? 0;
                final bool isConfirmed = confirmedReports.contains(reportId);

                final int? reportUserId =
                    report['UserID'] is int
                        ? report['UserID']
                        : int.tryParse(report['UserID']?.toString() ?? '');
                final bool isOwnReport =
                    (currentUserId != null &&
                        reportUserId != null &&
                        currentUserId == reportUserId);

                return _ReportCard(
                  report: report,
                  confirmCount: confirmCount,
                  isConfirmed: isConfirmed,
                  isOwnReport: isOwnReport,
                  onConfirm: () => _confirmPothole(reportId),
                  formatDateTime: _formatDateTime,
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Date range selector for filtering
  Widget _buildDateRangeSelector(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 2),
          lastDate: now,
          initialDateRange: selectedDateRange,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF04274B),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF04274B),
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            selectedDateRange = picked;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range_rounded, size: 16, color: Colors.grey[600]),

              SizedBox(width: 6),
              Text(
                appLoc.translate('Date Range'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDateRange == null
                        ? appLoc.translate('Select date range')
                        : '${selectedDateRange!.start.day}/${selectedDateRange!.start.month}/${selectedDateRange!.start.year} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}/${selectedDateRange!.end.year}',
                    style: TextStyle(
                      color: Color(0xFF04274B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selectedDateRange != null)
                  IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.red[400],
                      size: 16,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedDateRange = null;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    splashRadius: 16,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Loading, offline, error, and empty states for heatmap and reports
  Widget _buildHeatmapLoading() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF04274B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Color(0xFF04274B),
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).translate('Loading heatmap...'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapOffline(AppLocalizations appLoc) {
    return Container(
      color: Colors.orange[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: Colors.orange[600]),
            SizedBox(height: 10),
            Text(
              appLoc.translate(
                'Currently offline. Will sync when back online.',
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapError(AppLocalizations appLoc) {
    return Container(
      color: Colors.red[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: Colors.red[600]),
            SizedBox(height: 10),
            Text(
              appLoc.translate('An error occurred while loading the heatmap.'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapEmpty(AppLocalizations appLoc) {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 40, color: Colors.grey[400]),
            SizedBox(height: 10),
            Text(
              appLoc.translate('No data available.'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsLoading() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF04274B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Color(0xFF04274B),
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).translate('Loading reports...'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsOffline(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 36, color: Colors.orange[600]),
          SizedBox(height: 6),
          Text(
            appLoc.translate('Currently offline. Will sync when back online.'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[800],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsError(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 36, color: Colors.red[600]),
          SizedBox(height: 6),
          Text(
            appLoc.translate('An error occurred while loading reports.'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[800],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsEmpty(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 40, color: Colors.grey[400]),
          SizedBox(height: 10),
          Text(
            appLoc.translate('No reports found.'),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3),
          Text(
            appLoc.translate('Try adjusting your filters'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Dropdown widget for filters
class _ModernDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _ModernDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 6),
            Text(
              appLoc.translate(label),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items:
                  items
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              s,
                              style: TextStyle(
                                color: Color(0xFF04274B),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              icon: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF04274B),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Report card widget for displaying a report
class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final int confirmCount;
  final bool isConfirmed;
  final bool isOwnReport;
  final VoidCallback onConfirm;
  final String Function(String) formatDateTime;

  const _ReportCard({
    required this.report,
    required this.confirmCount,
    required this.isConfirmed,
    required this.isOwnReport,
    required this.onConfirm,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Column(
            children: [
              _buildHeaderSection(context, appLoc),
              _buildMainContentSection(context, appLoc),
              _buildFooterSection(context, appLoc),
            ],
          ),
        ),
      ),
    );
  }

  // Builds header section with user info and badges
  Widget _buildHeaderSection(BuildContext context, AppLocalizations appLoc) {
    final severity = report['SeverityLevel'];
    final status = report['Status'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.blueGrey[100]!, width: 1),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Centered user details (icon above name)
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF04274B),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report['UserName'] ?? appLoc.translate('Unknown'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF04274B),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (report['Timestamp'] != null &&
                    report['Timestamp'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      formatDateTime(report['Timestamp']),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (severity != null || status != null) const SizedBox(height: 12),
          // Centered badges row full width
          if (severity != null || status != null)
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (severity != null)
                    _buildStatusBadge(
                      severity,
                      _getSeverityColor(severity),
                      Icons.warning_amber_rounded,
                      appLoc,
                    ),
                  if (severity != null && status != null)
                    const SizedBox(width: 8),
                  if (status != null)
                    _buildStatusBadge(
                      status,
                      _getStatusColor(status),
                      Icons.info_outline_rounded,
                      appLoc,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Builds status/severity badge
  Widget _buildStatusBadge(
    String value,
    Color color,
    IconData icon,
    AppLocalizations appLoc,
  ) {
    final severityKey =
        value != null && ['Critical', 'Moderate', 'Small'].contains(value)
            ? value
            : null;
    final statusKey =
        value != null && ['In Progress', 'Resolved', 'Reported'].contains(value)
            ? value
            : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            appLoc.translate(severityKey ?? statusKey ?? value),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Builds main content section with image, location, and actions
  Widget _buildMainContentSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section (positioned first on the left)
          Container(
            width: 100,
            constraints: BoxConstraints(minHeight: 90, maxHeight: 118),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  report['ImageURL'] != null &&
                          report['ImageURL'].toString().isNotEmpty
                      ? Image.network(
                        'http://192.168.1.2${report['ImageURL']}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                      : _buildPlaceholderImage(),
            ),
          ),
          const SizedBox(width: 16),

          // Content Section
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Info
                    _buildInfoItem(
                      Icons.location_on_rounded,
                      '${report['Latitude']}, ${report['Longitude']}',
                    ),
                    const SizedBox(height: 8),

                    // Province Info
                    if (report['Province'] != null &&
                        report['Province'].toString().isNotEmpty)
                      _buildInfoItem(
                        Icons.map_rounded,
                        appLoc.translate(report['Province']),
                      ),
                    if (report['Province'] != null &&
                        report['Province'].toString().isNotEmpty)
                      const SizedBox(height: 8),

                    // Confirmation Count
                    if (confirmCount > 0)
                      _buildInfoItem(
                        Icons.thumb_up_alt_rounded,
                        '$confirmCount ${confirmCount == 1 ? appLoc.translate("Confirmation") : appLoc.translate("Confirmations")}',
                      ),
                    if (confirmCount > 0) const SizedBox(height: 8),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: appLoc.translate('Chat'),
                            color: Color(0xFF04274B),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ChatPage(
                                        reportId:
                                            report['ReportID'] is int
                                                ? report['ReportID']
                                                : int.parse(
                                                  report['ReportID'].toString(),
                                                ),
                                        baseApiUrl:
                                            'http://192.168.1.2/patchup_app/lib/api',
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildConfirmButton(context, appLoc)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Builds footer section with description
  Widget _buildFooterSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[25],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey[100]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_rounded,
            color: Colors.blueGrey[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              report['Description'] ?? appLoc.translate('No description'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder image for missing report images
  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.construction_rounded,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }

  // Info item row for location, province, etc.
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Action button for chat and confirm
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 36,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  // Confirm button logic and styling
  Widget _buildConfirmButton(BuildContext context, AppLocalizations appLoc) {
    Color btnBg;
    Color btnFg;

    if (isConfirmed) {
      btnBg = Colors.green[50]!;

      btnFg = Colors.green[700]!;
    } else if (confirmCount > 0) {
      btnBg = Colors.blue[50]!;

      btnFg = Colors.blue[700]!;
    } else {
      btnBg = Colors.grey[100]!;

      btnFg = Colors.grey[600]!;
    }

    return Container(
      height: 36,
      child: ElevatedButton.icon(
        icon: Icon(Icons.thumb_up_alt_rounded, size: 16),
        label: Text(
          appLoc.translate('Confirm'),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        onPressed:
            (isConfirmed)
                ? null
                : isOwnReport
                ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        appLoc.translate("You can't confirm your own report."),

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.red[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                : onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnBg,
          foregroundColor: btnFg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: btnBg,
          disabledForegroundColor: btnFg,
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  // Severity color mapping
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return Colors.red[600]!;
      case 'Moderate':
        return Colors.orange[600]!;
      case 'Small':
        return Colors.green[600]!;
      default:
        return Colors.orange[600]!;
    }
  }

  // Status color mapping
  Color _getStatusColor(String status) {
    final s = status.toString().toLowerCase().trim();
    if (s == 'resolved' || s == 'resolved.' || s == 'resolved!') {
      return Colors.green[600]!;
    } else if (s == 'in progress' || s == 'in progress...') {
      return Colors.orange[600]!;
    } else if (s == 'reported') {
      return Colors.blue[600]!;
    }
    return Colors.blue[600]!;
  }
}
