import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/ui/friend_screen.dart';
import 'package:rtc_uoi/src/ui/home_screen.dart';
import 'package:rtc_uoi/src/ui/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  final String urlAvt;
  final String name;
  final String phone;
  final String token;
  final int id;
  AppDrawer(this.urlAvt, this.name, this.phone, this.token, this.id);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  JoinRoom _joinRoom=JoinRoom();
  Future<Null> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', null);
    setState(() {
      _joinRoom.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Palette.BACKGROUND,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://uoi.bachasoftware.com/api/avatars/${widget.urlAvt}"),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        widget.name,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                ),
                Center(
                  child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Phone: ${widget.phone}",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext ctx) => new HomeScreen(
                        token: widget.token,
                        idFome: widget.id,
                      )));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Add Friend'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext ctx) => Search_Screen(
                        token: widget.token,
                        id: widget.id,
                      )));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Infor'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              logout();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext ctx) => SplashScreen()));

            },
          )
        ],
      ),
    );
  }
}
