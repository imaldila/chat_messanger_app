import 'package:chat_messanger_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //SEND MESSAGE
  Future<void> sendMessage(
      {required String message, required String receiverUid}) async {
    final user = _firebaseAuth.currentUser;
    final currentUserId = user!.uid;
    final currentUserEmail = user.email;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail!,
      receiverId: receiverUid,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverUid];
    ids.sort();
    final String chatId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .add(
          newMessage.toMap(),
        );
  }

  //GET MESSAGE
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();

    String chatRoomId = ids.join('_');
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
