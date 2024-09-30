import 'package:flutter/material.dart';

class ChatMessage {
  final String messageContent;
  final String messageType;

  ChatMessage({required this.messageContent, required this.messageType});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [
    // ChatMessage(messageContent: "Hello, John", messageType: "receiver"),
    // ChatMessage(messageContent: "Hi, Jane", messageType: "sender"),
    // ChatMessage(messageContent: "How are you?", messageType: "receiver"),
    // ChatMessage(messageContent: "I'm good, how about you?", messageType: "sender"),
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text;
    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add(ChatMessage(messageContent: text, messageType: "sender"));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body:

      Column(
        children: [
          Expanded(
            child:
            Text("fgggg")
            // ListView.builder(
            //   itemCount: messages.length,
            //   itemBuilder: (context, index) {
            //     final message = messages[index];
            //     return Container(
            //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            //       alignment: message.messageType == "sender" ? Alignment.topRight : Alignment.topLeft,
            //       child: Container(
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(20),
            //           color: message.messageType == "sender" ? Colors.orange : Colors.grey.shade200,
            //         ),
            //         padding: EdgeInsets.all(16),
            //         child: Text(message.messageContent, style: TextStyle(color: Colors.black),),
            //       ),
            //     );
            //   },
            // ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter message",
                      fillColor: Colors.grey[800],
                      filled: true,
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
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



// *******************************************************************************







