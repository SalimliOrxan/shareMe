import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerSearch.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';

class SearchResultPage extends StatefulWidget {

  final User me;
  SearchResultPage({@required this.me});

  @override
  _SearchResultState createState() => _SearchResultState();
}


class _SearchResultState extends State<SearchResultPage> {

  ProviderSearch _providerSearch;
  List<User> _users;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _providerSearch.users = []);
  }

  @override
  Widget build(BuildContext context) {
    _providerSearch = Provider.of<ProviderSearch>(context);
    _users          = Provider.of<List<User>>(context);

    return Scaffold(
        backgroundColor: colorApp,
        appBar: _appBar(),
        body: _body()
    );
  }


  Widget _appBar(){
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      actionsIconTheme: IconThemeData(color: Colors.white),
    );
  }

  Widget _body(){
    return SafeArea(
        child: Padding(
            padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: _searchResults()
        )
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
              return _item(position);
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
              trailing: IconButton(
                  onPressed: () => _followOperations(position),
                  icon: _iconFollow(position)
              )
          )
      ),
    );
  }

  Widget _noResult(){
    return Center(
      child: Icon(
        Icons.find_in_page,
        size: 100,
        color: Colors.deepOrange,
      )
    );
  }

  Widget _iconFollow(position){
    return _users.elementAt(position).friends.contains(Auth.instance.uid)
        ? Icon(Icons.done, color: Colors.green, size: 30)
        : _users.elementAt(position).followRequests.contains(Auth.instance.uid)
        ? Icon(Icons.update, color: Colors.yellow, size: 30)
        : _providerSearch.statusFollow
        ? Container(width: 20, height: 20, child: CircularProgressIndicator())
        : Icon(Icons.add, color: Colors.deepOrange, size: 30);
  }

  Future<void> _followOperations(position) async {
    bool isFollowingDone      = _users.elementAt(position).friends.contains(Auth.instance.uid);
    bool isFollowingRequested = _users.elementAt(position).followRequests.contains(Auth.instance.uid);

    if(isFollowingDone){
      // stop following
      _providerSearch.statusFollow = true;
      User user = _users.elementAt(position);
      user.friends.remove(Auth.instance.uid);
      await Database.instance.updateOtherUser(user);
      widget.me.friends.remove(user.uid);
      await Database.instance.updateUserData(widget.me);
      _providerSearch.statusFollow = false;
    } else {
      if(isFollowingRequested){
        // remove following request
        _providerSearch.statusFollow = true;
        User user = _users.elementAt(position);
        user.followRequests.remove(Auth.instance.uid);
        await Database.instance.updateOtherUser(user);
        _providerSearch.statusFollow = false;
      } else {
        // send following request
        _providerSearch.statusFollow = true;
        User user = _users.elementAt(position);
        user.followRequests.add(Auth.instance.uid);
        await Database.instance.updateOtherUser(user);
        _providerSearch.statusFollow = false;
      }
    }
  }
}