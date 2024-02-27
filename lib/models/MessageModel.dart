import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {

  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel({this.messageId, this.sender, this.seen, this.createdOn, this.text});

  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    seen = map["seen"];
    text = map["text"];
    createdOn = (map["createdOn"] as Timestamp).toDate();
    messageId = map["messageid"];
  }

  Map<String, dynamic> toMap() {
    return{
      "sender" : sender,
      "text" : text,
      "seen" : seen,
      "createdOn" : createdOn,
      "messageid" : messageId
    };
  }

}