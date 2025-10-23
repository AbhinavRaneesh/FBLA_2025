import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';
import 'package:student_learning_app/ai/utils/constants.dart';

/**
 * A repository class that handles communication with the Google Gemini AI API.
 * 
 * This class provides a clean interface for generating AI responses using the
 * Google Gemini 2.0 Flash model. It handles HTTP requests, response parsing,
 * and error handling for AI chat functionality.
 * 
 * The ChatRepo uses the Dio HTTP client for making API requests and provides
 * comprehensive logging for debugging and monitoring purposes.
 * 
 * Features:
 * - AI text generation using Google Gemini API
 * - Comprehensive error handling and logging
 * - Response validation and parsing
 * - Support for conversation context
 */
class ChatRepo {
  /**
   * Generates AI text responses using the Google Gemini API.
   * 
   * This method sends a conversation history to the Google Gemini 2.0 Flash
   * model and returns the generated response. It handles the complete API
   * communication flow including request formatting, response parsing, and
   * error handling.
   * 
   * The method performs the following steps:
   * 1. Creates a Dio HTTP client instance
   * 2. Formats the conversation history for the API
   * 3. Sends a POST request to the Gemini API
   * 4. Validates the response status code
   * 5. Parses the response structure to extract the generated text
   * 6. Handles various error conditions with detailed logging
   * 
   * The API request includes:
   * - Previous conversation messages for context
   * - Generation configuration specifying text/plain response format
   * - API key for authentication
   * 
   * @param previousMessage A list of previous chat messages providing context for the AI
   * @return A Future that completes with the generated AI response text, or empty string on error
   */
  static Future<String> chatTextGenerationRepo(
      List<ChatMessageModel> previousMessage) async {
    try {
      Dio dio = Dio();

      // Debug logging to track what's being sent
      print('Sending ${previousMessage.length} messages to AI');
      for (int i = 0; i < previousMessage.length; i++) {
        final msg = previousMessage[i];
        final text = msg.parts.isNotEmpty ? msg.parts.first.text : '';
        print('Message $i [${msg.role}]: ${text.length} chars - "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
      }

      final response = await dio.post(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}",
          data: {
            "contents": previousMessage.map((e) => e.toJson()).toList(),
            "generationConfig": {"responseMimeType": "text/plain"}
          });

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        if (data == null) {
          log('Response data is null');
          return '';
        }

        final candidates = data['candidates'];
        if (candidates == null || candidates.isEmpty) {
          log('No candidates in response');
          return '';
        }

        final firstCandidate = candidates.first;
        if (firstCandidate == null) {
          log('First candidate is null');
          return '';
        }

        final content = firstCandidate['content'];
        if (content == null) {
          log('Content is null');
          return '';
        }

        final parts = content['parts'];
        if (parts == null || parts.isEmpty) {
          log('No parts in content');
          return '';
        }

        final firstPart = parts.first;
        if (firstPart == null) {
          log('First part is null');
          return '';
        }

        final text = firstPart['text'];
        if (text == null) {
          log('Text is null');
          return '';
        }

        return text.toString();
      }
      return '';
    } catch (e) {
      log('Error in chatTextGenerationRepo: ${e.toString()}');
      return '';
    }
  }
}
