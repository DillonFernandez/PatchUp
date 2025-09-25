//
// ChatPage: UI for displaying, sending, editing, and deleting messages
// in a pothole report conversation. Handles message input, display,
// scrolling, and interaction with ChatService.
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';
import 'chat_models.dart';
import 'chat_service.dart';

class ChatPage extends StatefulWidget {
  final int reportId;
  final String baseApiUrl;

  const ChatPage({super.key, required this.reportId, required this.baseApiUrl});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  // Controllers and state for animation, scrolling, and input
  late ChatService _service;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _autoScroll = true;
  bool _loadingOlder = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize fade animation and chat service
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _service = ChatService(
      reportId: widget.reportId,
      baseUrl: widget.baseApiUrl,
    );
    _service.addListener(_onServiceUpdate);
    _service.init();
    _scroll.addListener(_handleScroll);
    _fadeController.forward();
  }

  /// Handles updates from ChatService and auto-scroll logic
  void _onServiceUpdate() {
    if (!mounted) return;
    if (_autoScroll && _service.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Handles scroll events for loading older messages and auto-scroll
  void _handleScroll() {
    if (_scroll.position.pixels < _scroll.position.minScrollExtent + 60 &&
        !_loadingOlder &&
        _service.hasMoreBackward) {
      _loadOlder();
    }
    final atBottom =
        _scroll.position.pixels >= (_scroll.position.maxScrollExtent - 100);
    _autoScroll = atBottom;
  }

  /// Loads older messages when user scrolls up
  Future<void> _loadOlder() async {
    setState(() => _loadingOlder = true);
    await _service.loadOlder();
    setState(() => _loadingOlder = false);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scroll.dispose();
    _controller.dispose();
    _service.removeListener(_onServiceUpdate);
    _service.dispose();
    super.dispose();
  }

  /// Sends a new message
  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _service.sendMessage(text);
    _controller.clear();
  }

  /// Localization helper
  String _t(String key) => AppLocalizations.of(context).translate(key);

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
      child: ChangeNotifierProvider.value(
        value: _service,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              appLoc.translate('Chat'),
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
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(child: _buildChatContent()),
                _buildMessageInput(appLoc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds chat message list and loading/empty states
  Widget _buildChatContent() {
    return Consumer<ChatService>(
      builder: (_, svc, __) {
        if (svc.loadingInitial && svc.messages.isEmpty) {
          return _buildLoadingState();
        }
        if (svc.messages.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFF8FAFC), Colors.grey[50]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: svc.messages.length + (_loadingOlder ? 1 : 0),
            itemBuilder: (ctx, idx) {
              if (_loadingOlder && idx == 0) {
                return _buildLoadingIndicator();
              }
              final msgIdx = _loadingOlder ? idx - 1 : idx;
              final msg = svc.messages[msgIdx];
              final isMe = svc.isOwnMessage(msg);
              return _buildMessageBubble(msg, isMe);
            },
          ),
        );
      },
    );
  }

  /// Shows loading indicator when loading older messages
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: const Color(0xFF04274B),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _t('Loading older messages...'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows loading state when initial messages are being fetched
  Widget _buildLoadingState() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final minH = (constraints.maxHeight - bottomInset).clamp(
          0.0,
          double.infinity,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 48, 24, 24 + bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF04274B).withOpacity(0.1),
                          const Color(0xFF3b82f6).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      color: const Color(0xFF04274B),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _t('Loading conversation...'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF04274B),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _t('Please wait while we fetch messages'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows empty state when there are no messages
  Widget _buildEmptyState() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final minH = (constraints.maxHeight - bottomInset).clamp(
          0.0,
          double.infinity,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 48, 24, 24 + bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF04274B).withOpacity(0.08),
                          const Color(0xFF3b82f6).withOpacity(0.04),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF04274B).withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 72,
                      color: const Color(0xFF04274B).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _t('Start the Conversation'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF04274B),
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('No messages yet. Be the first to send a message!'),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF04274B).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF04274B).withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      _t('💬 Type your message below'),
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF04274B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a chat message bubble with styling and options
  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final isDeleted = message.isDeleted;
    final showEdited = message.isEdited && !isDeleted;
    final isAdmin = message.isAdmin && !isDeleted;
    final timeBase =
        showEdited && message.editedAt != null
            ? message.editedAt!
            : message.createdAt;
    final timeLabel = _formatTime(timeBase) + (showEdited ? ' (edited)' : '');

    // Determine colors/gradient factoring admin
    LinearGradient? gradient;
    Color textColor;
    Color timeColor;

    if (isDeleted) {
      if (isMe) {
        gradient = LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[200]!],
        );
        textColor = Colors.white70;
        timeColor = Colors.white60;
      } else {
        gradient = LinearGradient(
          colors: [Colors.grey[100]!, Colors.grey[50]!],
        );
        textColor = Colors.grey[500]!;
        timeColor = Colors.grey[400]!;
      }
    } else if (isAdmin) {
      gradient = const LinearGradient(
        colors: [Color(0xFFE11D48), Color(0xFFF87171)],
      );
      textColor = Colors.white;
      timeColor = Colors.white70;
    } else if (isMe) {
      gradient = LinearGradient(
        colors: [const Color(0xFF04274B), const Color(0xFF1e40af)],
      );
      textColor = Colors.white;
      timeColor = Colors.white70;
    } else {
      gradient = LinearGradient(colors: [Colors.white, Colors.grey[50]!]);
      textColor = const Color(0xFF04274B);
      timeColor = Colors.grey[500]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF04274B).withOpacity(0.1),
              child: Text(
                message.userName.isNotEmpty
                    ? message.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF04274B),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress:
                  (isMe && !isDeleted)
                      ? () => _showMessageOptions(message)
                      : null,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft:
                        isMe
                            ? const Radius.circular(20)
                            : const Radius.circular(4),
                    bottomRight:
                        isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        isMe || isAdmin ? 0.15 : 0.08,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                  border:
                      (isMe || isAdmin)
                          ? null
                          : Border.all(color: Colors.grey[200]!, width: 1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Show name for non-self messages and all admin messages
                    if (((!isMe) || isAdmin) && !isDeleted) ...[
                      Text(
                        isAdmin
                            ? '${message.userName} | Admin'
                            : message.userName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              isAdmin ? Colors.white : const Color(0xFF04274B),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      isDeleted ? _t('Message deleted') : message.text,
                      style: TextStyle(
                        color: isDeleted ? textColor : textColor,
                        fontSize: 15,
                        fontStyle:
                            isDeleted ? FontStyle.italic : FontStyle.normal,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            showEdited ? FontStyle.italic : FontStyle.normal,
                        color: timeColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF04274B),
              child: Icon(Icons.person_rounded, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds message input field and send button
  Widget _buildMessageInput(AppLocalizations appLoc) {
    return Consumer<ChatService>(
      builder: (_, svc, __) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      cursorColor: const Color(0xFF04274B),
                      decoration: InputDecoration(
                        hintText: appLoc.translate('Type a message...'),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF04274B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient:
                        svc.sending
                            ? LinearGradient(
                              colors: [Colors.grey[400]!, Colors.grey[500]!],
                            )
                            : LinearGradient(
                              colors: [
                                const Color(0xFF04274B),
                                const Color(0xFF1e40af),
                              ],
                            ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        svc.sending
                            ? []
                            : [
                              BoxShadow(
                                color: const Color(0xFF04274B).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: svc.sending ? null : _send,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows options for editing or deleting a message
  void _showMessageOptions(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _t('Edit Message'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    _startEditMessage(msg);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: Colors.red[600],
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _t('Delete Message'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    _confirmDelete(msg);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Starts editing a message
  Future<void> _startEditMessage(ChatMessage msg) async {
    final updated = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _EditMessageDialog(initialText: msg.text),
    );
    if (!mounted || updated == null) return;
    if (updated.trim().isNotEmpty && updated.trim() != msg.text) {
      _service.editMessage(msg.messageId, updated.trim());
    }
  }

  /// Confirms deletion of a message
  void _confirmDelete(ChatMessage msg) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogCtx) => AlertDialog(
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
                    Icons.delete_rounded,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _t('Delete Message'),
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
                _t(
                  'Are you sure you want to delete this message? This action cannot be undone.',
                ),
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
                onPressed: () => Navigator.of(dialogCtx).pop(),
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
                  _t('Cancel'),
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
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  _service.deleteMessage(msg.messageId);
                },
                child: Text(
                  _t('Delete'),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
    );
  }

  /// Formats time for message display
  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? _t('PM') : _t('AM');
    return '$h:$m $ampm';
  }
}

/// Dialog for editing a chat message
class _EditMessageDialog extends StatefulWidget {
  final String initialText;

  const _EditMessageDialog({required this.initialText});

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 24,
      shadowColor: Colors.black.withOpacity(0.2),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF04274B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: const Color(0xFF04274B),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            appLoc.translate('Edit Message'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: const Color(0xFF04274B),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLoc.translate('Edit your message below:'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                color: const Color(0xFFF7F9FC),
              ),
              child: TextField(
                controller: _ctrl,
                maxLines: 5,
                minLines: 3,
                autofocus: true,
                cursorColor: const Color(0xFF04274B),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: appLoc.translate('Enter your message...'),
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF04274B),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[100],
            foregroundColor: Colors.grey[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            appLoc.translate('Cancel'),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04274B),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            final val = _ctrl.text.trim();
            Navigator.of(
              context,
            ).pop((val.isNotEmpty && val != widget.initialText) ? val : null);
          },
          child: Text(
            appLoc.translate('Save'),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
