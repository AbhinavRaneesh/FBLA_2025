import 'dart:convert';

class ChatMessageModel {
  final String role;
  final List<ChatPartModel> parts;

  ChatMessageModel({
    required this.role,
    required this.parts,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'parts': parts.map((part) => part.toJson()).toList(),
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] as String,
      parts: (json['parts'] as List)
          .map((part) => ChatPartModel.fromJson(part as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatPartModel {
  final String text;

  ChatPartModel({
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }

  factory ChatPartModel.fromJson(Map<String, dynamic> json) {
    return ChatPartModel(
      text: json['text'] as String,
    );
  }
}
