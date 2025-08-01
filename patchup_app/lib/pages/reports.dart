import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../components/appbar.dart';

// --- Fetch Heatmap Points from Backend API ---
Future<List<WeightedLatLng>> fetchHeatmapPoints() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.100/patchup_app/lib/api/heatmap_points.php'),
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

// --- Fetch All Reports from Backend API ---
Future<List<Map<String, dynamic>>> fetchReports() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.100/patchup_app/lib/api/display_reports.php'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}

// --- Main Reports Page Widget ---
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

// --- State Class for ReportsPage ---
class _ReportsPageState extends State<ReportsPage> {
  String? selectedStatus;
  String? selectedSeverity;
  DateTimeRange? selectedDateRange;

  final List<String> statusOptions = [
    'All',
    'Resolved',
    'In Progress',
    'Reported',
  ];
  final List<String> severityOptions = ['All', 'Critical', 'Moderate', 'Small'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- Custom AppBar Section ---
      appBar: const UserAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Heatmap Section ---
              Container(
                margin: const EdgeInsets.only(bottom: 35),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FutureBuilder<List<WeightedLatLng>>(
                          future: fetchHeatmapPoints(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final points = snapshot.data ?? [];
                            if (points.isEmpty) {
                              return Center(
                                child: Text(
                                  'No Reports Found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
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
                                  userAgentPackageName:
                                      'com.example.patchup_app',
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
                      // --- Overlay Title for Heatmap ---
                      Positioned(
                        left: 18,
                        top: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                color: Color(0xFF04274B),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Heatmap Overview',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.3,
                                  color: Color(0xFF04274B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // --- Divider and Section Label for Reports List ---
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1.3,
                      color: Colors.grey[200],
                      endIndent: 14,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF04274B).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt_rounded,
                          color: Color(0xFF04274B),
                          size: 22,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF04274B),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1.3,
                      color: Colors.grey[200],
                      indent: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // --- Filter Controls Section ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blueGrey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Filter Reports",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF04274B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // --- Status Dropdown Filter ---
                            Expanded(
                              child: _ModernDropdown(
                                label: "Status",
                                value: selectedStatus ?? 'All',
                                items: statusOptions,
                                icon: Icons.flag_rounded,
                                onChanged: (val) {
                                  setState(() {
                                    selectedStatus = val == 'All' ? null : val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // --- Severity Dropdown Filter ---
                            Expanded(
                              child: _ModernDropdown(
                                label: "Severity",
                                value: selectedSeverity ?? 'All',
                                items: severityOptions,
                                icon: Icons.warning_amber_rounded,
                                onChanged: (val) {
                                  setState(() {
                                    selectedSeverity =
                                        val == 'All' ? null : val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // --- Date Range Filter and Clear Button ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex:
                                  (selectedStatus != null ||
                                              selectedSeverity != null ||
                                              selectedDateRange != null) &&
                                          (selectedStatus != null ||
                                              selectedSeverity != null)
                                      ? 7
                                      : 10,
                              child: GestureDetector(
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
                                child: Container(
                                  height: 48,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Color(
                                        0xFF04274B,
                                      ).withOpacity(0.18),
                                      width: 1.2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        color: Color(0xFF04274B),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedDateRange == null
                                              ? 'Date Range'
                                              : '${selectedDateRange!.start.year}/${selectedDateRange!.start.month.toString().padLeft(2, '0')}/${selectedDateRange!.start.day.toString().padLeft(2, '0')} - ${selectedDateRange!.end.year}/${selectedDateRange!.end.month.toString().padLeft(2, '0')}/${selectedDateRange!.end.day.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: Color(0xFF04274B),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (selectedDateRange != null)
                                        IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.red[400],
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedDateRange = null;
                                            });
                                          },
                                          splashRadius: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // --- Clear All Filters Button ---
                            if ((selectedStatus != null ||
                                    selectedSeverity != null) &&
                                (selectedStatus != null ||
                                    selectedSeverity != null ||
                                    selectedDateRange != null))
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.clear, size: 18),
                                    label: Text('Clear'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red[700],
                                      side: BorderSide(
                                        color: Colors.red[200]!,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 0,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedStatus = null;
                                        selectedSeverity = null;
                                        selectedDateRange = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // --- Reports List with Filtering Logic Applied ---
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final reports = snapshot.data ?? [];
                  final filteredReports =
                      reports.where((report) {
                        // Status filter logic
                        if (selectedStatus != null &&
                            (report['Status'] == null ||
                                (report['Status'] as String).toLowerCase() !=
                                    selectedStatus!.toLowerCase())) {
                          return false;
                        }
                        // Severity filter logic
                        if (selectedSeverity != null &&
                            (report['SeverityLevel'] == null ||
                                (report['SeverityLevel'] as String)
                                        .toLowerCase() !=
                                    selectedSeverity!.toLowerCase())) {
                          return false;
                        }
                        // Date range filter logic
                        if (selectedDateRange != null &&
                            report['Timestamp'] != null &&
                            report['Timestamp'].toString().isNotEmpty) {
                          try {
                            final reportDate = DateTime.parse(
                              report['Timestamp'],
                            );
                            if (reportDate.isBefore(selectedDateRange!.start) ||
                                reportDate.isAfter(selectedDateRange!.end)) {
                              return false;
                            }
                          } catch (_) {
                            // Ignore parse errors, show the report
                          }
                        }
                        return true;
                      }).toList();

                  if (filteredReports.isEmpty) {
                    return Center(child: Text('No reports found.'));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredReports.length,
                    separatorBuilder: (_, __) => SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.blueGrey[50]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 16,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // --- Row for Severity and Status Indicators ---
                                    Row(
                                      children: [
                                        if (report['SeverityLevel'] != null)
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 5,
                                              ),
                                              margin: EdgeInsets.only(
                                                right:
                                                    report['Status'] != null
                                                        ? 8
                                                        : 0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: () {
                                                  switch (report['SeverityLevel']) {
                                                    case 'Critical':
                                                      return Colors.red[100];
                                                    case 'Moderate':
                                                      return Colors.yellow[100];
                                                    case 'Small':
                                                      return Colors.green[100];
                                                    default:
                                                      return Colors.grey[200];
                                                  }
                                                }(),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: () {
                                                      switch (report['SeverityLevel']) {
                                                        case 'Critical':
                                                          return Colors.red;
                                                        case 'Moderate':
                                                          return Colors
                                                              .orange[700];
                                                        case 'Small':
                                                          return Colors.green;
                                                        default:
                                                          return Colors
                                                              .orange[700];
                                                      }
                                                    }(),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${report['SeverityLevel']}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: () {
                                                        switch (report['SeverityLevel']) {
                                                          case 'Critical':
                                                            return Colors
                                                                .red[900];
                                                          case 'Moderate':
                                                            return Colors
                                                                .orange[900];
                                                          case 'Small':
                                                            return Colors
                                                                .green[900];
                                                          default:
                                                            return Colors.black;
                                                        }
                                                      }(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (report['Status'] != null)
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: () {
                                                  final status =
                                                      (report['Status'] ?? '')
                                                          .toString()
                                                          .toLowerCase()
                                                          .trim();
                                                  if (status == 'resolved' ||
                                                      status == 'resolved.' ||
                                                      status == 'resolved!') {
                                                    return Colors.green[100];
                                                  } else if (status ==
                                                          'in progress' ||
                                                      status ==
                                                          'in progress...') {
                                                    return Colors.yellow[100];
                                                  }
                                                  return Colors.blue[50];
                                                }(),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    color: () {
                                                      final status =
                                                          (report['Status'] ??
                                                                  '')
                                                              .toString()
                                                              .toLowerCase()
                                                              .trim();
                                                      if (status ==
                                                              'resolved' ||
                                                          status ==
                                                              'resolved.' ||
                                                          status ==
                                                              'resolved!') {
                                                        return Colors
                                                            .green[700];
                                                      } else if (status ==
                                                              'in progress' ||
                                                          status ==
                                                              'in progress...') {
                                                        return Colors
                                                            .orange[700];
                                                      }
                                                      return Colors.blue[700];
                                                    }(),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${report['Status']}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: () {
                                                        final status =
                                                            (report['Status'] ??
                                                                    '')
                                                                .toString()
                                                                .toLowerCase()
                                                                .trim();
                                                        if (status ==
                                                                'resolved' ||
                                                            status ==
                                                                'resolved.' ||
                                                            status ==
                                                                'resolved!') {
                                                          return Colors
                                                              .green[900];
                                                        } else if (status ==
                                                                'in progress' ||
                                                            status ==
                                                                'in progress...') {
                                                          return Colors
                                                              .orange[900];
                                                        }
                                                        return Colors.black;
                                                      }(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // --- Row for Image and Report Details ---
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // --- Report Image Display ---
                                        Container(
                                          width: 90,
                                          height: 90,
                                          child:
                                              report['ImageURL'] != null &&
                                                      report['ImageURL']
                                                          .toString()
                                                          .isNotEmpty
                                                  ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: Image.network(
                                                      'http://192.168.1.100${report['ImageURL']}',
                                                      width: 90,
                                                      height: 90,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) => Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 36,
                                                            color:
                                                                Colors
                                                                    .blueGrey[200],
                                                          ),
                                                    ),
                                                  )
                                                  : Center(
                                                    child: Icon(
                                                      Icons.warning,
                                                      color: Colors.redAccent,
                                                      size: 36,
                                                    ),
                                                  ),
                                        ),
                                        const SizedBox(width: 22),
                                        // --- Report Details Section ---
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // --- Location Row ---
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    color: Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                    size: 19,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Flexible(
                                                    child: Text(
                                                      '${report['Latitude']}, ${report['Longitude']}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 7),
                                              // --- Zip Code Row ---
                                              if (report['ZipCode'] != null &&
                                                  report['ZipCode']
                                                      .toString()
                                                      .isNotEmpty)
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.local_post_office,
                                                      size: 16,
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      report['ZipCode'],
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              // --- Timestamp Row ---
                                              if (report['Timestamp'] != null &&
                                                  report['Timestamp']
                                                      .toString()
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 7,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time,
                                                        size: 16,
                                                        color:
                                                            const Color.fromARGB(
                                                              255,
                                                              0,
                                                              0,
                                                              0,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        report['Timestamp'],
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // --- User Row ---
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 7,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person,
                                                      size: 16,
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      '${report['UserName'] ?? 'Unknown'}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // --- Description Section ---
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[50],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        report['Description'] ??
                                            'No description',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                          color: Colors.black,
                                          height: 1.35,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Custom Dropdown Widget for Modern Filter Controls ---
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
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xFF04274B),
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        filled: true,
        fillColor: Colors.blueGrey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color(0xFF04274B).withOpacity(0.18),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color(0xFF04274B).withOpacity(0.18),
            width: 1.2,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(icon, color: Color(0xFF04274B), size: 20),
          items:
              items
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: TextStyle(
                          color: Color(0xFF04274B),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
