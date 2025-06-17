import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:student_learning_app/models/chat_message_model.dart';
import 'package:student_learning_app/utils/constants.dart';

class ChatRepo {
  static Future<String> chatTextGenerationRepo(
      List<ChatMessageModel> previousMessage) async {
    try {
      Dio dio = Dio();

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