import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:study_sync/API/api_key.dart';

Future<String> getOpenRouterResponse(String userInput) async {
  const String endpoint = "https://openrouter.ai/api/v1/chat/completions";

  final header = {
    'Authorization': 'Bearer $API',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    'model': 'riverflow-v2.5-pro',
    'prompt': userInput,
    'max_tokens': 100,
    'temperature': 0.7,
  });

  final Response = await http.post(
    Uri.parse(endpoint),
    headers: header,
    body: body,
  );

  if (Response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(Response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Failed to get response ${Response.body}');
  }
}
