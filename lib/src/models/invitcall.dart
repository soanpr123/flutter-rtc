// To parse this JSON data, do
//
//     final invitcall = invitcallFromJson(jsonString);

import 'dart:convert';

List<dynamic> invitcallFromJson(String str) => List<dynamic>.from(json.decode(str).map((x) => x));

String invitcallToJson(List<dynamic> data) => json.encode(List<dynamic>.from(data.map((x) => x)));

class InvitcallClass {
  InvitcallClass({
    this.idFrom,
    this.displayName,
  });

  int idFrom;
  String displayName;

  factory InvitcallClass.fromJson(Map<String, dynamic> json) => InvitcallClass(
    idFrom: json["idFrom"],
    displayName: json["displayName"],
  );

  Map<String, dynamic> toJson() => {
    "idFrom": idFrom,
    "displayName": displayName,
  };
}
