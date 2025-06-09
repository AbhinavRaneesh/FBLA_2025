import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:student_learning_app/models/chat_message_model.dart';
import 'package:student_learning_app/utils/constants.dart';

class ChatRepo {
  static Future<String> chatTextGenerationRepo(List<ChatMessageModel> previousMessage) async {
    try {
      Dio dio = Dio();

      final response = await dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}",
        data: {
          "contents": previousMessage.map((e) => e.toJson()).toList(),
          "generationConfig": {
            "responseMimeType": "text/plain"
          }
        }
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data['candidates'].first['content']['parts'].first['text'];
      }
      return '';

    } catch (e) {
      log(e.toString());
      return ' ';
    }
  }
}