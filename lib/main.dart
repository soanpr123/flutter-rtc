import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:logindemo/src/provider/auth_provider.dart';
import 'package:logindemo/src/provider/user_provider.dart';
import 'package:logindemo/src/resourch/socket_client.dart';
import 'package:logindemo/src/screen/home_screen.dart';
import 'package:logindemo/src/screen/login_screen.dart';
import 'package:logindemo/src/screen/signup_screen.dart';
import 'package:logindemo/src/screen/splaps_screen.dart';
import 'package:provider/provider.dart';

void main()async {

  runApp(MyApp());
}

//void main(){
//  String text = "Tr%E1%BA%A7n.V%C5%A9.Vi%E1%BB%87t.Anh";
//  List encodedText = utf8.encode(text);
//  String base64Str = base64.encode(encodedText);
//  print('base64: $encodedText');
//  String decodedText  = utf8.decode(text.runes.toList());
//  print("ten: $decodedText");
//}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
//          ChangeNotifierProvider.value(
//            value: UserProvider(),
////          ),
          ChangeNotifierProxyProvider<Auth, UserProvider>(
            update: (ctx, auth, _) => UserProvider(auth.token),
          ),
        ],
        child: Consumer<Auth>(
            builder: (ctx, auth, _) => MaterialApp(
                  home: auth.isAuth
                      ? HomeScreen()
                      : FutureBuilder(
                          future: auth.autologin(),
                          builder: (context, authSnapshot) =>
                              authSnapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? SplashScreen()
                                  : LoginScreen()),
                  routes: {
                    SignupScreen.routername: (ctx) => SignupScreen(),
                    LoginScreen.routername: (ctx) => LoginScreen(),
                    HomeScreen.routername: (ctx) => HomeScreen()
                  },
                )));
  }
}
