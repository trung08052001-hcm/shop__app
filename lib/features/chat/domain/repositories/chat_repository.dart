import 'package:dartz/dartz.dart';
import 'package:shop_app/features/chat/domain/entities/chat_message.dart';
import 'package:shop_app/core/error/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, String>> getMyRoomId();
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId);
  void connectAndJoin(String roomId);
  void disconnectSocket();
  void joinRoom(String roomId);
  void sendMessage(String roomId, String content);
  Stream<ChatMessage> get onMessageReceived;
}
