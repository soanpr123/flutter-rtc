// To parse this JSON data, do
//
//     final proffile = proffileFromJson(jsonString);

import 'dart:convert';

Proffile proffileFromJson(String str) => Proffile.fromJson(json.decode(str));

String proffileToJson(Proffile data) => json.encode(data.toJson());

class Proffile {
  Proffile({
    this.message,
    this.infoUser,
    this.infoFriends,
    this.infoInvits,
    this.avatarUser,
  });

  String message;
  InfoUser infoUser;
  List<Info> infoFriends;
  List<Info> infoInvits;
  String avatarUser;

  factory Proffile.fromJson(Map<String, dynamic> json) => Proffile(
    message: json["message"],
    infoUser: InfoUser.fromJson(json["infoUser"]),
    infoFriends: List<Info>.from(json["infoFriends"].map((x) => Info.fromJson(x))),
    infoInvits: List<Info>.from(json["infoInvits"].map((x) => Info.fromJson(x))),
    avatarUser: json["avatarUser"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "infoUser": infoUser.toJson(),
    "infoFriends": List<dynamic>.from(infoFriends.map((x) => x.toJson())),
    "infoInvits": List<dynamic>.from(infoInvits.map((x) => x.toJson())),
    "avatarUser": avatarUser,
  };
}

class Info {
  Info({
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

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    displayName: json["display_name"],
    status: json["status"],
    avatars: json["avatars"] == null ? null : json["avatars"],
    email: json["email"] == null ? null : json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "display_name": displayName,
    "status": status,
    "avatars": avatars == null ? null : avatars,
    "email": email == null ? null : email,
  };
}

class InfoUser {
  InfoUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.company,
    this.displayName,
    this.bio,
    this.status,
    this.friendsList,
    this.invitations,
    this.avatars,
  });

  int id;
  String firstName;
  String lastName;
  String email;
  String phone;
  dynamic company;
  String displayName;
  dynamic bio;
  String status;
  String friendsList;
  String invitations;
  String avatars;

  factory InfoUser.fromJson(Map<String, dynamic> json) => InfoUser(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    company: json["company"],
    displayName: json["display_name"],
    bio: json["bio"],
    status: json["status"],
    friendsList: json["friends_list"],
    invitations: json["invitations"],
    avatars: json["avatars"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "company": company,
    "display_name": displayName,
    "bio": bio,
    "status": status,
    "friends_list": friendsList,
    "invitations": invitations,
    "avatars": avatars,
  };
}
