import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerSearch.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/search/searchResult.dart';

class NavigationSearchPage extends StatefulWidget {

  @override
  _NavigationSearchPageState createState() => _NavigationSearchPageState();
}


class _NavigationSearchPageState extends State<NavigationSearchPage> {

  ProviderSearch _providerSearch;
  User _me;
  TextEditingController _controllerSearch;

  @override
  void initState() {
    super.initState();
    _controllerSearch = TextEditingController();
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerSearch = Provider.of<ProviderSearch>(context);
    _me             = Provider.of<User>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return SafeArea(
      child: Padding(
          padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: Center(child: _searchField())
      )
    );
  }

  Widget _searchField(){
    return Container(
        height: 50,
        width: double.infinity,
        padding: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30)
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controllerSearch,
                maxLines: 1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintText: 'search',
                    hintStyle: TextStyle(color: Colors.deepOrange),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide.none
                    )
                ),
              )
            ),
            GestureDetector(
                onTap: _search,
                child: _providerSearch.statusSearch
                    ? Container(height: 20, width: 20, child: CircularProgressIndicator())
                    : Icon(Icons.search, color: Colors.deepOrange, size: 20)
            )
          ],
        )
    );
  }

  void _search() async {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_){
              return StreamProvider.value(
                  value: Database.instance.searchedUsers(_controllerSearch.text.trim()),
                  child: SearchResultPage(me: _me)
              );
            }
        )
    );
  }
}