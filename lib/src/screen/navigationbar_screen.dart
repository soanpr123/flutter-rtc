import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:logindemo/src/models/invitcall.dart';
import 'package:logindemo/src/resources/call_video/signaling.dart';
import 'package:logindemo/src/resources/socket_client.dart';
import 'package:logindemo/src/screen/add_friend_screen.dart';
import 'package:logindemo/src/screen/home_screen.dart';
import 'package:logindemo/src/screen/profile_screen.dart';
import 'package:logindemo/src/widgets/dialog_messenger.dart';

class Navigation extends StatefulWidget {
  final String token;
  Navigation({this.token});
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  Signaling _signaling;
  JoinRoom _joinRoom;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _joinRoom = JoinRoom();
    initRenderers();
    _joinRoom.invitCalls(invitCall);
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
      _signaling = Signaling(widget.token, _joinRoom)..onMessage(widget.token);

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
    }
  }

  _switchCamera() {
    _signaling.switchCamera();
  }

  _muteMic() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Theme.of(context).primaryColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
          ? SizedBox(
              width: 200.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      child: const Icon(Icons.switch_camera),
                      onPressed: _switchCamera,
                    ),
                    FloatingActionButton(
                      onPressed: _hangUp,
                      tooltip: 'Hangup',
                      child: Icon(Icons.call_end),
                      backgroundColor: Colors.pink,
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.mic_off),
                      onPressed: _muteMic,
                    )
                  ]))
          : null,
      body: _inCalling
          ? OrientationBuilder(builder: (context, orientation) {
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
                      height:
                          orientation == Orientation.portrait ? 120.0 : 90.0,
                      child: new RTCVideoView(_localRenderer),
                      decoration: new BoxDecoration(color: Colors.white),
                    ),
                  ),
                ]),
              );
            })
          : Center(
              child: [
                new HomeScreen(
                  token: widget.token,
                ),
                new AddFriendScreen(),
                new ProfileScreen(),
              ].elementAt(selectedIndex),
            ),
      bottomNavigationBar: _inCalling
          ? null
          : CurvedNavigationBar(
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
  invitCall(data) {
    print("invitCall là: $data");
    if (null == data || data.toString().isEmpty) {
      return;
    }
    InvitcallClass _invitcallClass = InvitcallClass.fromJson(data);
    var decode = Uri.decodeFull(_invitcallClass.displayName);
    print("tên người gọi : $decode");
    print("ID người gọi : ${_invitcallClass.idFrom}");
    setState(() {

//    _joinRoom.send('refuseCall', {
//      'idTo': _invitcallClass.idFrom,
//      'token': widget.token,
//      'message': 'already in a call'
//    });
      DialogShow().dialogShow("Calling for you",decode, context,_invitcallClass.idFrom,widget.token,_joinRoom);
    });
  }
}
