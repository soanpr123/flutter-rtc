import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:logindemo/src/screen/add_friend_screen.dart';
import 'package:logindemo/src/screen/home_screen.dart';
import 'package:logindemo/src/screen/profile_screen.dart';

class Navigation extends StatefulWidget {
  final String token;
  Navigation({this.token});
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child:[
          new HomeScreen(token: widget.token,),
          new AddFriendScreen(),
          new ProfileScreen(),
        ].elementAt(selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
//        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).primaryColor,
        height: 50,
//        buttonBackgroundColor: ,
        items: <Widget>[
          Icon(
            Icons.supervised_user_circle,
            size: 20,
            color: Colors.black,
          ),
          Icon(
            Icons.add,
            size: 20,
            color: Colors.black,
          ),
          Icon(
            Icons.info,
            size: 20,
            color: Colors.black,
          ),
        ],
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        index: 0,
        onTap: onItemTapped,
      ),
    );
  }
}
