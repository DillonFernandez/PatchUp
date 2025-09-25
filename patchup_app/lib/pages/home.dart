//
// HomePage: Displays welcome, statistics, recent reports, and handles pothole confirmation.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/appbar.dart';
import '../localization/app_localizations.dart';

// Fetches latest reports for home page
Future<List<Map<String, dynamic>>> fetchReports() async {
  final response = await http.get(
    Uri.parse(
      'http://192.168.8.187/patchup_app/lib/api/display_reports_home.php',
    ),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}

class HomePage extends StatefulWidget {
  final void Function()? goToReportTab;

  const HomePage({super.key, this.goToReportTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Fetches home statistics
  Future<Map<String, dynamic>> fetchHomeStats() async {
    final response = await http.get(
      Uri.parse('http://192.168.8.187/patchup_app/lib/api/home_stats.php'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  bool get _isOffline =>
      !(WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);

  @override
  Widget build(BuildContext context) {
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
    );
  }

  /// Builds welcome section with greeting and subtitle
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

  /// Builds statistics section with user, avg/day, resolved stats
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

  /// Builds recent reports section with confirmation and chat actions
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

                return _ReportCard(report: report);
              },
            );
          },
        ),
      ],
    );
  }

  /// Loading state for statistics
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

  /// Loading state for reports
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

  /// Offline message display
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

  /// Error message display
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

  /// Empty reports message
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

  const _ReportCard({required this.report});

  String _formatDateTime(String raw, AppLocalizations appLoc) {
    DateTime dt;
    try {
      dt = DateTime.parse(raw);
    } catch (_) {
      return raw;
    }

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
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Handle report tap
          },
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

  Widget _buildImageSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          // Main Image
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child:
                  report['ImageURL'] != null &&
                          report['ImageURL'].toString().isNotEmpty
                      ? Image.network(
                        'http://192.168.8.187${report['ImageURL']}',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => _buildImagePlaceholder(appLoc),
                      )
                      : _buildImagePlaceholder(appLoc),
            ),
          ),

          // Gradient Overlay
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                stops: [0.6, 1.0],
              ),
            ),
          ),

          // Top Status Badges
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopStatusBadges(appLoc),
                _buildValidationBadge(appLoc),
              ],
            ),
          ),

          // Bottom User Info
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

  Widget _buildImagePlaceholder(AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF04274B).withOpacity(0.1),
            Color(0xFF1e40af).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
            SizedBox(height: 8),
            Text(
              appLoc.translate('No Image'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildValidationBadge(AppLocalizations appLoc) {
    final vcRaw = report['ValidationCount'];
    final int vc =
        (vcRaw is int) ? vcRaw : int.tryParse(vcRaw?.toString() ?? '') ?? 0;

    if (vc <= 0) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.person_rounded, color: Color(0xFF04274B), size: 16),
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
                      color: Colors.black.withOpacity(0.5),
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
                  _formatDateTime(report['Timestamp'], appLoc),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context, AppLocalizations appLoc) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationInfo(appLoc),
          SizedBox(height: 12),
          _buildDescription(appLoc),
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
    final description =
        report['Description'] ?? appLoc.translate('No description');

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
          Icon(Icons.description_rounded, color: Colors.grey[600], size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
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
}

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
      color: color.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
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
  final s = status.toString().toLowerCase().trim();
  if (s == 'resolved' || s == 'resolved.' || s == 'resolved!') {
    return Icons.check_circle_rounded;
  } else if (s == 'in progress' || s == 'in progress...') {
    return Icons.schedule_rounded;
  } else if (s == 'reported') {
    return Icons.report_rounded;
  }
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
