import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/shared/component/connfig.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/ui/home_screen.dart';
import 'package:rtc_uoi/src/ui/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SimpleWebSocket _simpleWebSocket = SimpleWebSocket();
  @override
  void initState() {
    super.initState();
    autologin();
  }

  void autologin() async {
    final perfs = await SharedPreferences.getInstance();
    if (!perfs.containsKey('userData')) {
      Timer(
          Duration(seconds: 5),
              () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext ctx) => AuthScreen())));
    }else{
      final extraxUserData =
      json.decode(perfs.get('userData')) as Map<String, Object>;
      final webToken = extraxUserData['webToken'];
      final id = extraxUserData['id'];
      print("token save là $webToken");
      if (webToken != null) {
        final password = extraxUserData['password'];
        final pasinput = extraxUserData['pasinput'];
        final saltKey = extraxUserData['saltKey'];
        List<int> key = utf8.encode(saltKey);
        List<int> bytes = utf8.encode(pasinput);
        var hmacSha256 = new Hmac(sha512, key); // HMAC-SHA256
        var digest = hmacSha256.convert(bytes);
        if (digest.toString() == password) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext ctx) => HomeScreen(
                token: webToken,
                idFome: id,
              )));
          _simpleWebSocket.connect(Config.REACT_APP_URL_SOCKETIO, webToken);
        } else {}

      } else {
        Timer(
            Duration(seconds: 5),
                () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext ctx) => AuthScreen())));
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Palette.BACKGROUND),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Image(
                            width: 250,
                            image: AssetImage('assets/images/uoi_logo.png')),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "U-Oi Communication Tool",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
