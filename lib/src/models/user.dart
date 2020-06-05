import 'package:flutter/cupertino.dart';

//class UserMd {
//  final String id;
//  final String firstname;
//  final String lastname;
//  final String displayname;
//  final String status;
//  final String avatars;
//  final String email;
//  UserMd(
//      {@required this.id ,
//      @required this.firstname,
//      @required this.lastname,
//      @required this.displayname,
//      @required this.status,
//      @required this.avatars,
//      @required this.email});
//}
class UserMd {
  String message;
  List<DatumUser> data = [];

  UserMd({
    this.message,
    this.data,
  });

  factory UserMd.fromJson(Map<String, dynamic> json) => UserMd(
        message: json["message"],
        data: List<DatumUser>.from(
            json["status"].map((x) => DatumUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DatumUser {
  final int id;
  final int idFome;
  final String firstname;
  final String lastname;
  final String displayname;
  final String status;
  final String avatars;
  final String email;
  final String token;
   DatumUser(
      {@required this.id,
        @required this.idFome,
      @required this.firstname,
      @required this.lastname,
      @required this.displayname,
      @required this.status,
      @required this.avatars,
      @required this.email,
      @required this.token});

  factory DatumUser.fromJson(Map<String, dynamic> json) => DatumUser(
      id: json["id"] as int,
      firstname: json["first_name"] as String,
      lastname: json["last_name"] as String,
      displayname: json["display_name"] as String,
      status: json["status"] as String,
      avatars: json["avatars"] as String,
      email: json['email'] as String);



  Map<String, dynamic> toJson() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'displayname': displayname,
        'status': status,
        'avatars': avatars,
        'email': email
      };
}
