import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logindemo/src/models/message_model.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_common_client/socket_io_client.dart' as IO;
import 'package:logging/logging.dart';

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

class SimpleWebSocket with ChangeNotifier {
  String token = "";
  int idFriend = 0;
  String name = "";
  IO.Socket socket;

  connect(String url) async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
    stdout.writeln('Type something');
    List<String> cookie = null;
    socket = IO.io(url, {
      'secure': false,
      'path': '/socket-chat/',
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
    });
    socket.on('req-header-event', (data) {
      print("req-header-event " + data.toString());
    });
    socket.on('resp-header-event', (data) {
      print("resp-header-event " + data.toString());
    });
    socket.on('event', (data) => print("received " + data));
    socket.on('disconnect', (_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
    await stdin.pipe(ReadSender(socket));
//      joinRoom();
    await socket.on("notify_msg",(data2){
      print("data_msg : $data2");
    });
  }
}

class JoinRoom {
  IO.Socket _socket = IO.io("https://uoi.bachasoftware.com", {
    'path': '/socket-chat/',
    'transports': ['polling'],
  });
//  IO.Socket _socket;
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
//    _socket.on("notify_msg",(data2){
//      print("data_msg : $data2");
//      onChatMessageReceived(data2);
//    });
    _socket.on("histo", (data) {
      print("Received là : $data");
      onChatMessageReceived(data);
    });

  }
setOnListener(Function onListener)async{
   await _socket.on("notify_msg",  (data){
    print("data msg là : $data");
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
    _socket.emit("readed_message",{
      "token":token
    });
  }
}
