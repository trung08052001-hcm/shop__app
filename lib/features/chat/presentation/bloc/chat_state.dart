part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? roomId;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.roomId,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? roomId,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      roomId: roomId ?? this.roomId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, roomId, errorMessage];
}
