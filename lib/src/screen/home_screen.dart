import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:logindemo/src/models/invitcall.dart';
import 'package:logindemo/src/models/user.dart';
import 'package:logindemo/src/provider/user_provider.dart';
import 'package:logindemo/src/resources/call_video/signaling.dart';
import 'package:logindemo/src/resources/socket_client.dart';
import 'package:logindemo/src/screen/call_video_screen.dart';
import 'package:logindemo/src/widgets/dialog_messenger.dart';
import 'package:logindemo/src/widgets/friend_item.dart';
import 'package:provider/provider.dart';
import 'package:getflutter/getflutter.dart';

class HomeScreen extends StatefulWidget {
  static const routername = "/home";
  final String token;
  HomeScreen({this.token});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatumUser datumUser = DatumUser();
  var isInit = true;
  var isLoading = false;
  var isSearching = false;
  JoinRoom _joinRoom;
  Signaling _signaling;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _refrestProducts(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).fetchUser();
  }

  @override
  void initState() {
    _joinRoom = JoinRoom();
    _joinRoom.invitCalls(invitCall);
    _joinRoom.ready();
    _joinRoom.offerEvent(Offer);
    _signaling=Signaling(widget.token,_joinRoom);
    _signaling.onMessage(widget.token);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      Provider.of<UserProvider>(context).fetchUser().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
    isInit = false;
    super.didChangeDependencies();
  }



  @override
  Widget build(BuildContext context) {
    final itemUser = Provider.of<UserProvider>(context, listen: false).nameus;
    List<String> list = [];
    return Scaffold(
      key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: !isSearching
              ? Text("U-Oi Communication Tool")
              : TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.white, size: 30),
                      hintText: "Search Friend Here! ",
                      hintStyle: TextStyle(color: Colors.white)),
                ),
          actions: <Widget>[
            isSearching
                ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        this.isSearching = !this.isSearching;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        this.isSearching = !this.isSearching;
                      });
                    },
                  )
          ],
          elevation: 0.0,
        ),
        body: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3.0,
              color: Theme.of(context).primaryColor,
            ),
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refrestProducts(context),
                    child: Consumer<UserProvider>(
                      builder: (ctx, userpro, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemBuilder: (ctx, index) => FrientItems(
                                  disPlayname: userpro.users[index].displayname,
                                  imgeUrl: userpro.users[index].avatars,
                                  status: userpro.users[index].status,
                                  token: userpro.users[index].token,
                                  id: userpro.users[index].id,
                                  idFome: userpro.users[index].idFome,
                                ),
                            itemCount: userpro.users.length),
                      ),
                    )),
          ),
        ));
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


  Offer(data) {
   setState(() {
     print('offer là  : $data');
     Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctx)=>CallSample(widget.token)));
   });
  }
}


