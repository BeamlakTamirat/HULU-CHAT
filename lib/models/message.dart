import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String recieverID;
  final String message;
  final Timestamp timestamp;
  final bool isRead;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.recieverID,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'recieverID': recieverID,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}


//42:50