import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';
import 'package:student_learning_app/ai/repos/chat_repo.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatGenerationNewTextMessageEvent>(_handleChatGeneration);
    on<ChatClearHistoryEvent>(_handleChatClearHistory);
  }

  List<ChatMessageModel> messages = [];
  bool generating = false;

  Future<void> _handleChatGeneration(
    ChatGenerationNewTextMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    messages.add(ChatMessageModel(
        role: "user", parts: [ChatPartModel(text: event.inputMessage)]));
    generating = true;
    emit(ChatGeneratingState(messages: messages));
    try {
      // Get AI response
      final generatedText = await ChatRepo.chatTextGenerationRepo(messages);

      if (generatedText.isEmpty) {
        throw Exception("Empty response from AI");
      }

      // Add AI response
      messages.add(ChatMessageModel(
        role: "model",
        parts: [ChatPartModel(text: generatedText)],
      ));
      generating = false;
      emit(ChatSuccessState(messages: messages));
    } catch (e) {
      generating = false;
      emit(ChatErrorState(message: "Error: ${e.toString()}"));
    }
  }

  void _handleChatClearHistory(
    ChatClearHistoryEvent event,
    Emitter<ChatState> emit,
  ) {
    messages.clear(); // Clear all messages
    emit(ChatSuccessState(messages: []));
  }
}
