import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get stream of all users except current user
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Get user data
        final userData = doc.data();

        // Return user data
        return userData;
      }).toList();
    });
  }

  // Get unread message count between two users
  Future<int> getUnreadMessageCount(String senderId, String receiverId) async {
    try {
      // Create chat room ID (sorted to ensure consistency)
      List<String> ids = [senderId, receiverId];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Query messages that are from the sender and not read by receiver
      QuerySnapshot snapshot = await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .where("senderID", isEqualTo: senderId)
          .where("seen", isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Error getting unread messages: $e");
      return 0;
    }
  }

  // send message
  Future<void> sendMessage(String receiverID, String message,
      {String? imageUrl}) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Map<String, dynamic> newMessage = {
      "senderID": currentUserID,
      "senderEmail": currentUserEmail,
      "receiverID": receiverID,
      "message": message,
      "timestamp": timestamp,
      "seen": false,
      "type": imageUrl != null ? "image" : "text",
    };

    // Add image URL if provided
    if (imageUrl != null) {
      newMessage["imageUrl"] = imageUrl;
    }

    // construct chat room ID for the two users (sorted to ensure consistency)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensures the chatroomID is the same for any pair)
    String chatroomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .add(newMessage);
  }

  // Send image message
  Future<void> sendImageMessage(String receiverID, String imageUrl,
      {String message = ""}) async {
    return sendMessage(receiverID, message, imageUrl: imageUrl);
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // construct chat room ID for the two users (sorted to ensure consistency)
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatroomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Helper method to generate a consistent chat room ID
  String getChatRoomID(String userID1, String userID2) {
    // Sort the IDs to ensure consistency
    List<String> ids = [userID1, userID2];
    ids.sort();
    return ids.join('_');
  }

  // Get stream of unseen messages
  Stream<QuerySnapshot> getUnseenMessages(
      String currentUserID, String otherUserID) {
    // Get the chat room ID
    String chatRoomID = getChatRoomID(currentUserID, otherUserID);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .where('senderID', isEqualTo: otherUserID)
        .where('seen', isEqualTo: false)
        .snapshots();
  }

  // Get last message for a chat
  Stream<QuerySnapshot> getLastMessage(
      String currentUserID, String otherUserID) {
    String chatRoomID = getChatRoomID(currentUserID, otherUserID);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String senderID, String receiverID) async {
    // Get the chat room ID
    String chatRoomID = getChatRoomID(receiverID, senderID);

    // Get unread messages
    QuerySnapshot unreadMessages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .where('senderID', isEqualTo: senderID)
        .where('seen', isEqualTo: false)
        .get();

    // Update each message
    for (var doc in unreadMessages.docs) {
      await doc.reference.update({'seen': true});
    }
  }

  // Clear chat history
  Future<void> clearChatHistory(String otherUserID) async {
    try {
      // Get current user ID
      final String currentUserID = _auth.currentUser!.uid;

      // Generate chatroom ID
      List<String> ids = [currentUserID, otherUserID];
      ids.sort();
      String chatroomID = ids.join('_');

      // Get all messages in the chat
      QuerySnapshot messages = await _firestore
          .collection("chat_rooms")
          .doc(chatroomID)
          .collection("messages")
          .get();

      // Delete each message
      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // Return success
      return Future.value();
    } catch (e) {
      // Handle errors
      print("Error clearing chat history: $e");
      throw Exception("Failed to clear chat history. Please try again.");
    }
  }
}
