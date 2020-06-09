import 'package:flutter/material.dart';
import 'package:logindemo/src/resources/socket_client.dart';
import 'package:logindemo/src/screen/chat_screen.dart';


class FrientItems extends StatefulWidget {
  final String disPlayname;
  final String imgeUrl;
  final String status;
  final String token;
  final int id;
  final int idFome;
  FrientItems(
      {this.disPlayname,
      this.imgeUrl,
      this.status,
      this.token,
      this.id,
      this.idFome});

  @override
  _FrientItemsState createState() => _FrientItemsState();
}

class _FrientItemsState extends State<FrientItems> {
  JoinRoom _joinRoom;
  @override
  void initState() {
    _joinRoom=JoinRoom();
//G.initSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ChatScreen.routerName, arguments: {
              'image': widget.imgeUrl,
              'name': widget.disPlayname,
              'idFome': widget.idFome,
              'token': widget.token,
            });

           _joinRoom.joinRooms(widget.token, widget.id, widget.disPlayname);
          },
          child: GestureDetector(
            child: ListTile(
              title: Text(widget.disPlayname),
              leading: Stack(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://uoi.bachasoftware.com/api/avatars/${widget.imgeUrl}"),
                    ),
                  ),
                  widget.status == "Online"
                      ? Positioned(
                          top: 27,
                          bottom: 0,
                          left: 28,
                          child: Icon(Icons.brightness_1, color: Colors.green))
                      : Positioned(
                          top: 0, bottom: 0, left: 0, child: Container()),
                ],
              ),
//              trailing: Container(
//                child: ,
//              )
            ),
          ),
        ),
        Divider(
          color: Colors.black,
        )
      ],
    );
  }
}

class Info {
  final String name;
  final String avatar;

  Info(this.name, this.avatar);
}
