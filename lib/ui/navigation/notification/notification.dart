import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';

class NavigationNotificationPage extends StatefulWidget {

  @override
  _NavigationNotificationState createState() => _NavigationNotificationState();
}


class _NavigationNotificationState extends State<NavigationNotificationPage> {

  List<User> _requestedUsers;
  User _userData;

  @override
  Widget build(BuildContext context) {
    _requestedUsers = Provider.of<List<User>>(context);
    _userData       = Provider.of<User>(context);

    return Scaffold(
      backgroundColor: colorApp,
      body: _body()
    );
  }


  Widget _body(){
    return SafeArea(
        child: Padding(
            padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: _notifications()
        )
    );
  }

  Widget _notifications(){
    return _requestedUsers == null
    ? _bodyNoNotification()
    : _requestedUsers.length == 0
    ? _bodyNoNotification()
    : ListView.builder(
        itemCount: _requestedUsers.length,
        itemBuilder: (context, position){
          return GestureDetector(
              onTap: () => _tileClicked(position),
              child: _item(position)
          );
        }
    );
  }


  Widget _bodyNoNotification(){
    return Center(
        child: Icon(Icons.notifications_off, size: 150, color: Colors.white)
    );
  }

  Widget _item(int position){
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
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
                        imageUrl: _requestedUsers.elementAt(position).imgProfile ?? '',
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
                    _requestedUsers.elementAt(position).fullName ?? '',
                    style: TextStyle(color: Colors.white)
                ),
                subtitle: Text(
                    'location',
                    style: TextStyle(color: Colors.white)
                )
            )
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          color: Colors.green,
          icon: Icons.check,
          onTap: () async => _accept(position)
        )
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.deepOrange,
          icon: Icons.close,
          onTap: (){

          }
        ),
        IconSlideAction(
          color: Colors.red,
          icon: Icons.delete,
          onTap: (){
//            _providerNotification.notifications.removeAt(position);
//            _providerNotification.notifications = _providerNotification.notifications;
          },
        )
      ],
    );
  }

  void _tileClicked(int position){
    //openPopUp(context, 'Notification');
  }

  Future<void>_accept(position) async {
    User requestedUser = _requestedUsers.elementAt(position);
    // add me his friend list
    requestedUser.friends.add(Auth.instance.uid);
    // add him my friend list
    _userData.friends.add(requestedUser.uid);
    // remove follow request my follow list
    _userData.followRequests.remove(requestedUser.uid);
    // update me
    await Database.instance.updateUserData(_userData);
    // update him
    await Database.instance.updateOtherUser(requestedUser);
  }

  void _reject(){

  }

  void _delete(){

  }
}