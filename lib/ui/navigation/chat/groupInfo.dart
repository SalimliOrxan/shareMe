import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/chatUser.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerChat.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';

import 'friendsView.dart';

class GroupInfo extends StatefulWidget {

  @override
  _GroupInfoState createState() => _GroupInfoState();
}


class _GroupInfoState extends State<GroupInfo> {

  ProviderChat _providerChat;
  List<User> _friends;
  Message _chat;
  TextEditingController _controllerGroupName;

  @override
  void initState() {
    _controllerGroupName = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _providerChat.clearAll();
    _controllerGroupName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerChat = Provider.of(context);
    _friends      = Provider.of(context);
    _chat         = Provider.of(context);

    _controllerGroupName?.text = _chat?.groupName;

    return Scaffold(
      backgroundColor: colorApp,
      appBar: _appBar(),
      body: _chat == null ? Container() : _body()
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
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _groupIconField(),
          _groupNameField(),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              'Chat friends',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          _addAdminButton(),
          _addUserButton(),
          _usersView()
        ]
      )
    );
  }

  Widget _groupIconField(){
    return Stack(
        children: <Widget>[
          Container(
              height: 200,
              width: double.infinity,
              child: CachedNetworkImage(
                  imageUrl: _chat.groupImg,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Container(child: Icon(Icons.group, color: Colors.white, size: 50), color: Colors.white24),
                  fit: BoxFit.cover
              )
          ),
          Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final file = await pickImage(false);
                  await Database.instance.updateChat(_chat, file);
                },
                child: Container(
                    height: 200,
                    width: 90,
                    color: Colors.black26,
                    child: Center(
                      child: Text(
                          'upload',
                          style: TextStyle(
                              color: Colors.white
                          )
                      ),
                    )
                )
              )
          )
        ]
    );
  }

  Widget _groupNameField(){
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        height: 60,
        color: _providerChat.isEditable ? Colors.black26 : Colors.black54,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: TextField(
                controller: _controllerGroupName,
                enabled: _providerChat.isEditable,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(right: 20),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    counter: Text('')
                ),
                keyboardType: TextInputType.text,
                maxLines: 1,
                maxLength: 30
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () async {
                  if(_providerChat.isEditable){
                    _chat.groupName = _controllerGroupName.text.trim();
                    await Database.instance.updateChat(_chat, null);
                  }
                  _providerChat.isEditable = !_providerChat.isEditable;
                },
                icon: Icon(_providerChat.isEditable ? Icons.check : Icons.edit, color: Colors.deepOrange, size: 20)
              )
            )
          ]
        )
      )
    );
  }

  Widget _usersView(){
    return ListView.builder(
        itemCount: _chat.usersForRead.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
          enabled: user.uid != Auth.instance.uid && _chat.admins.contains(Auth.instance.uid) && !_chat.admins.contains(user.uid),
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
                  ),
                  trailing: Visibility(
                      visible: _chat.admins.contains(user.uid),
                      child: Container(
                          height: 20,
                          width: 50,
                          decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent, width: 0.5)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                                'admin',
                                style: TextStyle(color: Colors.greenAccent, fontSize: 11)
                            ),
                          )
                      )
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

  Widget _addAdminButton(){
    return Visibility(
      visible: _chat.admins.contains(Auth.instance.uid),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Container(
            width: double.infinity,
            color: Colors.black54,
            child: ListTile(
                onTap: _showAddAdminDialog,
                contentPadding: EdgeInsets.only(left: 10, right: 10),
                leading: Icon(Icons.vpn_key, color: Colors.deepOrange, size: 29),
                title: Text(
                    'Add admin',
                    style: TextStyle(color: Colors.white)
                )
            )
        )
      )
    );
  }

  Widget _addUserButton(){
    return Visibility(
      visible: _chat.admins.contains(Auth.instance.uid),
      child: Padding(
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
      ),
    );
  }


  Future<void> _showAddAdminDialog() async {
    _providerChat.selectedChatUserPositions?.clear();
    _providerChat.friendsIsNotInChat?.clear();

    await showDialog(
        context: context,
        builder: (BuildContext _context){
          return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(10),
              backgroundColor: colorApp,
              content: Container(height: 500, child: FriendsView(friends: _friends, chat: _chat, forAdmin: true, isGroup: true)),
              actions: <Widget>[
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.deepOrange, size: 30)
                ),
                IconButton(
                    onPressed: _addUsersToAdmins,
                    icon: Icon(Icons.add_circle, color: Colors.deepOrange, size: 30)
                )
              ]
          );
        }
    );
  }

  Future<void> _showAddFriendDialog() async {
    _providerChat.selectedChatUserPositions?.clear();
    _providerChat.friendsIsNotInChat?.clear();

    await showDialog(
        context: context,
        builder: (BuildContext _context){
          return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(10),
              backgroundColor: colorApp,
              content: Container(height: 500, child: FriendsView(friends: _friends, chat: _chat, forAdmin: false, isGroup: true)),
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

  Future<void> _addUsersToAdmins() async {
    if(_providerChat.selectedChatUserPositions.length > 0){
      Navigator.pop(context);

      _providerChat.selectedChatUserPositions.forEach((position){
        User user = _providerChat.friendsIsNotInChat[position];
        _chat.admins.add(user.uid);
      });

      await Database.instance.updateChat(_chat, null);
    }
  }

  Future<void> _addUsersToChat() async {
    if(_providerChat.selectedChatUserPositions.length > 0){
      Navigator.pop(context);

      List<User>newChatUsers = [];

      _providerChat.selectedChatUserPositions.forEach((position){
        User user = _providerChat.friendsIsNotInChat[position];
        newChatUsers.add(user);
        MyChatUser newUser = MyChatUser(uid: user.uid, name: user.fullName, img: user.imgProfile);
        _chat.usersForWrite.add(newUser.toMap());
        _chat.fcmTokens.add(user.fcmToken);
      });


      await Database.instance.updateChat(_chat, null);

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
    _chat.fcmTokens.remove(removedUser.fcmToken);
    _chat.usersForWrite.removeAt(position);
    await Database.instance.updateChat(_chat, null);
    await Database.instance.updateOtherUser(removedUser);
  }
}