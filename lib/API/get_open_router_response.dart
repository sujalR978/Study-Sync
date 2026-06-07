import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_sync/API/api_key.dart';

Future<String> getOpenRouterResponse(String userInput) async {
  const String endpoint = "https://openrouter.ai/api/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $API',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "model": "openai/gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": userInput},
    ],
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
