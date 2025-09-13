//
// Chat message models and utilities for parsing and copying chat data.
//

class ChatMessage {
  final int messageId;
  final int reportId;
  final int userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final bool isEdited;
  final bool isDeleted;
  final DateTime? editedAt;
  final bool isAdmin;

  ChatMessage({
    required this.messageId,
    required this.reportId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    required this.isEdited,
    required this.isDeleted,
    required this.editedAt,
    required this.isAdmin,
  });

  // Parses a ChatMessage from a map (e.g., from JSON)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      messageId: _asInt(map['MessageID']),
      reportId: _asInt(map['ReportID']),
      userId: _asInt(map['UserID']),
      userName: map['UserName']?.toString() ?? 'User',
      text: map['MessageText']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['CreatedAt']?.toString() ?? '') ??
          DateTime.now(),
      isEdited: (map['IsEdited']?.toString() == '1'),
      isDeleted: (map['IsDeleted']?.toString() == '1'),
      editedAt:
          map['EditedAt'] != null && map['EditedAt'].toString().isNotEmpty
              ? DateTime.tryParse(map['EditedAt'].toString())
              : null,
      isAdmin: (map['IsAdmin']?.toString() == '1'),
    );
  }

  // Utility: Safely parses integers from dynamic values
  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // Returns a copy of this message with optional overrides
  ChatMessage copyWith({
    String? text,
    bool? isEdited,
    bool? isDeleted,
    DateTime? editedAt,
    bool? isAdmin,
  }) {
    return ChatMessage(
      messageId: messageId,
      reportId: reportId,
      userId: userId,
      userName: userName,
      text: text ?? this.text,
      createdAt: createdAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      editedAt: editedAt ?? this.editedAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
