import 'package:flutter/material.dart';
import 'package:getflutter/components/search_bar/gf_search_bar.dart';
class FrientItems extends StatefulWidget {
  final String disPlayname;
  final String imgeUrl;
  final String status;
  FrientItems({this.disPlayname, this.imgeUrl,this.status});

  @override
  _FrientItemsState createState() => _FrientItemsState();
}

class _FrientItemsState extends State<FrientItems> {


  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return
        Column(
          children: <Widget>[
            ListTile(
              title: Text(widget.disPlayname),
              leading: Stack(
                children: <Widget>[
                  Container(
                    height:50 ,
                    width: 50,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage("https://uoi.bachasoftware.com/api/avatars/${widget.imgeUrl}"),
                    ),
                  ),
                  widget.status=="Online" ?  Positioned(
                      top: 27,
                      bottom:0 ,
                      left:   28,
                      child: Icon(Icons.brightness_1,color: Colors.green)):
                  Positioned(
                      top: 0,
                      bottom:0 ,
                      left:0,
                      child:Container())
                      ,
                ],
              ),
//              trailing: Container(
//                child: ,
//              )
            ),
            Divider()
          ],
        );

  }
}