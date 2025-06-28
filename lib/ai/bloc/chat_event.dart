part of 'chat_bloc.dart';

/**
 * Base class for all chat-related events in the ChatBloc.
 * 
 * This sealed class serves as the foundation for all events that can be
 * dispatched to the ChatBloc. It ensures type safety and provides a clear
 * contract for event handling in the BLoC pattern.
 */
@immutable
sealed class ChatEvent {}

/**
 * Event for generating a new AI response to a user message.
 * 
 * This event is dispatched when a user sends a message and an AI response
 * needs to be generated. It contains the user's input message that will
 * be processed by the AI system.
 * 
 * @param inputMessage The text message from the user that requires an AI response
 */
class ChatGenerationNewTextMessageEvent extends ChatEvent {
  /** The text message from the user that requires an AI response */
  final String inputMessage;

  /**
   * Creates a new ChatGenerationNewTextMessageEvent instance.
   * 
   * @param inputMessage The text message from the user that requires an AI response
   */
  ChatGenerationNewTextMessageEvent({required this.inputMessage});
}

/**
 * Event for clearing the chat conversation history.
 * 
 * This event is dispatched when the user wants to clear all messages
 * from the current conversation. It resets the chat to an empty state,
 * useful for starting fresh conversations or clearing sensitive information.
 */
class ChatClearHistoryEvent extends ChatEvent {}
