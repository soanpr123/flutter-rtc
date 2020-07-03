import 'package:flutter/material.dart';
import 'package:logindemo/src/resources/call_video/signaling.dart';
import 'package:logindemo/src/resources/socket_client.dart';


class DialogShow{
  dialogShow(String title,String name,BuildContext context,int idFrom,String token ,JoinRoom _joinromm){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "$name want to contact you"),
                    ),
                    SizedBox(height: 20,),
                    TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: title),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: 100.0,
                          child: RaisedButton(
                            onPressed: () {Navigator.of(context).pop();},
                            child: Text(
                              "close",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        ),
                        SizedBox(
                          width: 100.0,
                          child: RaisedButton(
                            onPressed: (){
                             _joinromm.Join(idFrom, token, name);
                             Navigator.of(context).pop();
                            },
                            child: Text(
                              "join",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
