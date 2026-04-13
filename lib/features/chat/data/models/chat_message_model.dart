import 'package:shop_app/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.roomId,
    required super.senderType,
    required super.senderId,
    required super.content,
    required super.status,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Backend schema: sender (ObjectId), senderModel ('User'|'Admin'), text (String)
    // Socket emit them 'content' as alias for 'text'
    final sType = json['senderModel'] ?? 'User';
    final sId = (json['sender'] is String)
        ? json['sender']
        : json['sender']?.toString() ?? '';
    final text = json['content'] ?? json['text'] ?? '';
    final roomId = (json['room'] is String)
        ? json['room']
        : json['room']?.toString() ?? '';

    return ChatMessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      roomId: roomId,
      senderType: sType,
      senderId: sId,
      content: text,
      status: json['isRead'] == true ? 'read' : 'sent',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'room': roomId,
      'sender': {
        'type': senderType,
        'userId': senderId,
      },
      'content': content,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

