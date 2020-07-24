import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/provider/providerSearch.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/search/searchResult.dart';

class NavigationSearchPage extends StatefulWidget {

  @override
  _NavigationSearchPageState createState() => _NavigationSearchPageState();
}


class _NavigationSearchPageState extends State<NavigationSearchPage> {

  ProviderSearch _providerSearch;
  TextEditingController _controllerSearch;

  @override
  void initState() {
    super.initState();
    _controllerSearch = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _providerSearch.keySearch = null;
      _providerSearch.users = [];
    });
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerSearch = Provider.of<ProviderSearch>(context);

    return Scaffold(
        backgroundColor: colorApp,
        appBar: _appBar(),
        body: _body()
    );
  }


  Widget _appBar(){
    return PreferredSize(
      preferredSize: Size(double.infinity, 60),
      child: AppBar(
        backgroundColor: colorApp,
        elevation: 0,
        flexibleSpace: _searchField()
      ),
    );
  }

  Widget _body(){
    return _providerSearch.keySearch == null
        ? _noResult()
        : StreamProvider.value(
        value: Database.instance.searchedUsers(_providerSearch.keySearch),
        child: SearchResultPage()
    );
  }

  Widget _searchField(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Container(
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
      ),
    );
  }

  Widget _noResult(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Center(
          child: Icon(
            Icons.find_in_page,
            size: 100,
            color: Colors.deepOrange,
          )
      ),
    );
  }

  void _search(){
    _providerSearch.keySearch = _controllerSearch.text.trim();
  }
}