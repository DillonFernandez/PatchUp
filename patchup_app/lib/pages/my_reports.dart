//
// Displays user's submitted pothole reports, heatmap visualization, filters, and report actions.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../chat/chat_page.dart';
import '../components/appbar.dart';
import '../localization/app_localizations.dart';

// Fetches heatmap points for the current user's reports
Future<List<WeightedLatLng>> fetchUserHeatmapPoints() async {
  final response = await http.post(
    Uri.parse('http://192.168.8.187/patchup_app/lib/api/heatmap_points.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'UserEmail': UserSession.email, 'mode': 'my_reports'}),
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

// Fetches reports submitted by the current user
Future<List<Map<String, dynamic>>> fetchUserReports() async {
  final response = await http.post(
    Uri.parse('http://192.168.8.187/patchup_app/lib/api/display_reports.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'UserEmail': UserSession.email}),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}

class MyReportsPage extends StatefulWidget {
  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

// Main state for MyReportsPage: manages filters, loading, and UI sections
class _MyReportsPageState extends State<MyReportsPage> {
  // Filter selections and options
  String? selectedStatus;
  String? selectedSeverity;
  String? selectedProvince;
  DateTimeRange? selectedDateRange;

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
    DateTime dt;
    try {
      dt = DateTime.parse(raw);
    } catch (_) {
      return raw;
    }
    final appLoc = AppLocalizations.of(context); // for translations
    String daySuffix(int d) {
      if (d >= 11 && d <= 13) return appLoc.translate('th');
      switch (d % 10) {
        case 1:
          return appLoc.translate('st');
        case 2:
          return appLoc.translate('nd');
        case 3:
          return appLoc.translate('rd');
        default:
          return appLoc.translate('th');
      }
    }

    final day = dt.day;
    final suffix = daySuffix(day);
    final monthName =
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
    final month = appLoc.translate(monthName);
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm =
        dt.hour >= 12 ? appLoc.translate('PM') : appLoc.translate('AM');
    return '$day$suffix $month ${dt.year} - $hour:$minute$ampm';
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLoc.translate('My Reports'),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF04274B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
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

  // Builds heatmap visualization section for user's reports
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
                child: Icon(Icons.map_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLoc.translate('My Reports Heatmap'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Your personal report distribution'),
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
                future: fetchUserHeatmapPoints(),
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

  // Builds filter controls section
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
                if (selectedStatus != null ||
                    selectedSeverity != null ||
                    selectedProvince != null ||
                    selectedDateRange != null)
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

  // Builds reports list section with actions and filtering
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
                      appLoc.translate('My Reports'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Your submitted reports'),
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
          future: fetchUserReports(),
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
                  if (selectedDateRange != null) {
                    if (!_isInSelectedRange(
                      report['Timestamp']?.toString() ?? '',
                    )) {
                      return false;
                    }
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
              separatorBuilder: (_, __) => SizedBox(height: 14),
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return _ReportCard(
                  report: report,
                  formatDateTime: _formatDateTime,
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Builds date range selector for filtering
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

  // Helper: checks if report is in selected date range
  bool _isInSelectedRange(String ts) {
    if (selectedDateRange == null) return true;
    if (ts.isEmpty) return true;
    DateTime reportDate;
    try {
      reportDate = DateTime.parse(ts);
    } catch (_) {
      return true;
    }
    final start = DateTime(
      selectedDateRange!.start.year,
      selectedDateRange!.start.month,
      selectedDateRange!.start.day,
    );
    final end = DateTime(
      selectedDateRange!.end.year,
      selectedDateRange!.end.month,
      selectedDateRange!.end.day,
      23,
      59,
      59,
      999,
    );
    return !(reportDate.isBefore(start) || reportDate.isAfter(end));
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

// Report card widget for displaying report details and chat button
class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final String Function(String) formatDateTime;

  const _ReportCard({required this.report, required this.formatDateTime});

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {}, // optional: open details
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context, appLoc),
              _buildContentSection(context, appLoc),
            ],
          ),
        ),
      ),
    );
  }

  // Builds image section with overlays (badges, user info)
  Widget _buildImageSection(BuildContext context, AppLocalizations appLoc) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          // Image / placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child:
                  report['ImageURL'] != null &&
                          report['ImageURL'].toString().isNotEmpty
                      ? Image.network(
                        'http://192.168.8.187${report['ImageURL']}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      )
                      : _buildImagePlaceholder(),
            ),
          ),
          // Bottom dark gradient
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.32)],
                stops: [0.6, 1.0],
              ),
            ),
          ),
          // Top badges
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopStatusBadges(appLoc),
                _buildValidationBadge(),
              ],
            ),
          ),
          // User + time
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: _buildUserInfo(appLoc),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF04274B).withOpacity(.10),
            Color(0xFF1e40af).withOpacity(.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.construction_rounded,
            color: Color(0xFF04274B),
            size: 32,
          ),
        ),
      ),
    );
  }

  // Builds badges, validation count, and user info overlays
  Widget _buildTopStatusBadges(AppLocalizations appLoc) {
    final severity = report['SeverityLevel'];
    final status = report['Status'];
    return Row(
      children: [
        if (severity != null)
          _buildModernBadge(
            severity,
            _getSeverityColor(severity),
            _getSeverityIcon(severity),
            appLoc,
          ),
        if (severity != null && status != null) SizedBox(width: 6),
        if (status != null)
          _buildModernBadge(
            status,
            _getStatusColor(status),
            _getStatusIcon(status),
            appLoc,
          ),
      ],
    );
  }

  Widget _buildValidationBadge() {
    final raw = report['ValidationCount'];
    final vc = (raw is int) ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;
    if (vc <= 0) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(.30),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '$vc',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(AppLocalizations appLoc) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.person_rounded, size: 16, color: Color(0xFF04274B)),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                report['UserName'] ?? appLoc.translate('Unknown'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(.55),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (report['Timestamp'] != null &&
                  report['Timestamp'].toString().isNotEmpty)
                Text(
                  formatDateTime(report['Timestamp']),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(.90),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(.55),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Builds location, description, and chat button section
  Widget _buildContentSection(BuildContext context, AppLocalizations appLoc) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationInfo(appLoc),
          SizedBox(height: 12),
          _buildDescription(appLoc),
          SizedBox(height: 14),
          _buildChatButton(context, appLoc),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${report['Latitude']}, ${report['Longitude']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (report['Province'] != null &&
              report['Province'].toString().isNotEmpty) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.map_rounded, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appLoc.translate(report['Province']),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription(AppLocalizations appLoc) {
    final desc = report['Description'] ?? appLoc.translate('No description');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description_rounded, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, AppLocalizations appLoc) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatPage(
                    reportId:
                        report['ReportID'] is int
                            ? report['ReportID']
                            : int.tryParse(report['ReportID'].toString()) ?? 0,
                    baseApiUrl: 'http://192.168.8.187/patchup_app/lib/api',
                  ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF04274B).withOpacity(.08),
          foregroundColor: Color(0xFF04274B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Color(0xFF04274B).withOpacity(.25),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 18),
            SizedBox(width: 8),
            Text(
              appLoc.translate('Chat'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Badge and icon helpers
  Widget _buildModernBadge(
    String value,
    Color color,
    IconData icon,
    AppLocalizations appLoc,
  ) {
    final severityKey =
        ['Critical', 'Moderate', 'Small'].contains(value) ? value : null;
    final statusKey =
        ['In Progress', 'Resolved', 'Reported'].contains(value) ? value : null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.90),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.30),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            appLoc.translate(severityKey ?? statusKey ?? value),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'Critical':
        return Icons.dangerous_rounded;
      case 'Moderate':
        return Icons.warning_amber_rounded;
      case 'Small':
        return Icons.info_outline_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase().trim();
    if (s.startsWith('resolved')) return Icons.check_circle_rounded;
    if (s.startsWith('in progress')) return Icons.schedule_rounded;
    if (s.startsWith('reported')) return Icons.report_rounded;
    return Icons.report_rounded;
  }

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

  Color _getStatusColor(String status) {
    final s = status.toLowerCase().trim();
    if (s.startsWith('resolved')) return Colors.green[600]!;
    if (s.startsWith('in progress')) return Colors.orange[600]!;
    if (s.startsWith('reported')) return Colors.blue[600]!;
    return Colors.blue[600]!;
  }
}
