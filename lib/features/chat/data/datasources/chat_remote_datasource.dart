import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shop_app/features/chat/data/models/chat_message_model.dart';
import 'package:shop_app/core/error/exceptions.dart';
import 'package:shop_app/core/network/dio_client.dart';
import 'package:injectable/injectable.dart';

abstract class ChatRemoteDatasource {
  Future<String> getMyRoomId();
  Future<List<ChatMessageModel>> getMessages(String roomId);
  void connectAndJoin(String roomId);
  void disconnectSocket();
  void joinRoom(String roomId);
  void sendMessage(String roomId, String content);
  Stream<ChatMessageModel> get onMessageReceived;
}

@LazySingleton(as: ChatRemoteDatasource)
class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final DioClient dioClient;
  IO.Socket? _socket;
  String? _currentRoomId;
  final _messageController = StreamController<ChatMessageModel>.broadcast();

  ChatRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<String> getMyRoomId() async {
    try {
      final response = await dioClient.dio.get('/chat/my-room');
      if (response.statusCode == 200) {
        return response.data['data']['_id'];
      } else {
        throw ServerException(response.data['message'] ?? 'Lỗi get my room');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String roomId) async {
    try {
      final response = await dioClient.dio.get('/chat/rooms/$roomId/messages');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((e) => ChatMessageModel.fromJson(e)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Lỗi load messages');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Kết nối socket VÀ tự động join room sau khi connected
  @override
  void connectAndJoin(String roomId) async {
    _currentRoomId = roomId;

    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_room', roomId);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final baseUrl = dioClient.dio.options.baseUrl.replaceAll('/api', '');

    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
    });

    _socket!.onConnect((_) {
      print('[Socket] Connected! Joining room: $_currentRoomId');
      if (_currentRoomId != null) {
        _socket!.emit('join_room', _currentRoomId);
      }
    });

    _socket!.on('receive_message', (data) {
      print('[Socket] receive_message: $data');
      if (data != null) {
        try {
          final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
          final message = ChatMessageModel.fromJson(map);
          _messageController.add(message);
        } catch (e) {
          print('[Socket] Parse error: $e');
        }
      }
    });

    _socket!.onReconnect((_) {
      print('[Socket] Reconnected! Re-joining: $_currentRoomId');
      if (_currentRoomId != null) {
        _socket!.emit('join_room', _currentRoomId);
      }
    });

    _socket!.onDisconnect((_) => print('[Socket] Disconnected'));
    _socket!.onError((e) => print('[Socket] Error: $e'));
    _socket!.connect();
  }

  @override
  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
    _currentRoomId = null;
  }

  @override
  void joinRoom(String roomId) {
    _currentRoomId = roomId;
    _socket?.emit('join_room', roomId);
  }

  @override
  void sendMessage(String roomId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    _socket?.emit('send_message', {
      'roomId': roomId,
      'senderId': userId,
      'senderModel': 'User',
      'text': content,
      'content': content,
    });
  }

  @override
  Stream<ChatMessageModel> get onMessageReceived => _messageController.stream;
}
