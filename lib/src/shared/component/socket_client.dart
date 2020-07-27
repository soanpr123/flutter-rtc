import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rtc_uoi/src/shared/component/connfig.dart';
import 'package:socket_io_common_client/socket_io_client.dart' as IO;
import 'package:logging/logging.dart';

const CLIENT_ID_EVENT = 'client-id-event';
const OFFER_EVENT = 'offer';
const ANSWER_EVENT = 'answer';
const END_EVENT = 'endCall';
const READY_EVENT = 'ready';
const ICE_CANDIDATE_EVENT = 'candidate';
typedef void OnMessageCallback(String tag,dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();


class SimpleWebSocket {
  int idFriend = 0;
  String name = "";
  IO.Socket socket;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;
  SimpleWebSocket();
  connect(String url, String token) async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
    stdout.writeln('Type something');
    socket = IO.io(url, {
      'path': '/socket-chat/',
      'transports': ['polling'],
    });

    socket.on('connect', (_) {
      socket.emit("user", {"token": token});
//      onOpen();
    });
    socket.on(CLIENT_ID_EVENT, (data) {
      onMessage( CLIENT_ID_EVENT,data);
    });
  }

  send(event, data) {
    if (socket != null) {
      socket.emit(event, data);
      print('send: $event - $data');
    }
  }
}

class JoinRoom {
  OnMessageCallback onMessage;
  IO.Socket _socket = IO.io(Config.REACT_APP_URL_SOCKETIO, {
    'path': '/socket-chat/',
    'transports': ['polling'],
  });

  joinRooms(String token, int id, String name) {
    if (_socket != null) {
      _socket.emit('change_room', {
        "token": token,
        "idFriend": [id],
        "display_name": name
      });
      print("join");
    }
  }

  setOnChatMessageReceivedListener(Function onChatMessageReceived) {
    _socket.on("histo", (data) {
      print("Received là : $data");
      onChatMessageReceived(data);
    });
  }

  ready() {
    _socket.on('ready', (data){
     onMessage(READY_EVENT,data);
    });

  }

  setOnListener(Function onListener) {
    _socket.on("notify_msg", (data) {
      print("data_msg : $data");
      onListener(data);
    });
  }

  sendSingleChatMessage(String masage, int date, String token) {
    if (null == _socket) {
      print("Socket is Null, Cannot send message");
      return;
    }
    _socket
        .emit("new_message", {"message": masage, "time": date, "token": token});
  }

  invitCalls(Function invitCall,String token) {
    _socket.on('invitCall', (data) {
      print('invitCall $data');

        invitCall(data);
    });
  }

  offerEvent() {
    _socket.on('offer', (data) {
      print('ofer là : $data');
      onMessage(OFFER_EVENT,data);
    });
  }
  answerEvent() {
    _socket.on('answer', (data) {
      onMessage(ANSWER_EVENT,data);
    });
  }
  readyrEvent() {
    _socket.on('ready', (data) {
      print('ready là : $data');
      onMessage(READY_EVENT,data);
    });
  }
  candidateEvent(){
    _socket.on('candidate', (data){
      onMessage(ICE_CANDIDATE_EVENT,data);
    });
  }
  Join(int idFrom, String token, String name) {
    _socket.emit('ready',
        {'idTo': idFrom, 'token': token, 'display_name': name});

  }
  DeclineCall(int id,String token){
  _socket.emit('refuseCall', { "idTo": id, "token": token, "message": 'Refuse' });
}
  send(event, data) {
    if (_socket != null) {
      _socket.emit(event, data);
      print('send: $event - $data');
    }
  }
  dispose(){
    _socket.close();
  }
}
