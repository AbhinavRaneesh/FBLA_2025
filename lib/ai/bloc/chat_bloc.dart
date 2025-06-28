import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';
import 'package:student_learning_app/ai/repos/chat_repo.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/**
 * A BLoC (Business Logic Component) that manages chat interactions with AI.
 * 
 * This class handles the state management for AI-powered chat functionality
 * in the EduQuest application. It manages message history, AI response generation,
 * and error handling for chat interactions.
 * 
 * The ChatBloc uses the BLoC pattern to separate business logic from UI,
 * providing a clean architecture for managing chat state and AI interactions.
 * 
 * Features:
 * - Message history management
 * - AI response generation
 * - Error handling and state management
 * - Chat history clearing
 * - Real-time state updates
 */
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  /**
   * Creates a new ChatBloc instance.
   * 
   * This constructor initializes the ChatBloc with the initial state and
   * registers event handlers for chat generation and history clearing.
   */
  ChatBloc() : super(ChatInitial()) {
    on<ChatGenerationNewTextMessageEvent>(_handleChatGeneration);
    on<ChatClearHistoryEvent>(_handleChatClearHistory);
  }

  /** List of chat messages in the current conversation */
  List<ChatMessageModel> messages = [];
  /** Flag indicating whether an AI response is currently being generated */
  bool generating = false;

  /**
   * Handles chat message generation events.
   * 
   * This method processes user input messages and generates AI responses.
   * It manages the conversation flow by adding user messages, triggering
   * AI generation, and handling the response or any errors that occur.
   * 
   * The method follows this flow:
   * 1. Adds the user message to the conversation history
   * 2. Sets the generating flag to true and emits generating state
   * 3. Calls the AI repository to generate a response
   * 4. Adds the AI response to the conversation history
   * 5. Emits success state with updated messages
   * 6. Handles any errors by emitting error state
   * 
   * @param event The chat generation event containing the user's input message
   * @param emit The emitter for state updates
   */
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

  /**
   * Handles chat history clearing events.
   * 
   * This method clears all messages from the conversation history and
   * resets the chat state to an empty conversation. It's useful for
   * starting fresh conversations or clearing sensitive information.
   * 
   * @param event The chat clear history event
   * @param emit The emitter for state updates
   */
  void _handleChatClearHistory(
    ChatClearHistoryEvent event,
    Emitter<ChatState> emit,
  ) {
    messages.clear(); // Clear all messages
    emit(ChatSuccessState(messages: []));
  }
}
