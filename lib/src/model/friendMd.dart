// To parse this JSON data, do
//
//     final friendMd = friendMdFromJson(jsonString);

import 'dart:convert';

FriendMd friendMdFromJson(String str) => FriendMd.fromJson(json.decode(str));

String friendMdToJson(FriendMd data) => json.encode(data.toJson());

class FriendMd {
  FriendMd({
    this.message,
    this.status,
  });

  String message;
  List<dynamic> data;
  List<StatusElement> status;

  factory FriendMd.fromJson(Map<String, dynamic> json) => FriendMd(
    message: json["message"],
    status: List<StatusElement>.from(json["status"].map((x) => StatusElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x)),
    "status": List<dynamic>.from(status.map((x) => x.toJson())),
  };
}

class StatusElement {
  StatusElement({
    this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    this.status,
    this.avatars,
    this.email,
  });

  int id;
  String firstName;
  String lastName;
  String displayName;
  String status;
  String avatars;
  String email;

  factory StatusElement.fromJson(Map<String, dynamic> json) => StatusElement(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    displayName: json["display_name"],
    status: json["status"],
    avatars: json["avatars"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "display_name": displayName,
    "status":status,
    "avatars": avatars,
    "email": email,
  };
}

enum StatusEnum { OFFLINE, ONLINE }

final statusEnumValues = EnumValues({
  "Offline": StatusEnum.OFFLINE,
  "Online": StatusEnum.ONLINE
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
