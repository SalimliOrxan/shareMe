import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/chatUser.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigation.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';

import 'friendsView.dart';

class GroupInfo extends StatefulWidget {

  @override
  _GroupInfoState createState() => _GroupInfoState();
}


class _GroupInfoState extends State<GroupInfo> {

  ProviderNavigation _providerNavigation;
  List<User> _friends;
  Message _chat;

  @override
  Widget build(BuildContext context) {
    _providerNavigation = Provider.of(context);
    _friends = Provider.of(context);
    _chat = Provider.of(context);

    return Scaffold(
      backgroundColor: colorApp,
      appBar: _appBar(),
      body: _body()
    );
  }



  Widget _appBar(){
    return AppBar(
        elevation: 0,
        backgroundColor: Colors.black26,
        actionsIconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Group info',
          style: TextStyle(color: Colors.white54),
        )
    );
  }

  Widget _body(){
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            'Chat friends',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        _addUserButton(),
        _usersView()
      ],
    );
  }

  Widget _usersView(){
    return ListView.builder(
        itemCount: _chat.usersForRead.length,
        shrinkWrap: true,
        itemBuilder: (context, position){
          return _itemUserView(position);
        }
    );
  }

  Widget _itemUserView(int position){
    MyChatUser user = _chat.usersForRead[position];

    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.only(bottom: 1),
      child: Slidable(
          enabled: user.uid != Auth.instance.uid,
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          closeOnScroll: true,
          child: Container(
              width: double.infinity,
              color: Colors.black54,
              child: ListTile(
                  onTap: (){

                  },
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  leading: user.img == null || user.img.isEmpty
                      ? Container(width: 40, height: 40, child: icUser)
                      : Container(
                      width: 40,
                      child: CachedNetworkImage(
                          imageUrl: user.img,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(width: 40, height: 40, child: icUser),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.none,
                          imageBuilder: (context, imageProvider){
                            return Container(
                                width: 40,
                                height: 40,
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
                      user.uid == Auth.instance.uid ? 'You' : user.name,
                      style: TextStyle(color: Colors.white)
                  )
              )
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: true,
                onTap: () => _removeUserFromChat(position)
            )
          ]
      )
    );
  }

  Widget _addUserButton(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
          width: double.infinity,
          color: Colors.black54,
          child: ListTile(
              onTap: _showAddFriendDialog,
              contentPadding: EdgeInsets.only(left: 10, right: 10),
              leading: Icon(Icons.person_add, color: Colors.deepOrange, size: 30),
              title: Text(
                  'Add friend',
                  style: TextStyle(color: Colors.white)
              )
          )
      ),
    );
  }


  Future<void> _showAddFriendDialog() async {
    _providerNavigation.selectedChatUserPositions?.clear();
    _providerNavigation.friendsIsNotInChat?.clear();

    await showDialog(
        context: context,
        builder: (BuildContext _context){
          return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(10),
              backgroundColor: colorApp,
              content: FriendsView(friends: _friends, chatUsers: _chat.usersForRead),
              actions: <Widget>[
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.deepOrange, size: 30)
                ),
                IconButton(
                    onPressed: _addUsersToChat,
                    icon: Icon(Icons.add_circle, color: Colors.deepOrange, size: 30)
                )
              ]
          );
        }
    );
  }

  Future<void> _addUsersToChat() async {
    if(_providerNavigation.selectedChatUserPositions.length > 0){
      Navigator.pop(context);

      List<User>newChatUsers = [];
      _providerNavigation.selectedChatUserPositions.forEach((position){
        User user = _providerNavigation.friendsIsNotInChat[position];
        newChatUsers.add(user);
        MyChatUser newUser = MyChatUser(uid: user.uid, name: user.fullName, img: user.imgProfile);
        _chat.usersForWrite.add(newUser.toMap());
      });


      await Database.instance.updateChat(_chat);

      newChatUsers.forEach((user) async {
        user.chats.add(_chat.chatId);
        await Database.instance.updateOtherUser(user);
      });
    }
  }

  Future<void> _removeUserFromChat(int position) async {
    User removedUser;

    for(User friend in _friends){
      if(_chat.usersForRead[position].uid == friend.uid){
        removedUser = friend..chats.remove(_chat.chatId);
        break;
      }
    }
    _chat.usersForWrite.removeAt(position);
    await Database.instance.updateChat(_chat);
    await Database.instance.updateOtherUser(removedUser);
  }
}