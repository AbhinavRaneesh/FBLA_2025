part of 'chat_bloc.dart';

/**
 * Base class for all chat-related states in the ChatBloc.
 * 
 * This sealed class serves as the foundation for all states that can be
 * emitted by the ChatBloc. It ensures type safety and provides a clear
 * contract for state management in the BLoC pattern.
 */
@immutable
sealed class ChatState {}

/**
 * Initial state of the chat system.
 * 
 * This state represents the starting point of the chat conversation
 * before any messages have been exchanged. It indicates that the
 * chat system is ready to receive user input.
 */
final class ChatInitial extends ChatState {}

/**
 * State indicating that an AI response is currently being generated.
 * 
 * This state is emitted when the system is processing a user message
 * and generating an AI response. It includes the current conversation
 * history so the UI can display the ongoing conversation while waiting
 * for the AI response.
 * 
 * @param messages The current list of messages in the conversation
 */
class ChatGeneratingState extends ChatState {
  /** The current list of messages in the conversation */
  final List<ChatMessageModel> messages;
  
  /**
   * Creates a new ChatGeneratingState instance.
   * 
   * @param messages The current list of messages in the conversation
   */
  ChatGeneratingState({required this.messages});
}

/**
 * State indicating successful completion of a chat operation.
 * 
 * This state is emitted when an AI response has been successfully
 * generated and added to the conversation. It includes the updated
 * conversation history with the new AI response.
 * 
 * @param messages The updated list of messages including the new AI response
 */
class ChatSuccessState extends ChatState {
  /** The updated list of messages including the new AI response */
  final List<ChatMessageModel> messages;

  /**
   * Creates a new ChatSuccessState instance.
   * 
   * @param messages The updated list of messages including the new AI response
   */
  ChatSuccessState({required this.messages});
}

/**
 * State indicating an error occurred during chat operations.
 * 
 * This state is emitted when an error occurs during AI response generation
 * or other chat-related operations. It includes an error message that
 * can be displayed to the user to explain what went wrong.
 * 
 * @param message A descriptive error message explaining what went wrong
 */
class ChatErrorState extends ChatState {
  /** A descriptive error message explaining what went wrong */
  final String message;

  /**
   * Creates a new ChatErrorState instance.
   * 
   * @param message A descriptive error message explaining what went wrong
   */
  ChatErrorState({required this.message});
}