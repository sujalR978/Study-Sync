import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:study_sync/API/api_key.dart';

Future<String> getOpenRouterResponse(List<Map<String, String>> massage) async {
  const String endpoint = "https://openrouter.ai/api/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $API',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "model": "anthropic/claude-sonnet-4",
    "messages": massage,
    "temperature": 0.7,
    "max_tokens": 200,
  });

  final response = await http.post(
    Uri.parse(endpoint),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Failed: ${response.statusCode} - ${response.body}');
  }
}

Future<dynamic> getOpenRouterResponseForGpt40(
  String userInput,
  List<XFile> images,
) async {
  const String endPoint = "https://openrouter.ai/api/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $API_image',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "model": "anthropic/claude-sonnet-4",
    "messages": [
      {
        "role": "user",
        "content": [
          {"type": "text", "text": userInput},
          {
            "type": "image_url",
            "image_url": {"url": images},
          },
        ],
      },
    ],
    "temperature": 0.7,
    "max_tokens": 200,
  });

  final response = await http.post(
    Uri.parse(endPoint),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Failed: ${response.statusCode} - ${response.body}');
  }
}
