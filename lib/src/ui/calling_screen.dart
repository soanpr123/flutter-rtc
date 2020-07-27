import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/ui/login_screen.dart';
import 'package:rtc_uoi/src/ui/render_video.dart';
import 'package:vibration/vibration.dart';

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
  _PatternVibrate() {
    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 200),
    );

    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 500),
    );

    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 200),
    );
    HapticFeedback.mediumImpact();
  }
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  JoinRoom _joinRoom = JoinRoom();
  @override
  void initState() {
    initPlayer();
    super.initState();
  }

  void initPlayer() async {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);
    audioCache.play('audio/ringtone.mp3');
    advancedPlayer.setVolume(10.0);
//    HapticFeedback.vibrate();
    _PatternVibrate();

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
                        widget.name + '\n Is Calling you...',
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
                      onPressed: () {
                        _joinRoom.DeclineCall(widget.idForm, widget.token);
                        Navigator.of(context).pop();
                        advancedPlayer.stop();
                      },
                      color: Colors.red,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    RaisedButton(
                      child: Text("Trả lời"),
                      onPressed: _join,
                      color: Colors.green,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
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
    advancedPlayer.stop();
    Vibration.cancel();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext ctx) =>
            RenderVideo(widget.token, widget.idFome, widget.idForm, null)));
  }
}
