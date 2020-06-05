import 'package:logindemo/src/resources/socket_client.dart';

class G{
  static SimpleWebSocket _socket;
  static initSocket(){
    if(_socket==null){
      _socket=SimpleWebSocket();
    }
  }
}