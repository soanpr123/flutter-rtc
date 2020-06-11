import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logindemo/src/models/user.dart';

class UserProvider with ChangeNotifier {
  List<DatumUser> _users = [];
  String token;
  int  idfome;
  static List<String> _nameus = [];
  List<DatumUser> get users => _users;
  List<searchUser> _search = [];
  List<String> get nameus => _nameus;

  List<searchUser> get search => _search;

  UserProvider(this.token,this.idfome);
  Map<String, String> requestHeaders = {
    'Accept': 'application/json;charset=UTF-8',
    'Content-type': 'application/json;charset=UTF-8'
  };

  static String utf8convert(String text) {
    var decode = Uri.decodeFull(text);
    print("Tên đây là : $decode");
    return decode;
  }

  Future<void> fetchUser() async {
    final url = 'https://uoi.bachasoftware.com/api/user/updateStatus';
    try {
      final response = await http.post(url,
          headers: requestHeaders, body: json.encode({'token': token}));
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData == null) {
        return;
      }

      List<DatumUser> loaderUser = [];
      List<String> loaderNameUser = [];
      UserMd userMd = UserMd.fromJson(responseData);
      if (userMd.data.length > 0) {
        for (DatumUser _uesr1 in userMd.data) {
          var decode = Uri.decodeFull(_uesr1.displayname);
          loaderUser.add(DatumUser(
              id: _uesr1.id,
              firstname: _uesr1.lastname,
              lastname: _uesr1.lastname,
              displayname: decode,
              status: _uesr1.status,
              avatars: _uesr1.avatars,
              email: _uesr1.email,
          token: token,
            idFome: idfome
          ));
          loaderNameUser.add(decode);
          _search.add(searchUser(name: decode, imageUrl: _uesr1.avatars));
        }
        _nameus = loaderNameUser;
        _users = loaderUser;

      }
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
  @override
  void dispose() {
  fetchUser();
    super.dispose();
  }
}

class searchUser {
  String name;
  String imageUrl;

  searchUser({@required this.name, @required this.imageUrl});
}
