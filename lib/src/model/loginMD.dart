// To parse this JSON data, do
//
//     final loginMd = loginMdFromJson(jsonString);

import 'dart:convert';

LoginMd loginMdFromJson(String str) => LoginMd.fromJson(json.decode(str));

String loginMdToJson(LoginMd data) => json.encode(data.toJson());

class LoginMd {
  LoginMd({
    this.password,
    this.saltKey,
    this.message,
    this.id,
    this.nbConnect,
    this.webToken,
  });

  String password;
  String saltKey;
  String message;
  int id;
  int nbConnect;
  String webToken;

  factory LoginMd.fromJson(Map<String, dynamic> json) => LoginMd(
    password: json["password"],
    saltKey: json["saltKey"],
    message: json["message"],
    id: json["id"],
    nbConnect: json["nbConnect"],
    webToken: json["webToken"],
  );

  Map<String, dynamic> toJson() => {
    "password": password,
    "saltKey": saltKey,
    "message": message,
    "id": id,
    "nbConnect": nbConnect,
    "webToken": webToken,
  };
}
