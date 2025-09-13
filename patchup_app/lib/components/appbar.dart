//
// UserAppBar: Custom app bar widget showing logo, user points, and notifications.
// Handles fetching user points and unread notification count.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/notifications.dart';

// Stores current user session info
class UserSession {
  static String email = '';
}

// Main app bar widget
class UserAppBar extends StatefulWidget implements PreferredSizeWidget {
  const UserAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(54);

  @override
  State<UserAppBar> createState() => _UserAppBarState();
}

class _UserAppBarState extends State<UserAppBar> {
  int points = 0;
  bool loading = true;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPoints();
    fetchUnreadNotifications();
  }

  // Fetches user points from API or cache
  Future<void> fetchPoints() async {
    final email = UserSession.email;
    if (email.isEmpty) {
      setState(() {
        loading = false;
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
      final fetchedPoints = result['points'] ?? 0;
      setState(() {
        points = fetchedPoints;
        loading = false;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_points_${email}', fetchedPoints);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedPoints = prefs.getInt('cached_points_${email}');
      setState(() {
        points = cachedPoints ?? 0;
        loading = false;
      });
    }
  }

  // Fetches unread notification count from API
  Future<void> fetchUnreadNotifications() async {
    final email = UserSession.email;
    if (email.isEmpty) {
      setState(() {
        unreadCount = 0;
      });
      return;
    }
    final url = 'http://192.168.1.2/patchup_app/lib/api/get_notifications.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Email": email}),
      );
      final result = jsonDecode(response.body);
      if (result['success'] == true && result['notifications'] is List) {
        final notifications = result['notifications'] as List;
        final count = notifications.where((n) => n['IsRead'] == 0).length;
        setState(() {
          unreadCount = count;
        });
      } else {
        setState(() {
          unreadCount = 0;
        });
      }
    } catch (e) {
      setState(() {
        unreadCount = 0;
      });
    }
  }

  // Builds the app bar UI
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // App logo
            Image.asset(
              'assets/images/logo/Logo 1.webp',
              width: 105,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(child: Container()),
            // Points indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 22),
                  const SizedBox(width: 6),
                  loading
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                        ),
                      )
                      : Text(
                        '$points',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Notification icon with badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.black87,
                    size: 28,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                    // Refresh unread count after returning
                    fetchUnreadNotifications();
                  },
                  tooltip: 'Notifications',
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
}
