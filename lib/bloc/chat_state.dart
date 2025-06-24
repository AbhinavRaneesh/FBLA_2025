part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

class ChatGeneratingState extends ChatState {
  final List<ChatMessageModel> messages;
  ChatGeneratingState({required this.messages});
}

class ChatSuccessState extends ChatState {
  final List<ChatMessageModel> messages;

  ChatSuccessState({required this.messages});
}

class ChatErrorState extends ChatState {
  final String message;

  ChatErrorState({required this.message});
}