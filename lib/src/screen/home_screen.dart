import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:logindemo/src/models/user.dart';
import 'package:logindemo/src/provider/user_provider.dart';
import 'package:logindemo/src/widgets/friend_item.dart';
import 'package:provider/provider.dart';
import 'package:getflutter/getflutter.dart';

class HomeScreen extends StatefulWidget {
  static const routername = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatumUser datumUser = DatumUser();
  var isInit = true;
  var isLoading = false;
  var isSearching = false;
  Future<void> _refrestProducts(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).fetchUser();
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
      appBar: AppBar(
        title:
            !isSearching ? Text("U-Oi Communication Tool") :
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: Icon(Icons.search,color: Colors.white,
                    size: 30),
                hintText: "Search Friend Here! ",
                  hintStyle: TextStyle(color: Colors.white)
              ),

            ),
        actions: <Widget>[
          isSearching?
          IconButton(
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
          ):
          IconButton(
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
      ),
      body: isLoading
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
                          ),
                      itemCount: userpro.users.length),
                ),
              )),
    );
  }
}
