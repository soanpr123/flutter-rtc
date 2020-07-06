// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) =>
    MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  MessageModel({
    this.message,
  });

  List<Message> message;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        message:
            List<Message>.from(json["message"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": List<dynamic>.from(message.map((x) => x.toJson())),
      };
}

class Message {
  Message({
    this.id,
    this.displayName,
    this.message,
    this.time,
    this.isReading,
  });

  int id;
  String displayName;
  String message;
  int time;
  bool isReading;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        displayName: json["display_name"],
        message: json["message"],
        time: json["time"],
        isReading: json["isReading"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "display_name": displayName,
        "message": message,
        "time": time,
        "isReading": isReading,
      };
}
