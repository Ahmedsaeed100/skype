import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? senderId;
  String? receiverId;
  String? type;
  String? message;
  FieldValue? timestamp;
  String? photoUrl;

  Message({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
  });

  //Will be only called when you wish to send an image
  // named constructor
  Message.imageMessage(
      {this.senderId,
      this.receiverId,
      this.message,
      this.type,
      this.timestamp,
      this.photoUrl});

  Map toMap() {
    var map = <String, dynamic>{};
    map['senderId'] = senderId;
    map['receiverId'] = receiverId;
    map['type'] = type;
    map['message'] = message;
    map['timestamp'] = timestamp;
    return map;
  }

  // named constructor
  Message.fromMap(Map<String, dynamic> map) {
    senderId = map['senderId'];
    receiverId = map['receiverId'];
    type = map['type'];
    message = map['message'];
    timestamp = map['timestamp'];
  }
}
