//
// LeaderBoardPage: Displays top contributors, rankings, user position, and badge details.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/appbar.dart';
import '../localization/app_localizations.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  // Leaderboard state
  List<dynamic> leaderboard = [];
  bool loading = true;
  bool _hasError = false;
  int? userRank;
  Map<String, dynamic>? userEntry;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  // Fetches leaderboard data from backend
  Future<void> fetchLeaderboard() async {
    try {
      final email = UserSession.email;
      final response = await http.post(
        Uri.parse('http://192.168.1.2/patchup_app/lib/api/leaderboard.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lb = data['leaderboard'] as List<dynamic>;
        setState(() {
          leaderboard = lb;
          loading = false;
          _hasError = false;
          userRank = data['user_position'];
          userEntry = {
            'name': data['user_name'] ?? '',
            'points': data['user_points'] ?? 0,
          };
        });
      } else {
        setState(() {
          loading = false;
          _hasError = true;
        });
      }
    } catch (_) {
      setState(() {
        loading = false;
        _hasError = true;
      });
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
      body:
          loading
              ? _buildLoadingState(appLoc)
              : _isOffline
              ? _buildOfflineState(appLoc)
              : _hasError
              ? _buildErrorState(appLoc)
              : leaderboard.isEmpty
              ? _buildEmptyState(appLoc)
              : _buildLeaderboardContent(appLoc),
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
              appLoc.translate('Loading leaderboard...'),
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
              appLoc.translate(
                'An error occurred while loading the leaderboard.',
              ),
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

  // Builds empty leaderboard UI
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
                Icons.leaderboard_outlined,
                size: 64,
                color: Color(0xFFFFD700).withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20),
            Text(
              appLoc.translate('No Data Available'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF04274B),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              appLoc.translate('No leaderboard data available.'),
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Builds main leaderboard content UI
  Widget _buildLeaderboardContent(AppLocalizations appLoc) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(appLoc),
            const SizedBox(height: 24),

            // Top 3 Podium
            _buildTopThreePodium(appLoc),
            const SizedBox(height: 24),

            // Remaining Rankings
            if (leaderboard.length > 3) _buildRemainingRankings(appLoc),
            if (leaderboard.length > 3) const SizedBox(height: 24),

            // Your Position
            _buildYourPosition(appLoc),
          ],
        ),
      ),
    );
  }

  // Builds hero section with leaderboard icon and subtitle
  Widget _buildHeroSection(AppLocalizations appLoc) {
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
                Icons.leaderboard_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              appLoc.translate('Leaderboard'),
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
              appLoc.translate('Top contributors and your ranking'),
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

  // Builds top 3 podium display
  Widget _buildTopThreePodium(AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFD700).withOpacity(0.2),
                        Colors.amber.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLoc.translate('Top Users'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF04274B),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Podium Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPodiumPositions(appLoc),
            ),
          ],
        ),
      ),
    );
  }

  // Builds podium positions for top 3 users
  List<Widget> _buildPodiumPositions(AppLocalizations appLoc) {
    final topCount = leaderboard.length >= 3 ? 3 : leaderboard.length;
    if (topCount == 0) return [SizedBox.shrink()];

    List<int> order = [];
    if (topCount == 1) {
      order = [0];
    } else if (topCount == 2) {
      order = [1, 0];
    } else {
      order = [1, 0, 2];
    }

    final rankColors = [
      Color(0xFFFFD700),
      Color(0xFFC0C0C0),
      Color(0xFFCD7F32),
    ];

    return order.map((i) {
      final entry = leaderboard[i];
      final isFirst = (i == 0);
      final badges = entry['badges'] as List<dynamic>? ?? [];

      return Expanded(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: isFirst ? 0 : 20),

            // Crown for first place
            if (isFirst)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFD700),
                  size: 32,
                ),
              ),

            // Rank Circle
            Container(
              width: isFirst ? 70 : 60,
              height: isFirst ? 70 : 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rankColors[i], rankColors[i].withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rankColors[i].withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: isFirst ? 28 : 24,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

            // Name
            Text(
              entry['name'],
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isFirst ? 16 : 14,
                color: Color(0xFF04274B),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),

            // Badges (keeping existing functionality)
            badges.isNotEmpty
                ? Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children:
                      badges
                          .map<Widget>((badge) => _buildBadgeIcon(badge))
                          .toList(),
                )
                : Icon(Icons.emoji_events, size: 24, color: Color(0xFFFFD700)),
            SizedBox(height: 10),

            // Points (further reduced)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isFirst ? 8 : 7, // was 12/10
                vertical: 8, // was 4
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rankColors[i], rankColors[i].withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16), // was 14
              ),
              child: Text(
                '${entry['points']} ${appLoc.translate('pts')}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isFirst ? 11 : 10,
                  // was 12 / 11
                  letterSpacing: 0.1,
                  // tighter
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Builds remaining rankings list
  Widget _buildRemainingRankings(AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.format_list_numbered_rounded,
                    color: Color(0xFF04274B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLoc.translate('All Rankings'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF04274B),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rankings List
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length - 3,
              separatorBuilder:
                  (_, __) => Divider(
                    color: Colors.grey[200],
                    thickness: 1,
                    height: 20,
                  ),
              itemBuilder: (context, idx) {
                final index = idx + 3;
                final entry = leaderboard[index];
                final badges = entry['badges'] as List<dynamic>? ?? [];

                return _buildRankingItem(entry, index + 1, badges, appLoc);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Builds individual ranking item
  Widget _buildRankingItem(
    Map<String, dynamic> entry,
    int rank,
    List<dynamic> badges,
    AppLocalizations appLoc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blueGrey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Color(0xFF04274B),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF04274B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Badges
                badges.isNotEmpty
                    ? Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children:
                          badges
                              .map<Widget>(
                                (badge) => _buildBadgeIcon(badge, size: 20),
                              )
                              .toList(),
                    )
                    : Icon(
                      Icons.emoji_events,
                      size: 20,
                      color: Color(0xFFFFD700),
                    ),
              ],
            ),
          ),

          // Points
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF04274B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${entry['points']} ${appLoc.translate('pts')}',
              style: TextStyle(
                color: Color(0xFF04274B),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds user's own position and points
  Widget _buildYourPosition(AppLocalizations appLoc) {
    String userName = '';
    if (userEntry != null &&
        userEntry!['name'] != null &&
        userEntry!['name'].toString().isNotEmpty) {
      userName = userEntry!['name'];
    } else if (UserSession.email.isNotEmpty) {
      userName = UserSession.email;
    } else {
      userName = appLoc.translate("You");
    }

    final showRank = userRank != null;
    final rankText = showRank ? '${userRank!}' : appLoc.translate('N/A');
    final pointsText =
        userEntry != null && userEntry!['points'] != null
            ? '${userEntry!['points']} ${appLoc.translate('pts')}'
            : '0 ${appLoc.translate('pts')}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF04274B), Color(0xFF1e40af)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF04274B).withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // Your rank circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  rankText,
                  style: TextStyle(
                    color: Color(0xFF04274B),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Your info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLoc.translate('Your Position'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Your points
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pointsText,
                style: TextStyle(
                  color: Color(0xFF04274B),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds badge icon with dialog
  Widget _buildBadgeIcon(Map<String, dynamic> badge, {double size = 24}) {
    final imagePath = badge['ImagePath'];

    return GestureDetector(
      onTap: () => _showBadgeDialog(badge),
      child: Tooltip(
        message: badge['BadgeName'] ?? '',
        child:
            imagePath != null && imagePath.toString().isNotEmpty
                ? Image.network(
                  'http://192.168.1.2${imagePath}',
                  height: size,
                  width: size,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.emoji_events,
                        size: size,
                        color: Color(0xFFFFD700),
                      ),
                )
                : Icon(
                  Icons.emoji_events,
                  size: size,
                  color: Color(0xFFFFD700),
                ),
      ),
    );
  }

  // Shows badge details dialog
  void _showBadgeDialog(Map<String, dynamic> badge) {
    final imagePath = badge['ImagePath'];
    final appLoc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF04274B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: const Color(0xFFE3E9F4),
                  ),
                  padding: const EdgeInsets.all(6),
                  child:
                      imagePath != null && imagePath.toString().isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              'http://192.168.1.2${imagePath}',
                              height: 64,
                              width: 64,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    Icons.emoji_events,
                                    size: 64,
                                    color: Color(0xFFFFD700),
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Color(0xFFFFD700),
                          ),
                ),
                const SizedBox(height: 18),
                Text(
                  badge['BadgeName'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  badge['Description'] ?? '',
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF0A4173),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  appLoc.translate('OK'),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }
}
