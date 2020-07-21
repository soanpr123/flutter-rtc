// To parse this JSON data, do
//
//     final appectInvication = appectInvicationFromJson(jsonString);

import 'dart:convert';

AppectInvication appectInvicationFromJson(String str) => AppectInvication.fromJson(json.decode(str));

String appectInvicationToJson(AppectInvication data) => json.encode(data.toJson());

class AppectInvication {
  AppectInvication({
    this.message,
    this.newFriendsInfo,
    this.newInvitsInfo,
  });

  String message;
  List<NewFriendsInfo> newFriendsInfo;
  List<dynamic> newInvitsInfo;

  factory AppectInvication.fromJson(Map<String, dynamic> json) => AppectInvication(
    message: json["message"],
    newFriendsInfo: List<NewFriendsInfo>.from(json["newFriendsInfo"].map((x) => NewFriendsInfo.fromJson(x))),
    newInvitsInfo: List<dynamic>.from(json["newInvitsInfo"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "newFriendsInfo": List<dynamic>.from(newFriendsInfo.map((x) => x.toJson())),
    "newInvitsInfo": List<dynamic>.from(newInvitsInfo.map((x) => x)),
  };
}

class NewFriendsInfo {
  NewFriendsInfo({
    this.firstName,
    this.lastName,
    this.status,
    this.avatars,
  });

  String firstName;
  String lastName;
  String status;
  String avatars;

  factory NewFriendsInfo.fromJson(Map<String, dynamic> json) => NewFriendsInfo(
    firstName: json["first_name"],
    lastName: json["last_name"],
    status: json["status"],
    avatars: json["avatars"],
  );

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "status": statusValues.reverse[status],
    "avatars": avatars,
  };
}

enum Status { OFFLINE, ONLINE }

final statusValues = EnumValues({
  "Offline": Status.OFFLINE,
  "Online": Status.ONLINE
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
