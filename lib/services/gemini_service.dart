import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

/// A friendly error the UI can show directly to the user.
class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}

class GeminiService {
  // Read at build time from --dart-define-from-file=env.json
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  // If you get a 404 "model not found", check the current name in Google AI Studio.
  static const String _model = 'gemini-3.5-flash';

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Sends the whole conversation so Gemini remembers earlier turns.
  Future<String> sendChat(List<Message> history) async {
    if (_apiKey.isEmpty) {
      throw GeminiException(
          'API key missing. Run the app with --dart-define-from-file=env.json');
    }

    // Convert our Message objects into Gemini's JSON format.
    // Gemini uses the roles "user" and "model".
    final contents = <Map<String, dynamic>>[];
    for (final m in history) {
      if (m.isError) continue; // never send error notices as history
      final role = m.isUser ? 'user' : 'model';
      if (contents.isEmpty && role == 'model') continue; // skip our greeting
      contents.add({
        'role': role,
        'parts': [
          {'text': m.text},
        ],
      });
    }

    final uri = Uri.parse('$_baseUrl/$_model:generateContent');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _apiKey,
            },
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {
                    'text': 'You are DocuChat, a friendly and concise AI '
                        'assistant. Give clear, accurate answers.',
                  },
                ],
              },
              'contents': contents,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw GeminiException(
              'Gemini returned no answer (the prompt may have been blocked).');
        }
        final parts = candidates[0]['content']?['parts'] as List?;
        final text = parts?.map((p) => p['text'] ?? '').join() ?? '';
        if (text.trim().isEmpty) {
          throw GeminiException('Gemini returned an empty answer. Try again.');
        }
        return text.trim();
      }

      // Turn HTTP status codes into human-friendly messages
      switch (response.statusCode) {
        case 400:
        case 403:
          throw GeminiException(
              'Request rejected (${response.statusCode}). Check your API key.');
        case 404:
          throw GeminiException(
              'Model "$_model" not found. Check the model name.');
        case 429:
          throw GeminiException(
              'Too many requests. Please wait a moment and try again.');
        default:
          throw GeminiException(
              'Server error (${response.statusCode}). Please try again.');
      }
    } on GeminiException {
      rethrow; // already friendly, pass it up unchanged
    } on TimeoutException {
      throw GeminiException('The request timed out. Check your connection.');
    } catch (_) {
      throw GeminiException('Network error. Check your internet connection.');
    }
  }
}