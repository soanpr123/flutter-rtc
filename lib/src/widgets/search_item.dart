import 'package:flutter/material.dart';
import 'package:getflutter/components/search_bar/gf_search_bar.dart';
import 'package:logindemo/src/provider/user_provider.dart';
import 'package:provider/provider.dart';
class Searchs extends StatefulWidget {
  @override
  _SearchsState createState() => _SearchsState();
}

class _SearchsState extends State<Searchs> {

  @override
  Widget build(BuildContext context) {
    final items=Provider.of<UserProvider>(context).search;
    return Container(
      child:  GFSearchBar(
        searchList: items,
        searchQueryBuilder: (query, list) {
          return list
              .where((item) =>
              item.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        overlaySearchListItemBuilder: (item) {
          return ListView.builder(itemBuilder: null,

            itemCount: items.length,);
        },
        onItemSelected: (item) {
          setState(() {
            print('$item');
          });
        },
      ),

    );
  }
}



