import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logindemo/src/models/message_model.dart';
import 'package:logindemo/utilities/config.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_common_client/socket_io_client.dart' as IO;
import 'package:logging/logging.dart';

const CLIENT_ID_EVENT = 'client-id-event';
const OFFER_EVENT = 'offer';
const ANSWER_EVENT = 'answer';
const READY_EVENT = 'ready';
const ICE_CANDIDATE_EVENT = 'candidate';
typedef void OnMessageCallback(String tag,dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();

class ReadSender implements StreamConsumer<List<int>> {
  IO.Socket socket;

  ReadSender(IO.Socket this.socket);

  @override
  Future addStream(Stream<List<int>> stream) {
    return stream.transform(utf8.decoder).forEach((content) {
      print(content);
      this.socket.emit("chat message", content);
    }).timeout(Duration(days: 30));
  }

  @override
  Future close() {
    return null;
  }
}

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
    List<String> cookie = null;
    socket = IO.io(url, {
//      'path': '/socket-chat/',
//    'path': '/socket.io',
      'transports': ['polling'],
      'request-header-processer': (requestHeader) {
        print("get request header " + requestHeader.toString());
        if (cookie != null) {
          requestHeader.add('cookie', cookie);
          print("set cookie success");
        } else {
          print("set cookie faield");
        }
      },
      'response-header-processer': (responseHeader) {
        print("get response header " + responseHeader.toString());
        if (responseHeader['set-cookie'] != null) {
          cookie = responseHeader['set-cookie'];
          print("receive cookie success");
        } else {
          print("receive cookie failed");
        }
      },
    });

    socket.on('connect', (_) {
      print('connect happened');
      socket.emit("user", {"token": token});
//      onOpen();
    });
    socket.on('req-header-event', (data) {
      print("req-header-event " + data.toString());
    });
    socket.on('resp-header-event', (data) {
      print("resp-header-event " + data.toString());
    });
    socket.on(CLIENT_ID_EVENT, (data) {
      onMessage( CLIENT_ID_EVENT,data);
    });

    socket.on(ICE_CANDIDATE_EVENT, (data) {
      print("Candicate là : $data");
    });

    socket.on('event', (data) => print("received " + data));
    socket.on('disconnect', (_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
    await stdin.pipe(ReadSender(socket));
//      joinRoom();
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
//    'path': '/socket-chat/',
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

  ready() {}

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

  invitCalls(Function invitCall) {
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

  Join(int idFrom, String token, String name) {
    _socket.emit('ready',
        {'idTo': idFrom, 'token': token, 'display_name': name});

  }

  send(event, data) {
    if (_socket != null) {
      _socket.emit(event, data);
      print('send: $event - $data');
    }
  }
}
