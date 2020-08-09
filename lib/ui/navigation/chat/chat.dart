import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/chatUser.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigation.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/chat/chatMessages.dart';
import 'package:share_me/ui/navigation/chat/friendsView.dart';
import 'package:share_me/ui/navigation/chat/groupIcon.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  ProviderNavigation _providerNavigation;
  List<User> _friends, _chatUsers = [];
  List<Message> _chats;
  User _me;
  TextEditingController _controllerGroupName;

  @override
  void initState() {
    _controllerGroupName = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerGroupName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerNavigation = Provider.of<ProviderNavigation>(context);
    _friends = Provider.of<List<User>>(context);
    _chats   = Provider.of<List<Message>>(context);
    _me      = Provider.of<User>(context);

    return Scaffold(
        backgroundColor: colorApp,
        floatingActionButton: _fab(),
        body: _chats == null || _chats.length == 0 ? _emptyBody() : _body()
    );
  }


  Widget _fab(){
    return FloatingActionButton(
        onPressed: _showCreateChatDialog,
        child: Icon(Icons.edit)
    );
  }

  Widget _body(){
    return _chatView();
  }

  Widget _emptyBody(){
    return Center(child: Icon(Icons.chat, size: 100, color: Colors.deepOrange));
  }

  Widget _chatView(){
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _chats.length,
        itemBuilder: (context, position){
          return _chats[position].isGroup ? _itemGroupChat(position) : _itemPersonalChat(position);
        }
    );
  }

  Widget _itemPersonalChat(int position){
    String img;
    String name;

    if(_chats.elementAt(position).senderId == _me.uid){
      img  = _chats.elementAt(position).usersForRead[0].img;
      name = _chats.elementAt(position).usersForRead[0].name;
    } else {
      img  = _chats.elementAt(position).senderImg;
      name = _chats.elementAt(position).senderName;
    }

    return Visibility(
        visible: !_me.deletedChats.contains(_chats[position].chatId),
        key: UniqueKey(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              closeOnScroll: true,
              child: Container(
                  width: double.infinity,
                  color: Colors.black54,
                  child: ListTile(
                      onTap: (){
                        _chatUsers = [];
                        for(var chatUser in _chats.elementAt(position).usersForRead) {
                          for(User user in _friends){
                            if(chatUser.uid == user.uid){
                              _chatUsers.add(user);
                              break;
                            }
                          }
                        }
                        _itemMessagePressed(position);
                      },
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      leading: img == null || img.isEmpty
                          ? Container(width: 40, height: 40, child: icUser)
                          : Container(
                          width: 40,
                          child: CachedNetworkImage(
                              imageUrl: img,
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
                      trailing: Icon(Icons.keyboard_arrow_right, color: Colors.deepOrange, size: 20),
                      title: Text(
                          name ?? 'Group',
                          style: TextStyle(color: Colors.white)
                      ),
                      subtitle: Text(
                          _chats.elementAt(position).date.toDate().toString().substring(0, 16),
                          style: TextStyle(color: Colors.white)
                      )
                  )
              ),
              secondaryActions: <Widget>[
                IconSlideAction(
                    color: Colors.red,
                    icon: Icons.delete,
                    closeOnTap: true,
                    onTap: (){
                      _deleteChat(position);
                    }
                )
              ]
          ),
        )
    );
  }

  Widget _itemGroupChat(int position){
    String name = _chats[position].groupName;
    String img  = _chats[position].groupImg;

    return Visibility(
        visible: !_me.deletedChats.contains(_chats[position].chatId),
        key: UniqueKey(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              closeOnScroll: true,
              child: Container(
                  width: double.infinity,
                  color: Colors.black54,
                  child: ListTile(
                      onTap: (){
                        _chatUsers = [];
                        for(var chatUser in _chats.elementAt(position).usersForRead) {
                          for(User user in _friends){
                            if(chatUser.uid == user.uid){
                              _chatUsers.add(user);
                              break;
                            }
                          }
                        }
                        _itemMessagePressed(position);
                      },
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      leading: img == null || img.isEmpty
                          ? CircleAvatar(maxRadius: 20, backgroundColor: Colors.white24, child: Icon(Icons.group))
                          : Container(
                          width: 40,
                          child: CachedNetworkImage(
                              imageUrl: img,
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
                      trailing: Icon(Icons.keyboard_arrow_right, color: Colors.deepOrange, size: 20),
                      title: Text(
                          name ?? 'Group',
                          style: TextStyle(color: Colors.white)
                      ),
                      subtitle: Text(
                          _chats.elementAt(position).date.toDate().toString().substring(0, 16),
                          style: TextStyle(color: Colors.white)
                      )
                  )
              ),
              secondaryActions: <Widget>[
                IconSlideAction(
                    color: Colors.red,
                    icon: Icons.delete,
                    closeOnTap: true,
                    onTap: (){
                      _deleteChat(position);
                    }
                )
              ]
          )
        )
    );
  }



  Future<void>_itemMessagePressed(int position) async {
    Navigator
        .of(context)
        .push(MaterialPageRoute(
        builder: (_) => StreamProvider.value(
            value: Database.instance.getChatById(_chats[position].chatId),
            child: ChatMessages(me: _me, receivers: _chatUsers)
        )
    ));
  }

  Future<void>_deleteChat(int position) async {
    _me.deletedChats.add(_chats[position].chatId);
    await Database.instance.updateUserData(_me);
  }

  Future<void>_showCreateChatDialog() async {
    if(_friends != null && _friends.length != 0){
      _providerNavigation.selectedChatUserPositions = [];
      _providerNavigation.groupIcon = null;
      _controllerGroupName.clear();

      await showDialog(
          context: context,
          builder: (BuildContext _context){
            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(10),
              backgroundColor: colorApp,
              content: Container(height: 500, child: FriendsView(friends: _friends, chat: null, forAdmin: false)),
              actions: <Widget>[
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.deepOrange, size: 30)
                ),
                IconButton(
                  onPressed: (){
                    if(_providerNavigation.selectedChatUserPositions.length > 0){
                      Navigator.pop(context);

                      if(_providerNavigation.isGroup){
                        _showGroupDialog();
                      }

                      _chatUsers = [];
                      _providerNavigation.selectedChatUserPositions.forEach((position){
                        _chatUsers.add(_friends[position]);
                      });
                      _chatUsers.add(_me);
                    }
                  },
                  icon: Icon(Icons.add_circle, color: Colors.deepOrange, size: 30)
                )
              ]
            );
          }
      );
    }
  }

  Future<void>_showGroupDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext _context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            backgroundColor: colorApp,
            title: TextField(
              controller: _controllerGroupName,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Group name',
                labelStyle: TextStyle(color: Colors.white)
              ),
              keyboardType: TextInputType.text,
              maxLines: 1,
              maxLength: 30
            ),
            content: GroupIcon(),
            actions: <Widget>[
              Container(
                height: 30,
                width: 100,
                child: RaisedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.deepOrange,
                ),
              ),
              Container(
                height: 30,
                width: 100,
                child: RaisedButton(
                  onPressed: (){
                    if(_controllerGroupName.text.trim().isNotEmpty){
                      _createChat();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.deepOrange,
                ),
              )
            ]
          );
        }
    );
  }

  Future<void>_createChat() async {
    bool chatExists = false;

    if(!_providerNavigation.isGroup){
      // it is not group
      if(_me.chattedFriends.containsKey(_chatUsers[0].uid)){
        // chat already exists
        chatExists = true;
      }
    }

    if(!chatExists){
      // create new chat
      Message chat = Message(
          groupName:     _controllerGroupName.text.trim(),
          usersForWrite: [],
          admins:        [],
          addedUsers:    [],
          removedUsers:  [],
          senderId:      _me.uid,
          senderName:    _me.fullName,
          senderImg:     _me.imgProfile,
          isGroup:       _providerNavigation.isGroup,
          date:          Timestamp.now()
      );

      _chatUsers.forEach((user){
        chat.addedUsers.add(user.fcmToken);
        MyChatUser chatUser = MyChatUser(uid: user.uid, name: user.fullName, img: user.imgProfile);
        chat.usersForWrite.add(chatUser.toMap());
      });

      if(_providerNavigation.isGroup){
        chat.admins.add(_me.uid);
      }

      String chatId = await Database.instance.createChat(chat, _providerNavigation.groupIcon);
      _me.chats.add(chatId);
      await Database.instance.updateUserData(_me);

      _chatUsers.forEach((user) async {
        if(user.uid != _me.uid){
          user.chats.add(chatId);
          await Database.instance.updateOtherUser(user);
        }
      });
    }

    else if(!_providerNavigation.isGroup){
      String chatId = _me.chattedFriends[_chatUsers[0].uid];

      if(_me.deletedChats.contains(chatId)){
        // show old chat
        _me.deletedChats.remove(chatId);
        await Database.instance.updateUserData(_me);
      }
    }
  }
}