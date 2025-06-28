import 'dart:convert';

/**
 * A data model representing a chat message in the AI conversation system.
 * 
 * This class encapsulates a single message in a chat conversation, including
 * the role of the sender (user or AI model) and the content parts of the message.
 * It provides JSON serialization and deserialization capabilities for API communication.
 * 
 * The ChatMessageModel is used throughout the AI chat system to represent
 * both user input and AI responses in a structured format.
 * 
 * @param role The role of the message sender ("user" or "model")
 * @param parts A list of message parts containing the actual content
 */
class ChatMessageModel {
  /** The role of the message sender ("user" or "model") */
  final String role;
  /** A list of message parts containing the actual content */
  final List<ChatPartModel> parts;

  /**
   * Creates a new ChatMessageModel instance.
   * 
   * @param role The role of the message sender ("user" or "model")
   * @param parts A list of message parts containing the actual content
   */
  ChatMessageModel({
    required this.role,
    required this.parts,
  });

  /**
   * Converts the ChatMessageModel to a JSON representation.
   * 
   * This method serializes the message model for API communication,
   * converting all parts to their JSON representation.
   * 
   * @return A Map containing the JSON representation of the message
   */
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'parts': parts.map((part) => part.toJson()).toList(),
    };
  }

  /**
   * Creates a ChatMessageModel from a JSON representation.
   * 
   * This factory method deserializes a JSON object into a ChatMessageModel,
   * parsing the role and converting all parts from their JSON representation.
   * 
   * @param json A Map containing the JSON representation of the message
   * @return A new ChatMessageModel instance
   */
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] as String,
      parts: (json['parts'] as List)
          .map((part) => ChatPartModel.fromJson(part as Map<String, dynamic>))
          .toList(),
    );
  }
}

/**
 * A data model representing a part of a chat message.
 * 
 * This class represents individual content parts within a chat message.
 * Currently, it primarily handles text content, but the structure allows
 * for future expansion to support other content types (images, code, etc.).
 * 
 * The ChatPartModel provides JSON serialization and deserialization
 * capabilities for API communication.
 * 
 * @param text The text content of this message part
 */
class ChatPartModel {
  /** The text content of this message part */
  final String text;

  /**
   * Creates a new ChatPartModel instance.
   * 
   * @param text The text content of this message part
   */
  ChatPartModel({
    required this.text,
  });

  /**
   * Converts the ChatPartModel to a JSON representation.
   * 
   * This method serializes the message part for API communication.
   * 
   * @return A Map containing the JSON representation of the message part
   */
  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }

  /**
   * Creates a ChatPartModel from a JSON representation.
   * 
   * This factory method deserializes a JSON object into a ChatPartModel.
   * 
   * @param json A Map containing the JSON representation of the message part
   * @return A new ChatPartModel instance
   */
  factory ChatPartModel.fromJson(Map<String, dynamic> json) {
    return ChatPartModel(
      text: json['text'] as String,
    );
  }
}
