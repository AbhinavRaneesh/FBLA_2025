import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';
import 'package:student_learning_app/ai/repos/chat_repo.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart' show rootBundle;

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
 * - System prompt initialization from assets
 */
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  /**
   * Creates a new ChatBloc instance.
   * 
   * This constructor initializes the ChatBloc with the initial state and
   * registers event handlers for chat generation and history clearing.
   * It also loads the system prompt from assets to initialize the AI context.
   */
  ChatBloc() : super(ChatInitial()) {
    on<ChatGenerationNewTextMessageEvent>(_handleChatGeneration);
    on<ChatClearHistoryEvent>(_handleChatClearHistory);
    _initializeSystemPrompt();
  }

  /** List of chat messages in the current conversation */
  List<ChatMessageModel> messages = [];
  /** Flag indicating whether an AI response is currently being generated */
  bool generating = false;
  /** System prompt loaded from assets */
  String _systemPrompt = '';

  /**
   * Loads the system prompt from assets/prompts/setUpAi.txt
   * 
   * This method reads the AI training prompt from the app's assets and
   * stores it for use in initializing AI conversations. The prompt is
   * loaded once when the ChatBloc is created.
   */
  Future<void> _initializeSystemPrompt() async {
    try {
      _systemPrompt = await rootBundle.loadString('assets/prompts/setUpAi.txt');
      print('System prompt loaded successfully');
      print('System prompt length: ${_systemPrompt.length} characters');
      print('First 100 chars: ${_systemPrompt.substring(0, _systemPrompt.length > 100 ? 100 : _systemPrompt.length)}');
      print('Last 100 chars: ${_systemPrompt.substring(_systemPrompt.length > 100 ? _systemPrompt.length - 100 : 0)}');
    } catch (e) {
      print('Error loading system prompt: $e');
      _systemPrompt = 'You are QuestAI, an educational assistant in the EduQuest app.';
    }
  }

  /**
   * Handles chat message generation events.
   * 
   * This method processes user input messages and generates AI responses.
   * It manages the conversation flow by adding user messages, triggering
   * AI generation, and handling the response or any errors that occur.
   * 
   * The method follows this flow:
   * 1. Prepends system prompt if this is the first message
   * 2. Adds the user message to the conversation history
   * 3. Sets the generating flag to true and emits generating state
   * 4. Calls the AI repository to generate a response
   * 5. Adds the AI response to the conversation history
   * 6. Emits success state with updated messages
   * 7. Handles any errors by emitting error state
   * 
   * @param event The chat generation event containing the user's input message
   * @param emit The emitter for state updates
   */
  Future<void> _handleChatGeneration(
    ChatGenerationNewTextMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // If this is the first user message and we have a system prompt, prepend it
    if (messages.isEmpty && _systemPrompt.isNotEmpty) {
      print('Prepending system prompt (length: ${_systemPrompt.length})');
      messages.add(ChatMessageModel(
        role: "user",
        parts: [ChatPartModel(text: _systemPrompt)]
      ));
      // Add a simple acknowledgment from the model
      messages.add(ChatMessageModel(
        role: "model",
        parts: [ChatPartModel(text: "Understood. I am QuestAI, ready to assist users with the EduQuest app.")]
      ));
      print('System prompt added to messages. Total messages: ${messages.length}');
    }
    
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
