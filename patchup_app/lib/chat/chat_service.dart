//
// ChatService: Manages chat message state, API communication, polling for updates,
// sending, editing, and deleting messages for a pothole report conversation.
//

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../components/appbar.dart' show UserSession;
import 'chat_models.dart';

class ChatService extends ChangeNotifier {
  final int reportId;
  final String baseUrl;

  ChatService({required this.reportId, required this.baseUrl});

  final List<ChatMessage> messages = [];

  bool loadingInitial = true;
  bool sending = false;
  bool hasMoreBackward = true;

  int? _lastMessageId;
  int? _oldestMessageId;
  bool _fetchingNew = false;
  bool _fetchingOlder = false;
  DateTime _lastUpdateCheck = DateTime.now();
  bool _fetchingUpdates = false;

  Timer? _pollMessagesTimer;

  static const int _pageLimit = 30;

  int? currentUserId;
  String? currentUserName;

  final Map<int, ChatMessage> _pendingDeleteOriginals = {};
  final Set<int> _pendingEdits = {};

  /// Initializes user info, loads initial messages, and starts polling timers
  Future<void> init() async {
    await _resolveCurrentUser();
    await _loadInitial();
    _startTimers();
  }

  /// Resolves current user info from session/email
  Future<void> _resolveCurrentUser() async {
    final email = UserSession.email;
    if (email.isEmpty) return;
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/get_user_info.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['user_id'] != null) {
          currentUserId =
              (data['user_id'] is int)
                  ? data['user_id']
                  : int.tryParse(data['user_id'].toString());
          currentUserName = data['name']?.toString();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  /// Checks if a message is sent by the current user
  bool isOwnMessage(ChatMessage m) =>
      currentUserId != null && m.userId == currentUserId;

  // ---------------- Messaging ----------------

  /// Loads initial batch of messages for the conversation
  Future<void> _loadInitial() async {
    loadingInitial = true;
    notifyListeners();
    try {
      final body = {'ReportID': reportId, 'limit': _pageLimit};
      final resp = await http.post(
        Uri.parse('$baseUrl/get_chat_messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          final List list = data['messages'] ?? [];
          messages.addAll(list.map((m) => ChatMessage.fromMap(m)));
          if (messages.isNotEmpty) {
            _lastMessageId = messages.last.messageId;
            _oldestMessageId = messages.first.messageId;
            hasMoreBackward = list.length == _pageLimit;
          } else {
            hasMoreBackward = false;
          }
        }
      }
    } catch (_) {}
    loadingInitial = false;
    notifyListeners();

    _lastUpdateCheck = DateTime.now().toUtc();
  }

  /// Schedules a microtask to notify listeners safely
  void _asyncNotify() {
    if (!hasListeners) return;
    scheduleMicrotask(() {
      if (hasListeners) notifyListeners();
    });
  }

  /// Edits a message with optimistic UI update and server sync
  Future<void> editMessage(int messageId, String newText) async {
    final email = UserSession.email;
    if (email.isEmpty || newText.trim().isEmpty) return;
    final idx = messages.indexWhere((m) => m.messageId == messageId);
    if (idx == -1) return;
    final current = messages[idx];
    if (current.isDeleted) return;
    if (_pendingEdits.contains(messageId)) return;

    _pendingEdits.add(messageId);
    final now = DateTime.now();
    messages[idx] = current.copyWith(
      text: newText.trim(),
      isEdited: true,
      editedAt: now,
    );
    notifyListeners();

    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/update_chat_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': email,
          'MessageID': messageId,
          'Message': newText.trim(),
        }),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['message'] != null) {
          final serverMsg = ChatMessage.fromMap(data['message']);
          final idx2 = messages.indexWhere((m) => m.messageId == messageId);
          if (idx2 != -1) {
            messages[idx2] = serverMsg;
            notifyListeners();
          }
        } else {
          final idx2 = messages.indexWhere((m) => m.messageId == messageId);
          if (idx2 != -1) {
            messages[idx2] = current;
            notifyListeners();
          }
        }
      } else {
        final idx2 = messages.indexWhere((m) => m.messageId == messageId);
        if (idx2 != -1) {
          messages[idx2] = current;
          notifyListeners();
        }
      }
    } catch (_) {
      final idx2 = messages.indexWhere((m) => m.messageId == messageId);
      if (idx2 != -1) {
        messages[idx2] = current;
        notifyListeners();
      }
    } finally {
      _pendingEdits.remove(messageId);
    }
  }

  /// Deletes a message with optimistic UI update and server sync
  Future<void> deleteMessage(int messageId) async {
    final email = UserSession.email;
    if (email.isEmpty) return;
    if (_pendingDeleteOriginals.containsKey(messageId)) return;

    final idx = messages.indexWhere((m) => m.messageId == messageId);
    if (idx == -1) return;
    final original = messages[idx];
    if (original.isDeleted) return;

    _pendingDeleteOriginals[messageId] = original;

    messages[idx] = original.copyWith(isDeleted: true);
    notifyListeners();

    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/delete_chat_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email, 'MessageID': messageId}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['message'] != null) {
          final updated = ChatMessage.fromMap(data['message']);
          final idx2 = messages.indexWhere((m) => m.messageId == messageId);
          if (idx2 != -1) {
            messages[idx2] = updated;
            notifyListeners();
          }
        }
      }
    } catch (_) {
    } finally {
      _pendingDeleteOriginals.remove(messageId);
    }
  }

  /// Polls for new messages from the server
  Future<void> _pollNewMessages() async {
    if (_fetchingNew || _lastMessageId == null) return;
    _fetchingNew = true;
    try {
      final body = {
        'ReportID': reportId,
        'after_id': _lastMessageId,
        'limit': _pageLimit,
      };
      final resp = await http.post(
        Uri.parse('$baseUrl/get_chat_messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          final List list = data['messages'] ?? [];
          if (list.isNotEmpty) {
            for (final m in list) {
              messages.add(ChatMessage.fromMap(m));
            }
            _lastMessageId = messages.last.messageId;
            _asyncNotify();
          }
        }
      }
    } catch (_) {}
    _fetchingNew = false;

    _pollMessageUpdates();
  }

  /// Polls for updates to existing messages (edits/deletes)
  Future<void> _pollMessageUpdates() async {
    if (_fetchingUpdates) return;
    _fetchingUpdates = true;
    try {
      final sinceUtc = _lastUpdateCheck.toUtc().toIso8601String();
      final body = {'ReportID': reportId, 'updated_since': sinceUtc};

      if (kDebugMode) {
        print('Polling updates since: $sinceUtc');
      }

      final resp = await http.post(
        Uri.parse('$baseUrl/get_chat_messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          final List list = data['messages'] ?? [];
          bool hasChanges = false;

          if (kDebugMode && list.isNotEmpty) {
            print('Found ${list.length} updated messages');
          }

          for (final m in list) {
            final updated = ChatMessage.fromMap(m);
            final idx = messages.indexWhere(
              (msg) => msg.messageId == updated.messageId,
            );

            if (idx != -1) {
              if (_pendingEdits.contains(updated.messageId) ||
                  _pendingDeleteOriginals.containsKey(updated.messageId)) {
                if (kDebugMode) {
                  print('Skipping pending message ${updated.messageId}');
                }
                continue;
              }

              if (kDebugMode) {
                print(
                  'Updating message ${updated.messageId}: deleted=${updated.isDeleted}, edited=${updated.isEdited}',
                );
              }

              messages[idx] = updated;
              hasChanges = true;
            }
          }

          if (hasChanges) {
            if (kDebugMode) {
              print('Notifying UI of message updates');
            }
            _asyncNotify();
          }
          _lastUpdateCheck = DateTime.now().toUtc();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error polling updates: $e');
      }
    }
    _fetchingUpdates = false;
  }

  /// Loads older messages for pagination
  Future<void> loadOlder() async {
    if (_fetchingOlder || !hasMoreBackward || _oldestMessageId == null) return;
    _fetchingOlder = true;
    try {
      final body = {
        'ReportID': reportId,
        'before_id': _oldestMessageId,
        'limit': _pageLimit,
      };
      final resp = await http.post(
        Uri.parse('$baseUrl/get_chat_messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          final List list = data['messages'] ?? [];
          if (list.isNotEmpty) {
            final older = list.map((m) => ChatMessage.fromMap(m)).toList();
            messages.insertAll(0, older);
            _oldestMessageId = messages.first.messageId;
            hasMoreBackward = older.length == _pageLimit;
            _asyncNotify();
          } else {
            hasMoreBackward = false;
          }
        }
      }
    } catch (_) {}
    _fetchingOlder = false;
  }

  /// Sends a new message to the server
  Future<void> sendMessage(String text) async {
    final email = UserSession.email;
    if (email.isEmpty || text.trim().isEmpty || sending) return;
    sending = true;
    notifyListeners();
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/add_chat_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': email,
          'ReportID': reportId,
          'Message': text.trim(),
        }),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && data['message'] != null) {
          final msg = ChatMessage.fromMap(data['message']);
          messages.add(msg);
          currentUserId ??= msg.userId;
          currentUserName ??= msg.userName;
          _lastMessageId = msg.messageId;
          if (_oldestMessageId == null || msg.messageId < _oldestMessageId!) {
            _oldestMessageId = msg.messageId;
          }
          notifyListeners();
        }
      }
    } catch (_) {}
    sending = false;
  }

  // ---------------- Timers ----------------

  /// Starts polling timer for new messages
  void _startTimers() {
    _pollMessagesTimer?.cancel();
    _pollMessagesTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _pollNewMessages(),
    );
  }

  @override
  void dispose() {
    _pollMessagesTimer?.cancel();
    super.dispose();
  }
}
