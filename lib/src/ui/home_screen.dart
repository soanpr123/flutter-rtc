import 'package:flutter/material.dart';
import 'package:logindemo/src/bloc/friend_bloc.dart';
import 'package:logindemo/src/bloc/profile_bloc.dart';
import 'package:logindemo/src/model/friendMd.dart';
import 'package:logindemo/src/model/invitcall.dart';
import 'package:logindemo/src/model/user_profile_MD.dart';
import 'package:logindemo/src/shared/component/connfig.dart';
import 'package:logindemo/src/shared/component/socket_client.dart';
import 'package:logindemo/src/shared/style/colors.dart';
import 'package:logindemo/src/shared/widget/friend_item.dart';
import 'package:logindemo/src/ui/calling_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routername = "/home";
  final String token;
  final int idFome;

  HomeScreen({this.token, this.idFome});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final friendBloc = FriendBloc();
  final profileBloc = ProfileBloc();
  String nameUser = '';
  JoinRoom _joinRoom;
  SimpleWebSocket _simpleWebSocket = SimpleWebSocket();
  Future<void> refrestProducts() async {
    await friendBloc.getUser(widget.token);
  }

//mới
  @override
  void initState() {
    super.initState();
    friendBloc.getUser(widget.token);
    _joinRoom = JoinRoom();
    profileBloc.getInfor(widget.token, getData);
    _joinRoom.invitCalls(invitCall);
  }

  @override
  void dispose() {
    super.dispose();
    friendBloc.dispose();
    profileBloc.dispose();
  }

  getData(data) {
    Proffile _profile = data;
    var decode = Uri.decodeFull(_profile.infoUser.displayName);
    print("data là pro : $decode");
    nameUser = decode;
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
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext ctx) => CallingScreen(
                name: decode,
                idForm: _invitcallClass.idFrom,
                token: widget.token,
                idFome: widget.idFome,
              )));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.BACKGROUND,
      appBar: AppBar(
        title: Text("U-Oi Communication Tool"),
        elevation: 0.0,
      ),
      body: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.0,
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
            child: RefreshIndicator(
              onRefresh: () => refrestProducts(),
              child: StreamBuilder<Object>(
                  stream: friendBloc.dataList,
                  builder: (context, snapshot) {
                    List<StatusElement> listSnap = [];
                    if (snapshot.hasData) {
                      listSnap = snapshot.data;
                      return ListView.builder(
                          itemBuilder: (ctx, index) => FrientItems(
                                disPlayname: listSnap[index].displayName,
                                imgeUrl: listSnap[index].avatars,
                                status: listSnap[index].status,
                                token: widget.token,
                                id: listSnap[index].id,
                                idFome: widget.idFome,
                                displayName: nameUser,
                              ),
                          itemCount: listSnap.length);
                    } else {
                      return Container(
                          width: size.width,
                          height: size.height,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    }
                  }),
            ),
          )),
    );
  }
}
