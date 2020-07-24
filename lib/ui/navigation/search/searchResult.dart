import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerSearch.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/search/searchedProfile.dart';

class SearchResultPage extends StatefulWidget {

  @override
  _SearchResultState createState() => _SearchResultState();
}


class _SearchResultState extends State<SearchResultPage> {

  ProviderSearch _providerSearch;
  List<User> _users;
  User _me;

  @override
  Widget build(BuildContext context) {
    _providerSearch = Provider.of<ProviderSearch>(context);
    _users          = Provider.of<List<User>>(context);
    _me             = Provider.of<User>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: _searchResults()
    );
  }

  Widget _searchResults(){
    return _users == null
        ? Container()
        : _users.length == 0
        ? _noResult()
        : Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: _users.length,
            itemBuilder: (context, position){
              return GestureDetector(
                  onTap: () => _itemClicked(position),
                  child: _item(position)
              );
            }
        )
    );
  }

  Widget _item(position){
    return Container(
      height: 80,
      width: double.infinity,
      child: Card(
          elevation: 5,
          shadowColor: Colors.deepOrange,
          color: Colors.black,
          child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 10),
              leading: CircleAvatar(
                  radius: 28,
                  child: CachedNetworkImage(
                      imageUrl: _users.elementAt(position).imgProfile ?? '',
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => icUser,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider){
                        return Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover
                                )
                            )
                        );
                      }
                  )
              ),
              title: Text(
                  _users.elementAt(position).fullName ?? '',
                  style: TextStyle(color: Colors.white)
              ),
              subtitle: Text(
                  'location',
                  style: TextStyle(color: Colors.white)
              ),
              trailing: _didIReceiveFollowRequest(position)
                  ? _acceptOrDeclineView(position)
                  : IconButton(
                  onPressed: () => _providerSearch.followOperations(_me, _users.elementAt(position)),
                  icon: _getIconFollow(position)
              )
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
          color: Colors.deepOrange
        )
      ),
    );
  }

  Widget _getIconFollow(position){
    return _users.elementAt(position).friends.contains(Auth.instance.uid)
        ? Icon(Icons.done, color: Colors.green, size: 30)
        : _users.elementAt(position).followRequests.contains(Auth.instance.uid)
        ? Icon(Icons.update, color: Colors.yellow, size: 30)
        : _providerSearch.statusFollow
        ? Container(width: 20, height: 20, child: CircularProgressIndicator())
        : Icon(Icons.person_add, color: Colors.deepOrange, size: 30);
  }

  Widget _acceptOrDeclineView(position){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 22,
          width: 120,
          padding: EdgeInsets.only(right: 10),
          child: RaisedButton(
              onPressed: () async => _providerSearch.acceptRequest(_me, _users.elementAt(position)),
              color: Colors.black,
              splashColor: Colors.blueGrey,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: Colors.white
                  )
              ),
              child: Row(
                  children: <Widget>[
                    Icon(Icons.done, color: Colors.green, size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    )
                  ]
              )
          )
        ),
        SizedBox(height: 11),
        Container(
          height: 22,
          width: 120,
          padding: EdgeInsets.only(right: 10),
          child: RaisedButton(
              onPressed: () async => _providerSearch.declineRequest(_me, _users.elementAt(position)),
              color: Colors.black,
              splashColor: Colors.blueGrey,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: Colors.white
                  )
              ),
              child: Row(
                  children: <Widget>[
                    Icon(Icons.close, color: Colors.red, size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Decline',
                      style: TextStyle(color: Colors.white),
                    )
                  ]
              )
          )
        )
      ],
    );
}


  void _itemClicked(int position){
    showMaterialModalBottomSheet(
        context: context,
        expand: true,
        builder: (context, scrollController){
          return MultiProvider(
            providers: [
              StreamProvider.value(value: Database.instance.searchedUsers(_providerSearch.keySearch)),
              StreamProvider.value(value: Database.instance.currentUserData)
            ],
            child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                    heightFactor: 0.97,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      child: Scaffold(
                        backgroundColor: colorApp,
                        body: Padding(
                            padding: EdgeInsets.fromLTRB(18, 18, 18, 5),
                            child: SearchedProfilePage(position: position)
                        ),
                      ),
                    )
                )
            )
          );
        }
    );
  }

  bool _didIReceiveFollowRequest(position){
    // accept or decline received following request
    return _me.followRequests.contains(_users.elementAt(position).uid);
  }
}