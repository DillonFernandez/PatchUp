//
// ReportPage: Allows users to submit pothole reports with image, location, severity, and description.
// Handles offline saving and syncing when online.
//

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../components/appbar.dart';
import '../localization/app_localizations.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Form fields and state
  String? selectedDangerLevel;
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;
  late final Connectivity _connectivity;
  bool _isSyncing = false;
  final Uuid _uuid = Uuid();

  // Province dropdown options
  String? selectedProvince;
  final List<String> provinceOptions = [
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

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      setState(() {
        _connectivityStatus = result;
      });
      if (_isOnline(result)) {
        _syncOfflineReports();
      }
    });
  }

  // Initializes connectivity and syncs offline reports if online
  Future<void> _initConnectivity() async {
    final statuses = await _connectivity.checkConnectivity();
    final status =
        statuses.isNotEmpty ? statuses.first : ConnectivityResult.none;
    setState(() {
      _connectivityStatus = status;
    });
    if (_isOnline(status)) {
      _syncOfflineReports();
    }
  }

  // Checks if device is online
  bool _isOnline(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  // Gets list of synced report IDs from preferences
  Future<Set<String>> _getSyncedReportIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('synced_report_ids') ?? []).toSet();
  }

  // Adds a report ID to the synced list
  Future<void> _addSyncedReportId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('synced_report_ids') ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList('synced_report_ids', ids);
    }
  }

  // Saves a report locally for offline sync
  Future<void> _saveReportOffline(Map<String, dynamic> report) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reports = prefs.getStringList('offline_reports') ?? [];
    reports.add(jsonEncode(report));
    await prefs.setStringList('offline_reports', reports);
  }

  // Gets offline reports, optionally excluding synced ones
  Future<List<Map<String, dynamic>>> _getOfflineReports({
    bool excludeSynced = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reports = prefs.getStringList('offline_reports') ?? [];
    final syncedIds = excludeSynced ? await _getSyncedReportIds() : <String>{};
    return reports
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .where((r) => !excludeSynced || !syncedIds.contains(r['id']))
        .toList();
  }

  // Removes synced reports from offline storage
  Future<void> _removeSyncedReportsFromOffline() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reports = prefs.getStringList('offline_reports') ?? [];
    final syncedIds = await _getSyncedReportIds();
    final unsyncedReports =
        reports
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .where((r) => !syncedIds.contains(r['id']))
            .map((r) => jsonEncode(r))
            .toList();
    await prefs.setStringList('offline_reports', unsyncedReports);
  }

  // Syncs offline reports to backend when online
  Future<void> _syncOfflineReports() async {
    if (_isSyncing) return;
    _isSyncing = true;
    final reports = await _getOfflineReports();
    if (reports.isEmpty) {
      _isSyncing = false;
      return;
    }
    final syncedIds = await _getSyncedReportIds();
    for (final report in reports) {
      final reportId = report['id'] as String? ?? '';
      if (reportId.isEmpty || syncedIds.contains(reportId)) continue;
      final success = await _uploadLocationToDB(
        province: report['Province'],
        lat: report['Latitude'],
        lng: report['Longitude'],
        desc: report['Description'],
        severity: report['SeverityLevel'],
        imagePath: report['ImagePath'],
        userEmail: report['UserEmail'],
      );
      if (success) {
        await _addSyncedReportId(reportId);
      }
    }
    await _removeSyncedReportsFromOffline();
    _isSyncing = false;
    if (mounted) {
      final appLoc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLoc.translate('Offline reports synced successfully!'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Uploads a single report to backend API
  Future<bool> _uploadLocationToDB({
    required String province,
    required String lat,
    required String lng,
    required String desc,
    required String severity,
    required String imagePath,
    required String userEmail,
  }) async {
    final uri = Uri.parse(
      'http://192.168.1.2/patchup_app/lib/api/pothole_report.php',
    );
    var request = http.MultipartRequest('POST', uri);
    request.fields['Province'] = province;
    request.fields['Latitude'] = lat;
    request.fields['Longitude'] = lng;
    request.fields['Description'] = desc;
    request.fields['SeverityLevel'] = severity;
    request.fields['UserEmail'] = userEmail;
    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('Image', imagePath));
    }
    try {
      final response = await request.send();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _longitudeController.dispose();
    _latitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Maps district/administrative area to province
  String? _mapDistrictToProvince(String? district, String? adminArea) {
    // You may want to expand this mapping for more accuracy
    final lower = (district ?? adminArea ?? '').toLowerCase();
    if (lower.contains('colombo') ||
        lower.contains('gampaha') ||
        lower.contains('kalutara')) {
      return 'Western Province';
    }
    if (lower.contains('kandy') ||
        lower.contains('matale') ||
        lower.contains('nuwara eliya')) {
      return 'Central Province';
    }
    if (lower.contains('galle') ||
        lower.contains('matara') ||
        lower.contains('hambantota')) {
      return 'Southern Province';
    }
    if (lower.contains('jaffna') ||
        lower.contains('kilinochchi') ||
        lower.contains('mannar') ||
        lower.contains('mullaitivu') ||
        lower.contains('vavuniya')) {
      return 'Northern Province';
    }
    if (lower.contains('trincomalee') ||
        lower.contains('batticaloa') ||
        lower.contains('ampara')) {
      return 'Eastern Province';
    }
    if (lower.contains('kurunegala') || lower.contains('puttalam')) {
      return 'North Western Province';
    }
    if (lower.contains('anuradhapura') || lower.contains('polonnaruwa')) {
      return 'North Central Province';
    }
    if (lower.contains('badulla') || lower.contains('monaragala')) {
      return 'Uva Province';
    }
    if (lower.contains('ratnapura') || lower.contains('kegalle')) {
      return 'Sabaragamuwa Province';
    }
    return null;
  }

  // Refreshes location using geolocator and updates fields and province
  Future<void> _refreshLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _longitudeController.text = position.longitude.toString();
      _latitudeController.text = position.latitude.toString();

      // Reverse geocode to get province
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String? province;
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        province = _mapDistrictToProvince(
          placemark.subAdministrativeArea,
          placemark.administrativeArea,
        );
        // If not found, try locality as fallback
        province ??= _mapDistrictToProvince(
          placemark.locality,
          placemark.administrativeArea,
        );
      }
      setState(() {
        selectedProvince = province;
      });
    } catch (e) {
      // If geocoding fails, do not change province
    }
    setState(() {});
  }

  // Picks image from camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Picks image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Shows thank you dialog after successful submission
  Future<void> _showThankYouDialog(BuildContext context) async {
    final appLoc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.2),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLoc.translate("Thank You!"),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: const Color(0xFF04274B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                appLoc.translate("Thank You Message"),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04274B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _longitudeController.clear();
                  _latitudeController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _selectedImage = null;
                    selectedDangerLevel = null;
                    selectedProvince = null;
                  });
                },
                child: Text(
                  appLoc.translate("Close"),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
    );
  }

  // Shows error dialog for incomplete fields or errors
  Future<void> _showErrorDialog(BuildContext context, String message) async {
    final appLoc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.2),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLoc.translate("Incomplete Fields"),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: const Color(0xFF04274B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04274B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  appLoc.translate("Close"),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
    );
  }

  // Shows offline dialog when report is saved locally
  Future<void> _showOfflineDialog(BuildContext context) async {
    final appLoc = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.2),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.orange[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLoc.translate("Report Saved Offline"),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: const Color(0xFF04274B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                appLoc.translate("Report Saved Offline Message"),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04274B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _longitudeController.clear();
                  _latitudeController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _selectedImage = null;
                    selectedDangerLevel = null;
                    selectedProvince = null;
                  });
                },
                child: Text(
                  appLoc.translate("Close"),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
    );
  }

  // Increments user points by 5 (offline mode)
  Future<void> _incrementUserPointsOffline(String userEmail) async {
    final uri = Uri.parse(
      'http://192.168.1.2/patchup_app/lib/api/increment_points.php',
    );
    try {
      await http.post(uri, body: {'UserEmail': userEmail, 'Points': '5'});
    } catch (_) {
      // Ignore errors in offline mode
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF04274B),
          selectionColor: const Color(0xFF04274B).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF04274B),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: LayoutBuilder(
            builder:
                (_, __) => Text(
                  appLoc.translate('Report a Pothole'),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
          ),
          backgroundColor: const Color(0xFF04274B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            // Show offline icon if not online
            if (!_isOnline(_connectivityStatus))
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.cloud_off,
                  color: Colors.redAccent,
                  size: 28,
                  semanticLabel: appLoc.translate('Offline'),
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header section
                _buildHeaderSection(context, appLoc),
                const SizedBox(height: 24),

                // Image upload section
                _buildImageSection(context, appLoc),
                const SizedBox(height: 20),

                // Location section
                _buildLocationSection(context, appLoc),
                const SizedBox(height: 20),

                // Description section
                _buildDescriptionSection(context, appLoc),
                const SizedBox(height: 20),

                // Severity section
                _buildSeveritySection(context, appLoc),
                const SizedBox(height: 24),

                // Submit button
                _buildSubmitButton(context, appLoc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds header section with icon and subtitle
  Widget _buildHeaderSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF04274B).withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF04274B), Color(0xFF1e40af)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF04274B).withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.construction_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(height: 16),
          Text(
            appLoc.translate("Help us keep roads safe & smooth"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF04274B),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            appLoc.translate('Your report helps the community'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds image upload section
  Widget _buildImageSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF04274B),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  appLoc.translate('Photo Evidence'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF04274B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child:
                  _selectedImage == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 40,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            appLoc.translate('Add a photo of the pothole'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    onPressed: _pickImageFromCamera,
                    icon: Icons.camera_alt_rounded,
                    label: appLoc.translate('Take Photo'),
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    onPressed: _pickImageFromGallery,
                    icon: Icons.photo_library_rounded,
                    label: appLoc.translate('Upload'),
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds location section
  Widget _buildLocationSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF04274B),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLoc.translate('Location'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF04274B),
                    ),
                  ),
                ),
                _buildActionButton(
                  onPressed: _refreshLocation,
                  icon: Icons.my_location_rounded,
                  label: appLoc.translate('Get Location'),
                  isPrimary: true,
                  isCompact: true,
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildLocationField(
              label: appLoc.translate('Province'),
              controller: TextEditingController(
                text:
                    selectedProvince == null
                        ? ''
                        : appLoc.translate(selectedProvince!),
              ),
              icon: Icons.map_rounded,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLocationField(
                    label: appLoc.translate('Latitude'),
                    controller: _latitudeController,
                    icon: Icons.gps_fixed_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildLocationField(
                    label: appLoc.translate('Longitude'),
                    controller: _longitudeController,
                    icon: Icons.gps_not_fixed_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds description section
  Widget _buildDescriptionSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: Color(0xFF04274B),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  appLoc.translate('Description'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF04274B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              cursorColor: const Color(0xFF04274B),
              decoration: InputDecoration(
                hintText: appLoc.translate('Description Hint'),
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                contentPadding: EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF04274B), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Builds severity section
  Widget _buildSeveritySection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF04274B),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  appLoc.translate('Severity Level'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF04274B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // CHANGED: two buttons first row, one button second row
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DangerLevelButton(
                        label: 'Small',
                        color: Colors.green,
                        selected: selectedDangerLevel == 'Small',
                        onTap: () {
                          setState(() => selectedDangerLevel = 'Small');
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _DangerLevelButton(
                        label: 'Moderate',
                        color: Colors.amber,
                        selected: selectedDangerLevel == 'Moderate',
                        onTap: () {
                          setState(() => selectedDangerLevel = 'Moderate');
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DangerLevelButton(
                        label: 'Critical',
                        color: Colors.red,
                        selected: selectedDangerLevel == 'Critical',
                        onTap: () {
                          setState(() => selectedDangerLevel = 'Critical');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds submit button for report
  Widget _buildSubmitButton(BuildContext context, AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF04274B).withOpacity(0.2),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          final lat = _latitudeController.text.trim();
          final lng = _longitudeController.text.trim();
          final desc = _descriptionController.text.trim();
          final severity = selectedDangerLevel ?? '';
          final province = selectedProvince ?? '';
          if (province.isEmpty ||
              lat.isEmpty ||
              lng.isEmpty ||
              desc.isEmpty ||
              severity.isEmpty ||
              _selectedImage == null) {
            await _showErrorDialog(
              context,
              appLoc.translate("Incomplete Fields Message"),
            );
            return;
          }
          final userEmail = UserSession.email;
          final imagePath = _selectedImage!.path;
          final reportId = _uuid.v4();
          final report = {
            'id': reportId,
            'Province': province,
            'Latitude': lat,
            'Longitude': lng,
            'Description': desc,
            'SeverityLevel': severity,
            'ImagePath': imagePath,
            'UserEmail': userEmail,
          };
          final syncedIds = await _getSyncedReportIds();
          if (syncedIds.contains(reportId)) {
            await _showErrorDialog(
              context,
              appLoc.translate("This report has already been submitted."),
            );
            return;
          }
          if (_isOnline(_connectivityStatus)) {
            final success = await _uploadLocationToDB(
              province: province,
              lat: lat,
              lng: lng,
              desc: desc,
              severity: severity,
              imagePath: imagePath,
              userEmail: userEmail,
            );
            if (success) {
              await _addSyncedReportId(reportId);
              await _showThankYouDialog(context);
            } else {
              // Save offline if failed
              await _saveReportOffline(report);
              await _showOfflineDialog(context);
            }
          } else {
            // Save report locally for later sync
            await _saveReportOffline(report);
            await _incrementUserPointsOffline(userEmail);
            await _showOfflineDialog(context);
          }
        },
        icon: Icon(Icons.send_rounded, color: Colors.white, size: 22),
        label: Text(
          appLoc.translate('Submit Report'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF04274B),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Action button builder
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isCompact = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: isCompact ? 16 : 20,
        color: isPrimary ? Colors.white : Color(0xFF04274B),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isPrimary ? Colors.white : Color(0xFF04274B),
          fontWeight: FontWeight.w600,
          fontSize: isCompact ? 13 : 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Color(0xFF04274B) : Colors.grey[100],
        foregroundColor: isPrimary ? Colors.white : Color(0xFF04274B),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Location field builder
  Widget _buildLocationField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: false,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Widget for selecting severity/danger level
class _DangerLevelButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _DangerLevelButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 60,
        decoration: BoxDecoration(
          gradient:
              selected
                  ? LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  )
                  : null,
          color: selected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: selected ? color : Colors.grey[500],
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              appLoc.translate(label),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.grey[600],
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
