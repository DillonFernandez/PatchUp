//
// MyBadgesPage: Displays user's earned badges, loading/error states, and badge details.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_localizations.dart';

// Gets logged-in user ID from preferences and backend
Future<int?> getLoggedInUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('user_email');
  if (email == null || email.isEmpty) return null;
  final response = await http.post(
    Uri.parse('http://192.168.1.2/patchup_app/lib/api/get_user_info.php'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'Email': email}),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['user_id'];
  }
  return null;
}

class MyBadgesPage extends StatefulWidget {
  @override
  _MyBadgesPageState createState() => _MyBadgesPageState();
}

class _MyBadgesPageState extends State<MyBadgesPage> {
  Future<List<dynamic>>? _badgesFuture;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  // Loads badges for the current user
  void _loadBadges() async {
    final userId = await getLoggedInUserId();
    if (userId != null) {
      setState(() {
        _badgesFuture = fetchUserBadges(userId);
      });
    } else {
      setState(() {
        _badgesFuture = Future.value([]);
      });
    }
  }

  // Fetches badges from backend
  Future<List<dynamic>> fetchUserBadges(int userId) async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.1.2/patchup_app/lib/api/get_user_badges.php?user_id=$userId',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['badges'] ?? [];
    } else {
      throw Exception('Failed to load badges');
    }
  }

  bool get _isOffline => false;

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('My Badges AppBar Title'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero section
            _buildHeroSection(context, appLoc),
            const SizedBox(height: 24),

            // Badges content (loading/error/empty/grid)
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _badgesFuture,
                builder: (context, snapshot) {
                  if (_isOffline) {
                    return _buildOfflineState(appLoc);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState(appLoc);
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(appLoc);
                  }
                  final badges = snapshot.data ?? [];
                  if (badges.isEmpty) {
                    return _buildEmptyState(appLoc);
                  }
                  return _buildBadgesGrid(badges, appLoc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds hero section with icon and subtitle
  Widget _buildHeroSection(BuildContext context, AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF1F5F9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF04274B).withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              appLoc.translate('Achievement Center'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF04274B),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              appLoc.translate('Your earned badges and accomplishments'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Builds loading state UI
  Widget _buildLoadingState(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF04274B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Color(0xFF04274B),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              appLoc.translate('Loading your badges...'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds offline state UI
  Widget _buildOfflineState(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Colors.orange[600],
              ),
            ),
            SizedBox(height: 20),
            Text(
              appLoc.translate("You're Offline"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF04274B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              appLoc.translate(
                'Currently offline. Will sync when back online.',
              ),
              style: TextStyle(
                fontSize: 15,
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Builds error state UI
  Widget _buildErrorState(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[600],
              ),
            ),
            SizedBox(height: 20),
            Text(
              appLoc.translate('Something went wrong'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF04274B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              appLoc.translate('An error occurred while loading your badges.'),
              style: TextStyle(
                fontSize: 15,
                color: Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Builds empty state UI
  Widget _buildEmptyState(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFD700).withOpacity(0.1),
                    Color(0xFFFFA500).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Color(0xFFFFD700).withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20),
            Text(
              appLoc.translate('No Badges Yet'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF04274B),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              appLoc.translate('No badges earned yet.'),
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              appLoc.translate(
                'Start reporting potholes to earn your first badge!',
              ),
              style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey[500],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Builds grid of badge cards
  Widget _buildBadgesGrid(List<dynamic> badges, AppLocalizations appLoc) {
    return GridView.builder(
      itemCount: badges.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(badge, appLoc);
      },
    );
  }

  // Builds individual badge card
  Widget _buildBadgeCard(Map<String, dynamic> badge, AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF1F5F9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Could add badge details modal here
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Icon/Image
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      badge['ImagePath'] != null &&
                              badge['ImagePath'].toString().isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              'http://192.168.1.2${badge['ImagePath']}',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    Icons.emoji_events_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.emoji_events_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                ),
                SizedBox(height: 12),

                // Badge Name
                Text(
                  badge['BadgeName'] ?? appLoc.translate('Unknown Badge'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF04274B),
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),

                // Badge Description
                Text(
                  badge['Description'] ??
                      appLoc.translate('No description available'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),

                // Earned Date
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${appLoc.translate('Earned')}: ${badge['EarnedAt']?.substring(0, 10) ?? appLoc.translate('Unknown')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF04274B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
