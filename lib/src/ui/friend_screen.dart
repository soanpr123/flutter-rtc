import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/bloc/profile_bloc.dart';
import 'package:rtc_uoi/src/bloc/search_friend_bloc.dart';
import 'package:rtc_uoi/src/model/search.dart';
import 'package:rtc_uoi/src/model/searchfriendMD.dart';
import 'package:rtc_uoi/src/model/user_profile_MD.dart';
import 'package:rtc_uoi/src/shared/component/Datasearchh.dart';
import 'package:rtc_uoi/src/shared/widget/item_inviteFriend.dart';

class Search_Screen extends StatefulWidget {
  final String token;
  final int id;
  Search_Screen({@required this.token, @required this.id});

  @override
  _Search_ScreenState createState() => _Search_ScreenState();
}

class _Search_ScreenState extends State<Search_Screen> {
  final _searchBloc = SearchhFriendBloc();
  var _listsnap = SearchFriendMd();
  final profileBloc = ProfileBloc();
  String name = "";
  @override
  void initState() {
    _searchBloc.getFriend(widget.token, widget.id);
    profileBloc.getInfor(widget.token, getData);
    super.initState();
  }

  @override
  void dispose() {
    _searchBloc.dispose();
    profileBloc.dispose();
    super.dispose();
  }

  getData(data) {
    Proffile _profile = data;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Friend"),
        actions: <Widget>[
          StreamBuilder<Object>(
              stream: _searchBloc.dataList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _listsnap = snapshot.data;
                  List<String> _listName = [];
                  List<Datum> _list = [];
                  for (Datum item in _listsnap.data) {
                    _listName.add(item.displayName);
                    _list.add(Datum(
                      firstName: item.firstName,
                      lastName: item.lastName,
                      displayName: item.displayName,
                      email: item.email,
                    ));
                  }
                  return IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: DataSearch(_listName, _list, widget.token));
                    },
                  );
                } else {
                  return Center(
                    child: Text("Add Friend"),
                  );
                }
              })
        ],
      ),
      body: Container(
        child: StreamBuilder<Object>(
            stream: profileBloc.datalist,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Proffile proffile = snapshot.data;
                return ListView.builder(
                  itemBuilder: (context, idx) => InviteFriendItem(
                      proffile.infoInvits[idx].displayName,
                      proffile.infoInvits[idx].email,
                      proffile.infoInvits[idx].id,
                      widget.token,
                      proffile),
                  itemCount: proffile.infoInvits.length,
                );
              } else {
                return Container(
                    width: size.width,
                    height: size.height,
                    alignment: Alignment.center,
                    child: Center(
                      child: Text("No invitations"),
                    ));
              }
            }),
      ),
    );
  }
}
