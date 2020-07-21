import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/bloc/search_bloc.dart';
import 'package:rtc_uoi/src/bloc/search_friend_bloc.dart';
import 'package:rtc_uoi/src/model/user_profile_MD.dart';

class InviteFriendItem extends StatefulWidget {
  final String name;
  final String email;
  final int id;
  final String token;
  Proffile _proffile = Proffile();
  InviteFriendItem(this.name, this.email, this.id, this.token, this._proffile);

  @override
  _InviteFriendItemState createState() => _InviteFriendItemState();
}

class _InviteFriendItemState extends State<InviteFriendItem> {
  final _searchBloc = SearchhSendBloc();
bool isAppect=true;
bool isrefuse=false;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(Uri.decodeFull(widget.name)),
      trailing: isAppect?Container(
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Appect"),
              onPressed: () {
                _searchBloc.appectInvite(widget.token, widget.email, widget.id);
                setState(() {
                  isAppect=false;
                });
              },
              color: Colors.green,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            ),
            RaisedButton(
              child: Text("refuse"),
              onPressed: () {
                _searchBloc.refuseInvication(widget.token, widget.id);
                setState(() {
                  isAppect=false;
                  isrefuse=true;
                });
              },
              color: Colors.red,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            )
          ],
        ),
      ):isrefuse?Text("Refused"):Text("Appected"),
    ));
  }
}
