import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:shop_app/features/chat/domain/entities/chat_message.dart';
import 'package:shop_app/features/chat/domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription? _messageSubscription;

  ChatBloc({required this.chatRepository}) : super(const ChatState()) {
    on<ChatStarted>(_onChatStarted);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatMessageReceived>(_onChatMessageReceived);
    on<ChatStopped>(_onChatStopped);
  }

  Future<void> _onChatStarted(ChatStarted event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));

    final result = await chatRepository.getMyRoomId();
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: ChatStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (roomId) async {
        // connectAndJoin: kết nối socket VÀ join room sau khi connected
        chatRepository.connectAndJoin(roomId);

        final messagesResult = await chatRepository.getMessages(roomId);
        messagesResult.fold(
          (failure) {
            emit(state.copyWith(
              status: ChatStatus.failure,
              errorMessage: failure.message,
            ));
          },
          (messages) {
            // API trả về cũ→mới (ascending). Với reverse:true ListView, index 0 = bottom.
            // Nên đảo ngược để mới nhất ở đầu list (= hiển thị ở dưới cùng)
            emit(state.copyWith(
              status: ChatStatus.success,
              roomId: roomId,
              messages: messages.reversed.toList(),
            ));
          },

        );

        _messageSubscription?.cancel();
        _messageSubscription = chatRepository.onMessageReceived.listen((message) {
          add(ChatMessageReceived(message));
        });
      },
    );
  }

  void _onChatMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    if (state.roomId == null) return;

    // Optimistic update: hiển thị ngay tin nhắn của user trước khi socket phản hồi
    final optimisticMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: state.roomId!,
      senderType: 'User',
      senderId: '',
      content: event.content,
      status: 'sending',
      createdAt: DateTime.now(),
    );
    final withOptimistic = [optimisticMsg, ...state.messages];
    emit(state.copyWith(messages: withOptimistic));

    chatRepository.sendMessage(state.roomId!, event.content);
  }

  void _onChatMessageReceived(ChatMessageReceived event, Emitter<ChatState> emit) {
    final newMsg = event.message;
    final current = List<ChatMessage>.from(state.messages);

    // Nếu có tin nhắn tạm (temp_) cùng content → thay thế thay vì thêm mới
    final tempIndex = current.indexWhere(
      (m) => m.id.startsWith('temp_') && m.content == newMsg.content && m.senderType == newMsg.senderType,
    );

    if (tempIndex != -1) {
      current[tempIndex] = newMsg;
    } else {
      current.insert(0, newMsg);
    }

    emit(state.copyWith(messages: current));
  }


  void _onChatStopped(ChatStopped event, Emitter<ChatState> emit) {
    _messageSubscription?.cancel();
    chatRepository.disconnectSocket();
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    chatRepository.disconnectSocket();
    return super.close();
  }
}
