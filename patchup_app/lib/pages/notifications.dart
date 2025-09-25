//
// NotificationsPage: Displays and manages user notifications.
// Handles fetching, marking as read, and UI for notifications.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/appbar.dart' show UserSession;
import '../localization/app_localizations.dart';

// Notifications page widget
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

// State for notifications logic and UI
class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _loading = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  // Loads user email and fetches notifications
  Future<void> _loadUserAndFetch() async {
    String? email = UserSession.email;
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('user_email');
    setState(() {
      _userEmail = email;
    });
    if (email != null) {
      await _fetchNotifications(email);
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  // Fetches notifications from backend API
  Future<void> _fetchNotifications(String email) async {
    setState(() {
      _loading = true;
    });
    final url =
        'http://192.168.8.187/patchup_app/lib/api/get_notifications.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": email}),
    );
    final result = jsonDecode(response.body);
    setState(() {
      _notifications = result["success"] ? result["notifications"] : [];
      _loading = false;
    });
  }

  // Marks all notifications as read (updates locally)
  Future<void> _markAllAsRead() async {
    if (_userEmail == null) return;
    final url =
        'http://192.168.8.187/patchup_app/lib/api/mark_notifications_read.php';
    await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": _userEmail}),
    );
    // Update all unread notifications to read locally
    setState(() {
      for (var n in _notifications) {
        n['IsRead'] = 1;
      }
    });
  }

  // Marks a single notification as read (updates locally)
  Future<void> _markAsRead(int notificationID) async {
    if (_userEmail == null) return;
    final url =
        'http://192.168.8.187/patchup_app/lib/api/mark_notifications_read.php';
    await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"Email": _userEmail, "NotificationID": notificationID}),
    );
    // Update the notification's IsRead status locally
    setState(() {
      final notif = _notifications.firstWhere(
        (n) => n['NotificationID'] == notificationID,
        orElse: () => null,
      );
      if (notif != null) {
        notif['IsRead'] = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLoc.translate('Notifications AppBar Title'),
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
        actions: [
          if (_notifications.any((n) => n['IsRead'] == 0))
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              tooltip: appLoc.translate('Mark all as read'),
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body:
          _loading
              ? _buildLoadingState(appLoc)
              : _notifications.isEmpty
              ? _buildEmptyState(appLoc)
              : _buildNotificationsList(appLoc),
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
              appLoc.translate('Loading notifications...'),
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

  // Builds empty state UI
  Widget _buildEmptyState(AppLocalizations appLoc) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF04274B).withOpacity(0.1),
                    Color(0xFF3b82f6).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: Color(0xFF04274B).withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20),
            Text(
              appLoc.translate('No Notifications'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF04274B),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              appLoc.translate(
                "You're all caught up! No new notifications at the moment.",
              ),
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

  // Builds notifications list UI
  Widget _buildNotificationsList(AppLocalizations appLoc) {
    final unreadCount = _notifications.where((n) => n['IsRead'] == 0).length;

    return Column(
      children: [
        // Header with statistics
        if (unreadCount > 0) _buildNotificationsHeader(unreadCount, appLoc),

        // Notifications list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(20),
            itemCount: _notifications.length,
            separatorBuilder: (context, idx) => SizedBox(height: 16),
            itemBuilder: (context, idx) {
              final notification = _notifications[idx];
              return _buildNotificationCard(notification, appLoc);
            },
          ),
        ),
      ],
    );
  }

  // Builds header with unread notifications count
  Widget _buildNotificationsHeader(int unreadCount, AppLocalizations appLoc) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF04274B), Color(0xFF1e40af)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF04274B).withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLoc.translate('New Notifications'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  '$unreadCount ${appLoc.translate(unreadCount == 1 ? 'unread notification' : 'unread notifications')}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$unreadCount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds individual notification card
  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    AppLocalizations appLoc,
  ) {
    final isRead = notification['IsRead'] == 1;
    final notificationId = notification['NotificationID'];

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isRead
                    ? [Colors.grey[100]!, Colors.grey[50]!]
                    : [Colors.white, Color(0xFFF1F5F9)],
          ),
          border:
              isRead
                  ? null
                  : Border.all(
                    color: Color(0xFF04274B).withOpacity(0.1),
                    width: 1,
                  ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isRead ? 0.03 : 0.08),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isRead ? null : () => _markAsRead(notificationId),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient:
                          isRead
                              ? null
                              : LinearGradient(
                                colors: [
                                  Color(0xFF04274B).withOpacity(0.1),
                                  Color(0xFF3b82f6).withOpacity(0.05),
                                ],
                              ),
                      color: isRead ? Colors.grey[200] : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isRead
                          ? Icons.notifications_outlined
                          : Icons.notifications_active_rounded,
                      color: isRead ? Colors.grey[500] : Color(0xFF04274B),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),

                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification['Title'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isRead
                                          ? Colors.grey[600]
                                          : Color(0xFF04274B),
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Color(0xFF3b82f6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),

                        Text(
                          notification['Body'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isRead
                                    ? Colors.grey[500]
                                    : Colors.blueGrey[700],
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 12),

                        // CHANGED: Row -> Wrap for automatic wrapping
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color:
                                      isRead
                                          ? Colors.grey[400]
                                          : Colors.blueGrey[500],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _formatTimestamp(
                                    notification['CreatedAt'] ?? '',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isRead
                                            ? Colors.grey[400]
                                            : Colors.blueGrey[500],
                                  ),
                                ),
                              ],
                            ),
                            if (!isRead)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF04274B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appLoc.translate('NEW'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF04274B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Mark as read button for unread notifications
                  if (!isRead) SizedBox(width: 8),
                  if (!isRead)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _markAsRead(notificationId),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.mark_email_read_rounded,
                            size: 20,
                            color: Color(0xFF04274B),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Formats notification timestamp for display
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      final appLoc = AppLocalizations.of(context);

      if (difference.inMinutes < 1) {
        return appLoc.translate('Just now');
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}${appLoc.translate('m ago')}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}${appLoc.translate('h ago')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}${appLoc.translate('d ago')}';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
