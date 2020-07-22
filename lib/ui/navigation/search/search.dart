import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/fullNameModel.dart';
import 'package:share_me/model/groupModel.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerSearch.dart';
import 'package:share_me/service/database.dart';

class SearchPage extends StatefulWidget {

  @override
  _SearchPageState createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {

  FullNameData   _providerName;
  GroupData      _providerGroup;
  ProviderSearch _providerSearch;
  TextEditingController _controllerSearch;


  @override
  void initState() {
    super.initState();
    _controllerSearch = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _providerSearch.uids = []);
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerName   = Provider.of<FullNameData>(context);
    _providerGroup  = Provider.of<GroupData>(context);
    _providerSearch = Provider.of<ProviderSearch>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return SafeArea(
      child: Padding(
          padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: Column(
              children: <Widget>[
                _searchField(),
                _results()
              ]
          )
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
                onTap: () async {
                  List<String>uids = [];
                  _providerName.fullNames.forEach((key, value){
                    if(value.toString().toLowerCase().contains(_controllerSearch.text.trim())){
                      uids.add(key);
                    }
                  });
                  _providerSearch.uids  = uids;
                  _providerSearch.users = await Database.instance.searchedUsers;
                },
                child: Icon(Icons.search, color: Colors.deepOrange, size: 20)
            )
          ],
        )
    );
  }

  Widget _results(){
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _providerSearch.users.length,
          itemBuilder: (context, position){
            return Container(
              height: 100,
              width: 100,
              child: Card(
                color: Colors.white,
                child: Center(child: Text(_providerSearch.users.elementAt(position).name)),
              ),
            );
          }
      ),
    );
  }
}