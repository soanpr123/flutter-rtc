import 'package:flutter/material.dart';
import 'package:flutter_webrtc/rtc_video_view.dart';
import 'package:logindemo/src/shared/component/signaling.dart';
import 'package:logindemo/src/shared/component/socket_client.dart';
import 'package:logindemo/src/ui/home_screen.dart';


class RenderVideo extends StatefulWidget {
  final String token;
  final int idFome;

  RenderVideo(this.token,this.idFome);
  @override
  _RenderVideoState createState() => _RenderVideoState();
}

class _RenderVideoState extends State<RenderVideo> {
  Signaling _signaling;
  JoinRoom _joinRoom;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;

  @override
  void initState() {
    super.initState();
    _joinRoom = JoinRoom();
    initRenderers();
    _connect();

  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_signaling != null) _signaling.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _connect() async {
    if (_signaling == null) {
      _signaling = Signaling(widget.token)..connect();
      _signaling.onStateChange = (SignalingState state) {
        switch (state) {
          case SignalingState.CallStateNew:
            this.setState(() {
              _inCalling = true;
            });
            break;
          case SignalingState.CallStateBye:
            this.setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });
            break;
          case SignalingState.CallStateInvite:
          case SignalingState.CallStateConnected:
          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:
          case SignalingState.ConnectionOpen:
            break;
        }
      };
      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
//          _selfId = event['self'];
//          _peers = event['peers'];
        });
      });
      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });

    }
  }

  _hangUp() {
    if (_signaling != null) {
      _signaling.bye();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext ctx)=>HomeScreen(token: widget.token,idFome: widget.idFome,)));
    }
  }

  _switchCamera() {
    _signaling.switchCamera();
  }

  _muteMic() {}
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('P2P Call Sample'),
        ),

        body: OrientationBuilder(builder: (context, orientation) {
          return new Container(
            child: new Stack(children: <Widget>[
              new Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: new Container(
                    margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: new RTCVideoView(_remoteRenderer),
                    decoration: new BoxDecoration(color: Colors.black54),
                  )),
              new Positioned(
                left: 20.0,
                top: 20.0,
                child: new Container(
                  width: orientation == Orientation.portrait ? 90.0 : 120.0,
                  height: orientation == Orientation.portrait ? 120.0 : 90.0,
                  child: new RTCVideoView(_localRenderer),
                  decoration: new BoxDecoration(color: Colors.white),
                ),
              ),
            ]),
          );
        }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 300,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                heroTag: "btn1",
                child: const Icon(Icons.switch_camera),
                onPressed: _switchCamera,
              ),
              FloatingActionButton(
                heroTag: "btn2",
                onPressed: _hangUp,
                tooltip: 'Hangup',
                child: Icon(Icons.call_end),
                backgroundColor: Colors.pink,
              ),
              FloatingActionButton(
                heroTag: "btn3",
                child: const Icon(Icons.mic_off),
                onPressed: _muteMic,
              )
            ]),
      ),
    );
  }

}