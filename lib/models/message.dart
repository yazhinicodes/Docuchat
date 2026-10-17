class Message {
  final String text;
  final bool isUser; // true = sent by user, false = sent by AI
  final DateTime time;
  final bool isError; // true = an error notice, not a real AI answer

  const Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
  });
}