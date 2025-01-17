import 'package:flutter/material.dart';
import 'package:gdsc/api/gemini_api.dart';

class ChatBot extends StatefulWidget {
  final String? userInput;

  const ChatBot({Key? key, this.userInput}) : super(key: key);

  @override
  _ChatBotState createState() => _ChatBotState();
}


class _ChatBotState extends State<ChatBot> {
  final TextEditingController textController = TextEditingController();
  final List<ChatMessage> chatHistory = [];
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    if (widget.userInput != null && widget.userInput!.isNotEmpty) {
      _sendMessage(widget.userInput!);
    }
  }

  void _sendMessage(String message) {
    String hiddenMessage =
        "answer for the above question by Imagining You are a mental health assistant chatbot designed to provide support and guidance to users experiencing stress or emotional difficulties. Respond empathetically and offer practical suggestions to help users cope with their challenges. Keep your responses strictly concise, only 2-3 lines long, and ensure they align with previous responses to maintain continuity in the conversation and answer.";
    if (message.isNotEmpty) {
      setState(() {
        chatHistory.add(ChatMessage(text: message, isUserMessage: true));
        textController.clear();
      });
      _fetchResponse(
          message, hiddenMessage); // Pass hidden message to _fetchResponse
    }
  }

  void _fetchResponse(String userInput, String hiddenInput) async {
    setState(() {
      isLoading = true; // Show loader
    });
    try {
      String response = await GeminiAPI.getGeminiData(
          userInput, hiddenInput); // Pass hidden input to API call
      setState(() {
        chatHistory.add(ChatMessage(text: response, isUserMessage: false));
        isLoading = false; // Hide loader
      });
    } catch (e) {
      print('Error fetching response: $e');
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Friend',
            style: TextStyle(fontFamily: 'Yesava')), // Change font
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF3EDE0), // Set background color to F3EDE0
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(chatMessage: chatHistory[index]);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () => _sendMessage(textController.text.trim()),
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(), // Show loader
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage chatMessage;

  const ChatBubble({Key? key, required this.chatMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: chatMessage.isUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: chatMessage.isUserMessage
                ? Colors.blue.withOpacity(0.8)
                : Colors.green.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            chatMessage.text,
            style: TextStyle(
                color: Colors.white, fontFamily: 'Yesava'), // Change font
          ),
        ),
      ),
    );
  }
}
