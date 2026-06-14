import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_sync/API/api_key.dart';

// --- STANDARD TEXT-ONLY CHAT COMPLETION ---
Future<String> getOpenRouterResponse(List<Map<String, String>> massage) async {
  const String endpoint = "https://openrouter.ai/api/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $API',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "model": "google/gemini-2.5-flash",
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

// --- MULTIMODAL IMAGE + TEXT COMPLETION (GPT-4o) ---
Future<dynamic> getOpenRouterResponseForGpt40(
  String message,
  List<String> base64Images,
) async {
  const String endPoint = "https://openrouter.ai/api/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $API_image',
    'Content-Type': 'application/json',
  };

  List<Map<String, dynamic>> message_images = [
    {"type": "text", "text": message},
  ];

  // Map pre-converted strings directly into your payload structures
  for (String base64DataUri in base64Images) {
    message_images.add({
      "type": "image_url",
      "image_url": {"url": base64DataUri},
    });
  }

  final body = jsonEncode({
    "model": "google/gemini-2.5-flash:free",
    "messages": [
      {"role": "user", "content": message_images},
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
