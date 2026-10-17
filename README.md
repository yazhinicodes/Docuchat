# DocuChat

An AI-powered chat app built with Flutter and the Google Gemini API, with a WhatsApp-style interface.

## Screenshots

![Chat screen](screenshots/chat.png)
![Error handling](screenshots/error.png)

## Features

- Chat UI with user and AI message bubbles and timestamps
- Real AI answers from Gemini, with full conversation memory
- Typing indicator and auto-scroll to the latest message
- Friendly error handling: missing key, timeouts, rate limits, no internet
- Widget test covering the core send-message flow
- API key kept out of source control

## Tech Stack

- Flutter and Dart
- Google Gemini API (REST, via the `http` package)
- Material 3 theming

## Project Structure

    lib/
      main.dart                    App entry point and theme
      models/message.dart          Message data model
      services/gemini_service.dart Gemini API calls and error handling
      screens/chat_screen.dart     Chat screen and state
      widgets/message_bubble.dart  Reusable chat bubble

## Getting Started

1. Install Flutter and clone this repo.
2. Get a free API key from Google AI Studio.
3. Copy `env.example.json` to `env.json` and paste your key into it.
4. Run:

       flutter pub get
       flutter run --dart-define-from-file=env.json

## What I Learned

This is my first Flutter project. I learned widgets and the widget tree,
StatelessWidget vs StatefulWidget, state management with setState,
async/await, consuming a REST API from a mobile app, and writing widget tests.

## Future Improvements

- Backend proxy so the API key never ships inside the app
- Markdown rendering for AI answers
- Chat history saved on the device
- Streaming responses