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
  List<InfoFriend> infoFriends;
  List<dynamic> infoInvits;
  String avatarUser;

  factory Proffile.fromJson(Map<String, dynamic> json) => Proffile(
    message: json["message"],
    infoUser: InfoUser.fromJson(json["infoUser"]),
    infoFriends: List<InfoFriend>.from(json["infoFriends"].map((x) => InfoFriend.fromJson(x))),
    infoInvits: List<dynamic>.from(json["infoInvits"].map((x) => x)),
    avatarUser: json["avatarUser"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "infoUser": infoUser.toJson(),
    "infoFriends": List<dynamic>.from(infoFriends.map((x) => x.toJson())),
    "infoInvits": List<dynamic>.from(infoInvits.map((x) => x)),
    "avatarUser": avatarUser,
  };
}

class InfoFriend {
  InfoFriend({
    this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    this.status,
    this.avatars,
  });

  int id;
  String firstName;
  String lastName;
  String displayName;
  Status status;
  String avatars;

  factory InfoFriend.fromJson(Map<String, dynamic> json) => InfoFriend(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    displayName: json["display_name"],
    status: statusValues.map[json["status"]],
    avatars: json["avatars"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "display_name": displayName,
    "status": statusValues.reverse[status],
    "avatars": avatars,
  };
}

enum Status { OFFLINE, ONLINE }

final statusValues = EnumValues({
  "Offline": Status.OFFLINE,
  "Online": Status.ONLINE
});

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
  String company;
  String displayName;
  String bio;
  Status status;
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
    status: statusValues.map[json["status"]],
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
    "status": statusValues.reverse[status],
    "friends_list": friendsList,
    "invitations": invitations,
    "avatars": avatars,
  };
}

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
