import 'dart:convert';

Empty emptyFromJson(String str) => Empty.fromJson(json.decode(str));

String emptyToJson(Empty data) => json.encode(data.toJson());

class Empty {
  Empty({
    this.message,
    this.id,
  });

  String message;
  int id;

  factory Empty.fromJson(Map<String, dynamic> json) => Empty(
    message: json["message"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "id": id,
  };
}
