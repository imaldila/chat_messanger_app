import 'package:chat_messanger_app/components/chat_bubble.dart';
import 'package:chat_messanger_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String recevierUserEmail;
  final String recevierUserUid;
  const ChatPage(
      {super.key,
      required this.recevierUserEmail,
      required this.recevierUserUid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      await _chatService.sendMessage(
          message: message, receiverUid: widget.recevierUserUid);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recevierUserEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          const SizedBox(
            height: 25,
          )
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          _firebaseAuth.currentUser!.uid, widget.recevierUserUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text('Loading...'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred'),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = data['senderId'] == _firebaseAuth.currentUser!.uid;

    return Container(
      alignment: alignment ? Alignment.centerRight : Alignment.centerLeft,
      margin: alignment
          ? const EdgeInsets.only(left: 50)
          : const EdgeInsets.only(right: 50),
      padding: const EdgeInsets.all(8),
      child: ChatBubble(message: data['message']),
    );
  }
}
