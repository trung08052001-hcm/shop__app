import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String roomId;
  final String senderType; // 'User' or 'Admin'
  final String senderId;
  final String content;
  final String status;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderType,
    required this.senderId,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderType,
        senderId,
        content,
        status,
        createdAt,
      ];
}
