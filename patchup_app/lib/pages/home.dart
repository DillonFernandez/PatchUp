//
// HomePage: Displays welcome, statistics, recent reports, and handles pothole confirmation.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../chat/chat_page.dart';
import '../components/appbar.dart';
import '../localization/app_localizations.dart';
import 'report.dart';

// Fetches latest reports for home page
Future<List<Map<String, dynamic>>> fetchReports() async {
  final response = await http.get(
    Uri.parse(
      'http://192.168.1.2/patchup_app/lib/api/display_reports_home.php',
    ),
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

class HomePage extends StatefulWidget {
  final void Function()? goToReportTab;

  const HomePage({super.key, this.goToReportTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Fetches home statistics
  Future<Map<String, dynamic>> fetchHomeStats() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.2/patchup_app/lib/api/home_stats.php'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  bool get _isOffline =>
      !(WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);

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
    final theme = Theme.of(context);
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      appBar: const UserAppBar(),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Welcome section
                _buildWelcomeSection(context, appLoc),
                const SizedBox(height: 20),

                // Statistics section
                _buildStatisticsSection(context, appLoc),
                const SizedBox(height: 24),

                // Recent reports section
                _buildRecentReportsSection(context, appLoc),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // Builds welcome section with greeting and subtitle
  Widget _buildWelcomeSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF1F5F9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF04274B).withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Welcome Icon
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF04274B), Color(0xFF1e40af)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF04274B).withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),

            // Welcome Text
            Text(
              appLoc.translate("Welcome to PatchUp!"),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Color(0xFF04274B),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            Text(
              appLoc.translate("Home Subtitle"),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Builds statistics section with user, avg/day, resolved stats
  Widget _buildStatisticsSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
    return Column(
      children: [
        // Statistics Cards
        FutureBuilder<Map<String, dynamic>>(
          future: fetchHomeStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingStats();
            } else if (_isOffline) {
              return _buildOfflineMessage(appLoc);
            } else if (snapshot.hasError) {
              return _buildErrorMessage(appLoc);
            } else {
              final stats = snapshot.data!;
              return Container(
                padding: EdgeInsets.all(14),
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
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_rounded,
                        label: appLoc.translate("Users"),
                        value: stats['total_users'].toString(),
                        color: Color(0xFF3b82f6),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 45,
                      color: Colors.grey[200],
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up_rounded,
                        label: appLoc.translate("Avg/Day"),
                        value: stats['avg_reports_per_day'].toString(),
                        color: Color(0xFFf59e0b),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 45,
                      color: Colors.grey[200],
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_rounded,
                        label: appLoc.translate("Resolved"),
                        value: stats['potholes_resolved'].toString(),
                        color: Color(0xFF10b981),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  // Builds recent reports section with confirmation and chat actions
  Widget _buildRecentReportsSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
    return Column(
      children: [
        // Section Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  Icons.history_edu_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLoc.translate('Recent Reports'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Latest community submissions'),
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
        const SizedBox(height: 14),

        // Reports List
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingReports(appLoc);
            }
            if (_isOffline) {
              return _buildOfflineMessage(appLoc);
            }
            if (snapshot.hasError) {
              return _buildErrorMessage(appLoc);
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return _buildEmptyReports(appLoc);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              separatorBuilder: (_, __) => SizedBox(height: 5),
              itemBuilder: (context, index) {
                final report = reports[index];
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
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Loading state for statistics
  Widget _buildLoadingStats() {
    return Container(
      padding: EdgeInsets.all(14),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          3,
          (i) => Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Color(0xFF04274B),
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6),
              Container(
                width: 28,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Loading state for reports
  Widget _buildLoadingReports(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 28),
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
              appLoc.translate('Loading reports...'),
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

  // Offline message display
  Widget _buildOfflineMessage(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(18),
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

  // Error message display
  Widget _buildErrorMessage(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(18),
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
            appLoc.translate('An error occurred while loading data.'),
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

  // Empty reports message
  Widget _buildEmptyReports(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(20),
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
            appLoc.translate('Be the first to report a pothole!'),
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

  // Floating action button for reporting a pothole
  Widget _buildFloatingActionButton(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF04274B).withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportPage()),
          );
        },
        backgroundColor: Color(0xFF04274B),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.add_rounded, size: 20),
        label: Text(
          appLoc.translate('Report'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// Statistic card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.blueGrey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
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

  const _ReportCard({
    required this.report,
    required this.confirmCount,
    required this.isConfirmed,
    required this.isOwnReport,
    required this.onConfirm,
  });

  String _formatDateTime(String raw, AppLocalizations appLoc) {
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
    final ampm = hour >= 12 ? appLoc.translate('PM') : appLoc.translate('AM');
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return '$day$suffix $month - $hour:$minute $ampm';
  }

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
              // Header Section
              _buildHeaderSection(context, appLoc),

              // Main Content Section
              _buildMainContentSection(context, appLoc),

              // Footer Section
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
          // Full-width centered user details (icon above name)
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
                      _formatDateTime(report['Timestamp'], appLoc),
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
          // Full-width badges row (stretches even if few badges)
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
