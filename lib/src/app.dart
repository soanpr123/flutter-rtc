import 'package:flutter/material.dart';
import 'package:logindemo/src/shared/style/colors.dart';
import 'package:logindemo/src/ui/splash_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       primaryColor: Palette.BACKGROUND,
      ),
      home: SplashScreen(),
    );
  }
}