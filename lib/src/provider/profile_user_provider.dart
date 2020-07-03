import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:logindemo/src/models/profile.dart';
import 'package:logindemo/utilities/config.dart';
import 'package:http/http.dart' as http;

class ProfileUser with ChangeNotifier{
  List<InfoUser>_profile=[];
  String displayName;
  List<InfoUser> get profile => _profile;

  String get _displayName=>displayName;

  Map<String, String> requestHeaders = {
    'Accept': 'application/json;charset=UTF-8',
    'Content-type': 'application/json;charset=UTF-8'
  };
  Future<void> fetchUser(String token) async {
    final url = Config.REACT_APP_API_URL+'/user/profile';
    try {
      final response = await http.post(url,
          headers: requestHeaders, body: json.encode({'token': token}));
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData == null) {
        return;
      }
      print('data infor : $responseData');
      List<InfoUser> loaderUser =[];
      Proffile proffile=Proffile.fromJson(responseData);
      var name = Uri.decodeFull(proffile.infoUser.displayName);
      var bio = Uri.decodeFull(proffile.infoUser.bio);
      displayName=name;
    _profile.add(InfoUser(
      id: proffile.infoUser.id,
      firstName: proffile.infoUser.firstName,
     lastName:proffile.infoUser.lastName,
     email:proffile.infoUser.email,
      phone:proffile.infoUser.phone,
     company:proffile.infoUser.company,
     displayName:name,
      bio:bio,
      status:proffile.infoUser.status,
      friendsList:proffile.infoUser.friendsList,
      invitations:proffile.infoUser.invitations,
      avatars:proffile.infoUser.avatars,
    ));
    print("item laf : ${_profile.length}");
      notifyListeners();
    } catch (e) {
      throw e;
    }

  }
}