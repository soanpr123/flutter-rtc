// To parse this JSON data, do
//
//     final searchFriendMd = searchFriendMdFromJson(jsonString);

import 'dart:convert';

SearchFriendMd searchFriendMdFromJson(String str) => SearchFriendMd.fromJson(json.decode(str));

String searchFriendMdToJson(SearchFriendMd data) => json.encode(data.toJson());

class SearchFriendMd {
  SearchFriendMd({
    this.message,
    this.data,
  });

  String message;
  List<Datum> data;

  factory SearchFriendMd.fromJson(Map<String, dynamic> json) => SearchFriendMd(
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.firstName,
    this.lastName,
    this.displayName,
    this.email,
  });

  String firstName;
  String lastName;
  String displayName;
  String email;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    firstName: json["first_name"],
    lastName: json["last_name"],
    displayName: json["display_name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "display_name": displayName,
    "email": email,
  };
}
