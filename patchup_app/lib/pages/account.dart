//
// AccountPage: Displays user info, points, quick actions, settings, and account actions.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/appbar.dart';
import '../localization/app_localizations.dart';
import '../main.dart';
import 'aboutus_contactus.dart';
import 'login.dart';
import 'my_badges.dart';
import 'my_reports.dart';
import 'terms_conditions.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // User info and state
  String userName = '';
  String userEmail = '';
  bool loading = true;
  String selectedLanguageCode = 'en';
  bool notificationsEnabled = true;
  int userPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchUserPoints();
    _loadSelectedLanguage();
  }

  // Fetches user info from backend or cache
  Future<void> _fetchUserInfo() async {
    final email = UserSession.email;
    if (email.isEmpty) {
      setState(() {
        userName = '';
        userEmail = '';
        loading = false;
      });
      return;
    }
    final url = 'http://192.168.1.2/patchup_app/lib/api/get_user_info.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Email": email}),
      );
      final result = jsonDecode(response.body);
      setState(() {
        userName = result['name'] ?? '';
        userEmail = result['email'] ?? email;
        loading = false;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_name_$email', userName);
      await prefs.setString('cached_user_email_$email', userEmail);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString('cached_user_name_$email');
      final cachedEmail = prefs.getString('cached_user_email_$email');
      setState(() {
        userName = cachedName ?? '';
        userEmail = cachedEmail ?? email;
        loading = false;
      });
    }
  }

  // Fetches user points from backend or cache
  Future<void> _fetchUserPoints() async {
    final email = UserSession.email;
    if (email.isEmpty) {
      setState(() {
        userPoints = 0;
      });
      return;
    }
    final url = 'http://192.168.1.2/patchup_app/lib/api/get_points.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Email": email}),
      );
      final result = jsonDecode(response.body);
      setState(() {
        userPoints = result['points'] ?? 0;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_user_points_$email', userPoints);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedPoints = prefs.getInt('cached_user_points_$email');
      setState(() {
        userPoints = cachedPoints ?? 0;
      });
    }
  }

  // Logs out user and clears session
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    UserSession.email = '';
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // Shows confirm logout dialog
  Future<void> _confirmLogout(BuildContext context) async {
    final appLoc = AppLocalizations.of(context);
    final shouldLogout = await showDialog<bool>(
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
                    Icons.logout_rounded,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLoc.translate('Logout'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: const Color(0xFF04274B),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                appLoc.translate('Are you sure you want to logout?'),
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
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  appLoc.translate('Cancel'),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  appLoc.translate('Logout'),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
    );
    if (shouldLogout == true) {
      await _logout(context);
    }
  }

  // Loads selected language from preferences
  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_language');
    if (langCode != null && langCode.isNotEmpty) {
      setState(() {
        selectedLanguageCode = langCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF04274B),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF04274B), Color(0xFF0A4173)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Column(
              children: [
                // Profile header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 28,
                  ),
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFFE3E9F4),
                          child: Icon(
                            Icons.person,
                            size: 44,
                            color: Color(0xFF04274B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child:
                            loading
                                ? (userName.isNotEmpty || userEmail.isNotEmpty
                                    ? _buildProfileInfo()
                                    : const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ))
                                : _buildProfileInfo(),
                      ),
                    ],
                  ),
                ),
                // Main content section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x2204274B),
                          blurRadius: 28,
                          offset: Offset(0, -10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          // Quick Actions Section
                          _buildQuickActionsSection(context, appLoc),
                          const SizedBox(height: 24),

                          // Settings Section
                          _buildSettingsSection(context, appLoc),
                          const SizedBox(height: 24),

                          // Account Actions Section
                          _buildAccountActionsSection(context, appLoc),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds profile info display
  Widget _buildProfileInfo() {
    final appLoc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName.isNotEmpty ? userName : appLoc.translate('Name not found'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
            shadows: [
              Shadow(
                color: Color(0x33000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userEmail.isNotEmpty
              ? userEmail
              : appLoc.translate('Email not found'),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFB3C2D6),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 22),
              const SizedBox(width: 6),
              Text(
                '$userPoints ${appLoc.translate('Points')}',
                style: const TextStyle(
                  color: Color(0xFFFFA000),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Builds quick actions section (My Reports, My Badges)
  Widget _buildQuickActionsSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
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
                  Icons.dashboard_rounded,
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
                      appLoc.translate('Quick Actions'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Access your data and achievements'),
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

        // Quick Action Cards
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.assignment_rounded,
                title: appLoc.translate('My Reports'),
                subtitle: appLoc.translate('View submissions'),
                gradient: [Colors.blue[50]!, Colors.blue[100]!],
                iconColor: Colors.blue[700]!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyReportsPage()),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.emoji_events_rounded,
                title: appLoc.translate('My Badges'),
                subtitle: appLoc.translate('View achievements'),
                gradient: [Colors.amber[50]!, Colors.amber[100]!],
                iconColor: Colors.amber[700]!,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyBadgesPage()),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Quick action card builder
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF04274B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds settings section (language, notifications)
  Widget _buildSettingsSection(BuildContext context, AppLocalizations appLoc) {
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
                  Icons.settings_rounded,
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
                      appLoc.translate('Settings'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Customize your experience'),
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

        // Settings Cards
        _buildLanguageCard(),
        const SizedBox(height: 16),
        _buildNotificationsSection(appLoc),
      ],
    );
  }

  // Builds account actions section (About, Terms, Logout)
  Widget _buildAccountActionsSection(
    BuildContext context,
    AppLocalizations appLoc,
  ) {
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
                  Icons.account_circle_rounded,
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
                      appLoc.translate('Account'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      appLoc.translate('Support and account options'),
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

        // Account Action Cards
        _buildAccountActionCard(
          context,
          icon: Icons.info_outline_rounded,
          title: appLoc.translate('About & Contact Us'),
          subtitle: appLoc.translate('Learn more about PatchUp'),
          color: Colors.blue,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutContactUsPage()),
              ),
        ),
        const SizedBox(height: 12),
        _buildAccountActionCard(
          context,
          icon: Icons.description_outlined,
          title: appLoc.translate('Terms and Conditions'),
          subtitle: appLoc.translate('Read our terms of service'),
          color: Colors.indigo,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsConditionsPage(),
                ),
              ),
        ),
        const SizedBox(height: 12),
        _buildAccountActionCard(
          context,
          icon: Icons.logout_rounded,
          title: appLoc.translate('Logout'),
          subtitle: appLoc.translate('Sign out of your account'),
          color: Colors.red,
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  // Account action card builder
  Widget _buildAccountActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF04274B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.blueGrey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds language selection card
  Widget _buildLanguageCard() {
    final appLoc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: Color(0xFF04274B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLoc.translate('language'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF04274B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLanguageButton(
                    langCode: 'en',
                    label: appLoc.translate('English'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLanguageButton(
                    langCode: 'si',
                    label: appLoc.translate('Sinhala'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLanguageButton(
                    langCode: 'ta',
                    label: appLoc.translate('Tamil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Language button builder
  Widget _buildLanguageButton({
    required String langCode,
    required String label,
  }) {
    final isSelected = selectedLanguageCode == langCode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      child: TextButton(
        onPressed: () async {
          setState(() {
            selectedLanguageCode = langCode;
          });
          final inherited = InheritedLocale.of(context);
          inherited?.setLocale(Locale(langCode));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_language', langCode);
        },
        style: TextButton.styleFrom(
          backgroundColor:
              isSelected ? Color(0xFF04274B) : Colors.grey.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Builds notifications toggle section
  Widget _buildNotificationsSection(AppLocalizations appLoc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF04274B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF04274B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                appLoc.translate('Enable Notifications'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF04274B),
                ),
              ),
            ),
            Switch(
              value: notificationsEnabled,
              activeColor: Color(0xFF04274B),
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
