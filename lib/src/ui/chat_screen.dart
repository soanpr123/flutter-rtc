import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/rtc_video_view.dart';
import 'package:intl/intl.dart';
import 'package:rtc_uoi/src/model/message_model.dart';
import 'package:rtc_uoi/src/model/response_message_model.dart';
import 'package:rtc_uoi/src/shared/component/signaling.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/ui/render_video.dart';

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
  Signaling _signaling;
  ScrollController _chatLVController;
  TextEditingController _chatTfController;
  _buildMessage(Message message, bool isMe, bool callvideo) {
    var date = new DateTime.fromMicrosecondsSinceEpoch(message.time * 1000);
    String formatdate = DateFormat('yyyy/MM/dd, kk:mm').format(date);
    final Container msg = callvideo
        ? Container(
            width: 200,
            height: 60,
            margin: EdgeInsets.only( top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                topLeft: Radius.circular(15.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: Text(message.displayName,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
                Divider(
                  color: Colors.black,
                ),
                Text("- Ended at: $formatdate",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
              ],
            ),
          )
        : Container(
            margin: isMe
                ? EdgeInsets.only(
                    top: 10.0,
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
    if(callvideo){
      return  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          msg,
        ],
      );
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
              style: TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: InputDecoration.collapsed(
                  hintText: 'Send a message...',
                  hintStyle: TextStyle(color: Colors.white)),
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
    _chatMessages = List();
    _signaling=Signaling(widget.token,widget.displayName);
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
              if (_signaling != null) {
                _signaling.invite(widget.peerId, 'video', false, widget.displayName);
              }
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext ctx) => RenderVideo(widget.token,
                      widget.idForme, widget.peerId, widget.displayName)));
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
      body: GestureDetector(
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
                      itemCount:
                          _chatMessages == null ? 0 : _chatMessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Message message = _chatMessages[index];
                        final bool isMe = message.id == widget.idForme;
                        final bool callvideo =
                            message.displayName == "VIDEO_CHAT_ENDED";
                        return _buildMessage(message, isMe, callvideo);
                      },
                    )),
              ),
            ),
            _buildMessageComposer(widget.token, widget.name, widget.idForme),
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
