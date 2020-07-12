import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/ui/login_screen.dart';
import 'package:rtc_uoi/src/ui/render_video.dart';

class CallingScreen extends StatefulWidget {
final int idFome;
 final String name;
 final int idForm;
 final String token;
CallingScreen({
   @required this.name,
   @required this.idForm,
   @required this.token,
   @required this.idFome,
});
  @override
  _CallingScreenState createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
JoinRoom _joinRoom=JoinRoom();
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Palette.BACKGROUND),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.name+ '\n Is Calling you...',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                   RaisedButton(
                     child: Text("Từ trối"),
                     onPressed: (){},
                     color: Colors.red,
                     textColor: Theme.of(context)
                         .primaryTextTheme
                         .button
                         .color,
                   ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    RaisedButton(
                      child: Text("Trả lời"),
                      onPressed: _join,
                      color: Colors.green,
                      textColor: Theme.of(context)
                          .primaryTextTheme
                          .button
                          .color,
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _join() {
    _joinRoom.Join(widget.idForm, widget.token, widget.name);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext ctx)=>RenderVideo(widget.token,widget.idFome,null,null)));
  }
}
