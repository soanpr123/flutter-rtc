import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rtc_uoi/src/bloc/login_bloc.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/ui/home_screen.dart';
import 'package:rtc_uoi/src/ui/login_screen.dart';
import 'package:rtc_uoi/src/ui/splash_screen.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Palette.BACKGROUND,
      ),
      home: SplashScreen(),
    );
  }
}
