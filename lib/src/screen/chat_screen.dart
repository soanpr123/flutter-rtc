import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logindemo/src/models/message_model.dart';
import 'package:logindemo/src/provider/user_provider.dart';
import 'package:logindemo/src/resources/socket_client.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  static const routerName = '/Chat-screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  JoinRoom _joinRoom;
  List<Message> _chatMessages;
  ScrollController _chatLVController;
  TextEditingController _chatTfController;

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
        color: isMe ? Theme.of(context).accentColor : Color(0xFFFFEFEE),
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
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            formatdate,
            style: TextStyle(
              color: Colors.blueGrey,
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

  _buildMessageComposer(String token,String name,int id) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
              controller: _chatTfController,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              sendBottomTap(token,name,id);
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
    _chatMessages = List();
    _chatLVController = ScrollController(initialScrollOffset: 0.0);
    _chatTfController = TextEditingController();
    super.initState();
  }

  @override
  //----------------get message in response------------------------//

//------------------- done add Message to UI---------------------///
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

  _addMessage(
    id,
    List<Message> chatMessageModel,
  ) async {
    setState(() {
      _chatMessages = chatMessageModel;
    });
    _chatListScrollToBottom();
  }

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

  @override
  Widget build(BuildContext context) {
    final info =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final id = Provider.of<UserProvider>(context).users;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          info['name'],
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
            onPressed: () {},
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
                  color: Colors.white,
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
                    itemCount: _chatMessages == null ? 0 : _chatMessages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Message message = _chatMessages[index];
                      final bool isMe = message.id == info['idFome'];
                      return _buildMessage(message, isMe);
                    },
                  ),
                ),
              ),
            ),
            _buildMessageComposer(info['token'],info['name'],info['idFome']),
          ],
        ),
      ),
    );
  }

  void sendBottomTap(String token,String name,int id) {
    if (_chatTfController.text.isEmpty) {
      return;
    }
    String text = _chatTfController.text.trim();
    _chatMessages.add(Message(
      id: id,
      message: text,
      time: DateTime.now().millisecondsSinceEpoch,
      isReading: false,
      displayName: name,
    ));
   _chatListScrollToBottom();
   _joinRoom.sendSingleChatMessage(
        text, DateTime.now().millisecondsSinceEpoch, token);
    _chatTfController.text = '';
  }
  onListerner(data) {
    print("listenr là : $data");
  }
}
