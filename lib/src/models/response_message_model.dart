// To parse this JSON data, do
//
//     final responseMessageModel = responseMessageModelFromJson(jsonString);

import 'dart:convert';

List<dynamic> responseMessageModelFromJson(String str) => List<dynamic>.from(json.decode(str).map((x) => x));

String responseMessageModelToJson(List<dynamic> data) => json.encode(List<dynamic>.from(data.map((x) => x)));

class ResponseMessageModelClass {
  ResponseMessageModelClass({
    this.message,
    this.username,
    this.verif,
    this.room,
    this.userid,
    this.isRoomMultiUsr,
    this.time,
  });

  String message;
  String username;
  int verif;
  int room;
  int userid;
  bool isRoomMultiUsr;
  int time;

  factory ResponseMessageModelClass.fromJson(Map<String, dynamic> json) => ResponseMessageModelClass(
    message: json["message"],
    username: json["username"],
    verif: json["verif"],
    room: json["room"],
    userid: json["userid"],
    isRoomMultiUsr: json["isRoomMultiUsr"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "username": username,
    "verif": verif,
    "room": room,
    "userid": userid,
    "isRoomMultiUsr": isRoomMultiUsr,
    "time": time,
  };
}
