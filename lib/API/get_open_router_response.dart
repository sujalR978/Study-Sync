import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:study_sync/API/api_key.dart';

// --- STANDARD TEXT-ONLY CHAT COMPLETION ---
Future<String> getOpenRouterResponse(List<Map<String, String>> massage) async {
  const String endpoint = "https://openrouter.ai/api/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $API',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "model":
        "google/gemini-2.5-flash", // FIXED: Updated to an active, reliable text model
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
  List<XFile> images,
) async {
  const String endPoint = "https://openrouter.ai/api/v1/chat/completions";

  final headers = {
    'Authorization': 'Bearer $API_image',
    'Content-Type': 'application/json',
  };

  List<Map<String, dynamic>> message_images = [
    {"type": "text", "text": message},
  ];

  for (XFile image in images) {
    try {
      final bytes = await image.readAsBytes();
      final base64 = base64Encode(bytes);

      String extension = image.path.split('.').last.toLowerCase();
      if (extension == 'jpg') extension = 'jpeg';

      message_images.add({
        "type": "image_url",
        "image_url": {"url": "data:image/$extension;base64,$base64"},
      });
    } catch (e) {
      throw Exception('failed $e');
    }
  }

  final body = jsonEncode({
    "model": "openai/gpt-4o",
    "messages": [
      {
        "role": "user",
        "content":
            message_images, // FIXED: Changed from message_contents to your defined message_images list!
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

// --- FUTURE GEMINI SPECIFIC FUNCTION FRAMEWORK ---
Future<dynamic> getOpenRouterResponseForgemini() async {
  // Ready for implementation when needed
}
