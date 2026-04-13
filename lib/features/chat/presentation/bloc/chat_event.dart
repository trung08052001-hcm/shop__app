part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatStarted extends ChatEvent {}

class ChatMessageSent extends ChatEvent {
  final String content;
  const ChatMessageSent(this.content);

  @override
  List<Object> get props => [content];
}

class ChatMessageReceived extends ChatEvent {
  final ChatMessage message;
  const ChatMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class ChatStopped extends ChatEvent {}
