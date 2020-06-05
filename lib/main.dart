import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:logindemo/src/provider/auth_provider.dart';
import 'package:logindemo/src/provider/user_provider.dart';
import 'package:logindemo/src/screen/chat_screen.dart';

import 'package:logindemo/src/screen/home_screen.dart';
import 'package:logindemo/src/screen/login_screen.dart';
import 'package:logindemo/src/screen/signup_screen.dart';
import 'package:logindemo/src/screen/splaps_screen.dart';
import 'package:provider/provider.dart';

void main()async {

  runApp(MyApp());
}


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
            update: (ctx, auth, _) => UserProvider(auth.token,auth.idFome),
          ),
        ],
        child: Consumer<Auth>(
            builder: (ctx, auth, _) => MaterialApp(
              theme: ThemeData(
                primaryColor: Colors.red,
                accentColor: Color(0xFFFEF9EB),
              ),
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
                    HomeScreen.routername: (ctx) => HomeScreen(),
                    ChatScreen.routerName: (ctx) => ChatScreen()
                  },
                )));
  }
}


