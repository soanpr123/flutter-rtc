import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/bloc/friend_bloc.dart';
import 'package:rtc_uoi/src/bloc/profile_bloc.dart';
import 'package:rtc_uoi/src/model/friendMd.dart';
import 'package:rtc_uoi/src/model/invitcall.dart';
import 'package:rtc_uoi/src/model/user_profile_MD.dart';
import 'package:rtc_uoi/src/shared/component/socket_client.dart';
import 'package:rtc_uoi/src/shared/style/colors.dart';
import 'package:rtc_uoi/src/shared/widget/app_drawer.dart';
import 'package:rtc_uoi/src/shared/widget/friend_item.dart';
import 'package:rtc_uoi/src/ui/calling_screen.dart';

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
  String avt='';
  String phone;
  JoinRoom _joinRoom;
  Future<void> refrestProducts() async {
    await friendBloc.getUser(widget.token);
  }

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

   setState(() {
     nameUser = decode;
     avt=_profile.infoUser.avatars;
     phone=_profile.infoUser.phone;
   });
    print("data là pro : $phone");
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
      drawer:  AppDrawer(avt,nameUser,phone),
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
