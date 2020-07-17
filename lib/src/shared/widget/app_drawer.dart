import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';


class AppDrawer extends StatefulWidget {
  final urlAvt;
  final name;
  final phone;
  AppDrawer(this.urlAvt,this.name,this.phone);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
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
            child:  Column(
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
                    child: Text(widget.name,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                  ),
                ),
                Center(
                  child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text("Phone: ${widget.phone}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {

            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Product'),
            onTap: () {

            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');

            },
          )
        ],
      ),
    );
  }
}
