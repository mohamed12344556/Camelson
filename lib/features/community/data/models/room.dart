class Room {
  final String id;
  final String name;
  final String? description;
  final String subject;
  final String grade;
  final int memberCount;
  final int messageCount;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String? creatorId;
  final String? creatorName;
  final int currentUserRole; // 0=creator, 1=moderator, 2=member

  Room({
    required this.id,
    required this.name,
    this.description,
    required this.subject,
    required this.grade,
    required this.memberCount,
    required this.messageCount,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    this.creatorId,
    this.creatorName,
    this.currentUserRole = 2, // Default to member
  });

  /// Check if current user is the creator
  bool get isUserCreator => currentUserRole == 0;

  /// Check if current user has admin privileges (creator or moderator)
  bool get hasAdminPrivileges => currentUserRole == 0 || currentUserRole == 1;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      subject: json['subject'],
      grade: json['grade'],
      memberCount: json['memberCount'],
      messageCount: json['messageCount'],
      createdAt: DateTime.parse(json['createdAt']),
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      currentUserRole: json['currentUserRole'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'grade': grade,
      'memberCount': memberCount,
      'messageCount': messageCount,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'currentUserRole': currentUserRole,
    };
  }
}