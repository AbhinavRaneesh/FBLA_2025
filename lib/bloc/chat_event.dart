part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class ChatGenerationNewTextMessageEvent extends ChatEvent {
  final String inputMessage;

  ChatGenerationNewTextMessageEvent({
    required this.inputMessage
  });
}

class ChatClearHistoryEvent extends ChatEvent {}