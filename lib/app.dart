import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:logindemo/src/models/invitcall.dart';

import 'package:logindemo/src/provider/auth_provider.dart';
import 'package:logindemo/src/provider/user_provider.dart';
import 'package:logindemo/src/resources/call_video/signaling.dart';
import 'package:logindemo/src/resources/socket_client.dart';
import 'package:logindemo/src/screen/chat_screen.dart';

import 'package:logindemo/src/screen/home_screen.dart';
import 'package:logindemo/src/screen/login_screen.dart';
import 'package:logindemo/src/screen/navigationbar_screen.dart';
import 'package:logindemo/src/screen/signup_screen.dart';
import 'package:logindemo/src/screen/splaps_screen.dart';
import 'package:logindemo/src/widgets/dialog_messenger.dart';
import 'package:logindemo/src/widgets/render_video.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, UserProvider>(
            update: (ctx, auth, previus) => UserProvider(
                auth.token, previus == null ? [] : previus.users, auth.idFome),
          ),
        ],
        child: Consumer<Auth>(
            builder: (ctx, auth, _) => MaterialApp(
                  theme: ThemeData(
                    primaryColor: Colors.red,
                    accentColor: Color(0xFFFEF9EB),
                  ),
                  home: auth.isAuth
                      ? Navigation(
                          token: auth.token,
                        )
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
