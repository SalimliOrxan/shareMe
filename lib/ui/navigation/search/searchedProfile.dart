import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/provider/providerSearch.dart';
import 'package:share_me/service/auth.dart';

class SearchedProfilePage extends StatefulWidget {

  final position;
  SearchedProfilePage({@required this.position});

  @override
  _SearchedProfileState createState() => _SearchedProfileState();
}


class _SearchedProfileState extends State<SearchedProfilePage> {

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
    return _users == null || _me == null
        ? Container()
        : LayoutBuilder(
        builder: (context, constraints){
          return SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Column(
                    children: <Widget>[
                      _imageAndName(constraints.maxHeight),
                      _actionPanel()
                    ]
                )
            )
          );
        }
    );
  }

  Widget _imageAndName(maxHeight){
    return Container(
        height: maxHeight / 2,
        width: double.infinity,
        child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                  height: maxHeight / 3,
                  width: double.infinity,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                          imageUrl: _users?.elementAt(widget.position)?.imgCover ?? '',
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(20))),
                          fit: BoxFit.cover
                      )
                  )
              ),
              Positioned(
                  bottom: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorApp
                                )
                            ),
                            CachedNetworkImage(
                                imageUrl: _users?.elementAt(widget.position)?.imgProfile ?? '',
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => icUser,
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider){
                                  return Container(
                                      width: 100,
                                      height: 100,
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
                          ]
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                              '${_users?.elementAt(widget.position)?.name ?? ''} ${_users?.elementAt(widget.position)?.surname ?? ''}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25
                              )
                          )
                      )
                    ],
                  )
              )
            ]
        )
    );
  }

  Widget _actionPanel(){
    return Container(
      height: 60,
      width: double.infinity,
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _didIReceiveFollowRequest(widget.position)
                  ? _acceptOrDeclineView(widget.position)
                  : _followButton()
            ]
        ),
      ),
    );
  }

  Widget _followButton(){
    return Container(
        height: 40,
        child: RaisedButton(
            onPressed: () => _providerSearch.followOperations(_me, _users.elementAt(widget.position)),
            color: Colors.black,
            splashColor: Colors.blueGrey,
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            child: Row(
                children: <Widget>[
                  _getIconFollow(widget.position),
                  SizedBox(width: 5),
                  Text(
                    _getTextFollow(widget.position),
                    style: TextStyle(color: Colors.white),
                  )
                ]
            )
        )
    );
  }

  Widget _getIconFollow(position){
    return _users.elementAt(position).friends.contains(Auth.instance.uid)
        ? Icon(Icons.done, color: Colors.green, size: 20)
        : _users.elementAt(position).followRequests.contains(Auth.instance.uid)
        ? Icon(Icons.update, color: Colors.yellow, size: 20)
        : _providerSearch.statusFollow
        ? Container(width: 20, height: 20, child: CircularProgressIndicator())
        : Icon(Icons.person_add, color: Colors.deepOrange, size: 20);
  }

  String _getTextFollow(position){
    return _users.elementAt(position).friends.contains(Auth.instance.uid)
        ? 'Following'
        : _users.elementAt(position).followRequests.contains(Auth.instance.uid)
        ? 'Waiting'
        : 'Follow';
  }

  Widget _acceptOrDeclineView(position){
    return Row(
      children: <Widget>[
        Container(
            height: 40,
            width: 110,
            child: RaisedButton(
                onPressed: () async => _providerSearch.acceptRequest(_me, _users.elementAt(position)),
                color: Colors.black,
                splashColor: Colors.blueGrey,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
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
        SizedBox(width: 20),
        Container(
            height: 40,
            width: 110,
            child: RaisedButton(
                onPressed: () async => _providerSearch.declineRequest(_me, _users.elementAt(position)),
                color: Colors.black,
                splashColor: Colors.blueGrey,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
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


  bool _didIReceiveFollowRequest(position){
    // accept or decline received following request
    return _me.followRequests.contains(_users.elementAt(position).uid);
  }
}