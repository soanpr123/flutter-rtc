import 'package:flutter/material.dart';
import 'package:rtc_uoi/src/bloc/search_bloc.dart';
import 'package:rtc_uoi/src/model/search.dart';
import 'package:rtc_uoi/src/model/searchfriendMD.dart';

class DataSearch extends SearchDelegate<String> {
  List<Datum> _list = [];
  List<String> name = [];
  String token;
  DataSearch(this.name, this._list, this.token);
  final _searchBloc = SearchhSendBloc();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
    throw UnimplementedError();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Datum> resentlist = [];
    query.isEmpty
        ? "no result"
        : resentlist.addAll(_list.where((element) =>
            element.displayName.toLowerCase().contains(query.toLowerCase())));
    return ListView.builder(
      itemBuilder: (context, idx) => ListTile(
        title: RichText(
          text: TextSpan(
              text: resentlist[idx].displayName.substring(0, query.length),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: resentlist[idx].displayName.substring(query.length),
                    style: TextStyle(color: Colors.grey))
              ]),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _searchBloc.invistSend(token, resentlist[idx].email);
            print("tên   ${resentlist[idx].email}");
          },
        ),
      ),
      itemCount: resentlist.length,
    );
    throw UnimplementedError();
  }
}
