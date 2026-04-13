import 'package:dartz/dartz.dart';

import 'package:shop_app/core/error/exceptions.dart';
import 'package:shop_app/core/error/failures.dart';
import 'package:shop_app/features/chat/domain/entities/chat_message.dart';
import 'package:shop_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:shop_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;

  ChatRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, String>> getMyRoomId() async {
    try {
      final roomId = await remoteDatasource.getMyRoomId();
      return Right(roomId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId) async {
    try {
      final messages = await remoteDatasource.getMessages(roomId);
      return Right(messages.cast<ChatMessage>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void connectAndJoin(String roomId) {
    remoteDatasource.connectAndJoin(roomId);
  }

  @override
  void disconnectSocket() {
    remoteDatasource.disconnectSocket();
  }

  @override
  void joinRoom(String roomId) {
    remoteDatasource.joinRoom(roomId);
  }

  @override
  void sendMessage(String roomId, String content) {
    remoteDatasource.sendMessage(roomId, content);
  }

  @override
  Stream<ChatMessage> get onMessageReceived =>
      remoteDatasource.onMessageReceived.cast<ChatMessage>();
}
