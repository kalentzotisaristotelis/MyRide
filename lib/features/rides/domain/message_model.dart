import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String docId) {
    // Ελέγχουμε αν το timestamp υπάρχει, αλλιώς βάζουμε την τρέχουσα ώρα
    // ώστε να μην κρασάρει η εφαρμογή μέχρι να απαντήσει ο server.
    final timestamp = map['timestamp'] as Timestamp?;

    return Message(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Rider',
      text: map['text'] ?? '',
      timestamp: timestamp != null ? timestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(), // Χρήση χρόνου από τον Server
    };
  }
}