class Message {
  final String text;
  final bool isUser; // true = sent by user, false = sent by AI
  final DateTime time;

  const Message({
    required this.text,
    required this.isUser,
    required this.time,
  });
}