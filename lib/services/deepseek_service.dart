import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekService {
  static final String apiKey = dotenv.env['API_KEY'] ?? '';
  static final String endpoint = dotenv.env['ENDPOINT'] ?? '';

  static Future<Map<String, String>> getAIMove(
    String fen,
    String lastPlayerMove,
  ) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "openai/gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content":
                "You are DeepKing, a competitive and witty chess AI. Given a FEN and the player’s last move, respond with the best move (e.g. e2e4) and a one-liner taunt or comment.",
          },
          {
            "role": "user",
            "content":
                "FEN: $fen\nPlayer just played: $lastPlayerMove\nWhat is your next move and your response?",
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final message = json['choices'][0]['message']['content'] as String;

      final regex = RegExp(r'([a-h][1-8][a-h][1-8])');
      final match = regex.firstMatch(message);
      final move = match?.group(1) ?? "";
      final chat = message.replaceAll(move, "").trim();

      return {"move": move, "chat": chat};
    } else {
      throw Exception("DeepSeek API failed: ${response.body}");
    }
  }
}
