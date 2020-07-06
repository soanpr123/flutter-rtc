import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/rtc_video_view.dart';
import 'package:intl/intl.dart';
import 'package:logindemo/src/model/message_model.dart';
import 'package:logindemo/src/model/response_message_model.dart';
import 'package:logindemo/src/shared/component/signaling.dart';
import 'package:logindemo/src/shared/component/socket_client.dart';
import 'package:logindemo/src/shared/style/colors.dart';


class ChatScreen extends StatefulWidget {
  static const routerName = '/Chat-screen';
  final String token;
  final String name;
  final String displayName;
  final int idForme;
  final int peerId;
  ChatScreen({
    @required this.token,
    @required this.name,
    @required this.idForme,
    @required this.peerId,
    @required this.displayName,

  });
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  JoinRoom _joinRoom;
  List<Message> _chatMessages;
  ScrollController _chatLVController;
  TextEditingController _chatTfController;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Signaling _signaling;
  _buildMessage(Message message, bool isMe) {
    var date = new DateTime.fromMicrosecondsSinceEpoch(message.time * 1000);
    String formatdate = DateFormat('yyyy/MM/dd, kk:mm').format(date);
    final Container msg = Container(
      margin: isMe
          ? EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 80.0,
      )
          : EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.black54,
        borderRadius: isMe
            ? BorderRadius.only(
          topLeft: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
        )
            : BorderRadius.only(
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            formatdate,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (isMe) {
      return msg;
    }
    return Row(
      children: <Widget>[
        msg,
      ],
    );
  }

  _buildMessageComposer(String token, String name, int id) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Palette.BACKGROUND,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Colors.blue,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              style: TextStyle(color:  Colors.white),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
                hintStyle: TextStyle(color:  Colors.white)
              ),
              controller: _chatTfController,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Colors.blue,
            onPressed: () async {
              sendBottomTap(token, name, id);
//              _joinRoom.sendSingleChatMessage();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _joinRoom = JoinRoom();
    _joinRoom.setOnChatMessageReceivedListener(onChatMessageReceived);
    _joinRoom.setOnListener(onListerner);
    _chatListScrollToBottom();
    _joinRoom = JoinRoom();
//    _joinRoom.invitCalls(invitCall);
    initRenderers();
    _connect(widget.token);
    _chatMessages = List();
    _chatLVController = ScrollController(initialScrollOffset: 0.0);
    _chatTfController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _joinRoom = JoinRoom();
    _joinRoom.setOnChatMessageReceivedListener(onChatMessageReceived);
    _joinRoom.setOnListener(onListerner);
    _chatListScrollToBottom();
    _chatMessages = List();
    _chatLVController = ScrollController(initialScrollOffset: 0.0);
    _chatTfController = TextEditingController();
    super.dispose();
  } //↓↓↓↓↓↓↓------get message in response------↓↓↓↓↓↓//

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

  void _connect(String token) async {
    if (_signaling == null) {
      _signaling = Signaling(token)..connect();
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
  _invitePeer(context, peerId, use_screen) async {
    if (_signaling != null) {
      _signaling.invite(peerId, 'video', use_screen,widget.displayName);
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
  onChatMessageReceived(data) {
    print('onChatMessageReceived $data');
    if (null == data || data.toString().isEmpty) {
      return;
    }
    MessageModel messageMD = MessageModel.fromJson(data);
    List<Message> loaderMassage = [];
    for (Message item in messageMD.message) {
      loaderMassage.add(Message(
          id: item.id,
          displayName: item.displayName,
          message: item.message,
          time: item.time,
          isReading: item.isReading));
    }
    print(loaderMassage.length);
    processMessage(loaderMassage);
  }

  processMessage(List<Message> chatMessageModel) {
    _addMessage(0, chatMessageModel);
  }

//↓↓↓↓↓↓------add Message to UI----↓↓↓↓↓↓↓//
  _addMessage(
      id,
      List<Message> chatMessageModel,
      ) async {
    setState(() {
      _chatMessages = chatMessageModel;
    });
    _chatListScrollToBottom();
  }

//------------------- done add Message to UI---------------------///
  _chatListScrollToBottom() {
    Timer(Duration(milliseconds: 100), () {
      if (_chatLVController.hasClients) {
        _chatLVController.animateTo(
          _chatLVController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.decelerate,
        );
      }
    });
  }

//-------------------done get message in response------------------------//
//------↓↓↓↓--notification listener and update Listview--↓↓↓↓-----//
  onListerner(data) {
    if (null == data || data.toString().isEmpty) {
      return;
    }
    ResponseMessageModelClass messageMD =
    ResponseMessageModelClass.fromJson(data);
    List<Message> loaderMassage = [];
    if (this.mounted) {
      setState(() {
        _chatMessages.add(Message(
          id: messageMD.userid,
          message: messageMD.message,
          time: messageMD.time,
          isReading: false,
          displayName: messageMD.username,
        ));
        print(loaderMassage.length);
        _chatListScrollToBottom();
      });
    }
  }

  //-------------------------------------done notification listener and update Listview------------------------//
//  _invitePeer(context, peerId, use_screen) async {
//    if (_signaling != null && peerId != _selfId) {
//      _signaling.invite(peerId, 'video', use_screen);
//    }
//  }
  //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓-Build Ui chat-↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.videocam),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {
              _invitePeer(context, widget.peerId, false);
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
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
          : GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: ListView.builder(
                      cacheExtent: 100,
                      controller: _chatLVController,
                      reverse: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 15.0),
                      itemCount: _chatMessages == null
                          ? 0
                          : _chatMessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Message message = _chatMessages[index];
                        final bool isMe = message.id == widget.idForme;
                        return _buildMessage(message, isMe);
                      },
                    )),
              ),
            ),
            _buildMessageComposer(
                widget.token, widget.name, widget.idForme),
          ],
        ),
      ),
    );
  }

  void sendBottomTap(String token, String name, int id) {
    if (_chatTfController.text.isEmpty) {
      return;
    }
    String text = _chatTfController.text.trim();
    if (this.mounted) {
      setState(() {
        _chatMessages.add(Message(
          id: id,
          message: text,
          time: DateTime.now().millisecondsSinceEpoch,
          isReading: false,
          displayName: name,
        ));
        _chatListScrollToBottom();
      });
    }
    _joinRoom.sendSingleChatMessage(
        text, DateTime.now().millisecondsSinceEpoch, token);
    _chatTfController.text = '';
  }
}
