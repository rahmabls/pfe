import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userMessage = _controller.text;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage}),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RAW BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String botReply =
            data["response"]?.toString() ??
            data["error"]?.toString() ??
            "Réponse vide du serveur";

        setState(() {
          _messages.add(ChatMessage(text: botReply, isUser: false));
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "Erreur HTTP ${response.statusCode}",
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      print("ERREUR: $e");

      setState(() {
        _messages.add(
          ChatMessage(
            text: "Impossible de contacter le serveur.",
            isUser: false,
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF6A4CFF)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message.text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1F3B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1A6E),
        title: const Text("Assistant IA"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Posez votre question...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
