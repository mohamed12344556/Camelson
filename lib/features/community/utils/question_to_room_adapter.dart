import '../data/models/question.dart';
import '../data/models/room.dart';

/// Adapter to convert Question to Room for compatibility with ChatBloc
class QuestionToRoomAdapter {
  /// Convert a Question to a Room object
  static Room questionToRoom(Question question) {
    return Room(
      id: question.id,
      name: question.title,
      description: question.description,
      subject: question.subjectName,
      grade: 'General', // Questions don't have grades
      memberCount: question.memberCount,
      messageCount: question.messageCount,
      createdAt: question.createdAt,
      lastMessage: null, // Not tracked in Question
      lastMessageTime: question.updatedAt ?? question.createdAt,
      unreadCount: 0, // Questions don't track unread
      creatorId: question.creatorId,
      creatorName: question.creatorName,
      currentUserRole: question.currentUserRole,
    );
  }

  /// Convert a Room back to a Question ID (for navigation)
  static String roomToQuestionId(Room room) {
    return room.id;
  }
}
