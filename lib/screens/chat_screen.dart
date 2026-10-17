import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // The app's STATE: the list of messages and whether the AI is "typing"
  final List<Message> _messages = [
    Message(
      text: "Hi! I'm DocuChat. Ask me anything.",
      isUser: false,
      time: DateTime.now(),
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _gemini = GeminiService();
  bool _isTyping = false;

  @override
  void dispose() {
    // Free the resources when the screen is closed (prevents memory leaks)
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Wait until the new message is drawn, then scroll down
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

   Future<void> _sendMessage() async {
     final text = _controller.text.trim();
     if (text.isEmpty || _isTyping) return;

     // 1. Add the user's message and show the typing indicator
     setState(() {
       _messages.add(Message(text: text, isUser: true, time: DateTime.now()));
       _isTyping = true;
     });
     _controller.clear();
     _scrollToBottom();

     // 2. Ask Gemini (the service always throws a friendly GeminiException)
     Message reply;
     try {
       final answer = await _gemini.sendChat(_messages);
       reply = Message(text: answer, isUser: false, time: DateTime.now());
     } on GeminiException catch (e) {
       reply = Message(
        text: e.message,
        isUser: false,
        time: DateTime.now(),
        isError: true,
       );
     }
     if (!mounted) return; // screen may have closed while waiting

     // 3. Show the reply and hide the typing indicator
     setState(() {
       _messages.add(reply);
       _isTyping = false;
     });
     _scrollToBottom();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DocuChat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Text('AI assistant',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // The message list takes all the space above the input bar
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const _TypingIndicator();
                }
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(), // Enter key sends too
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F8),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF4F46E5),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('DocuChat is typing...',
            style: TextStyle(color: Colors.black45, fontSize: 13)),
      ),
    );
  }
}