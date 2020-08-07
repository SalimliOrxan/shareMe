import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  ProviderNavigation _providerNavigation;
  List<User> _friends, _chatUsers = [];
  List<Message> _chats;
  User _me;

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
        onPressed: _showChatDialog,
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
          return _chats[position].usersForRead.length == 2 ? _itemPersonalChat(position) : _itemGroupChat(position);
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
        )
    );
  }

  Widget _itemGroupChat(int position){
    String name = _chats[position].groupName;
    String img  = _chats[position].groupImg;

    return Visibility(
        visible: !_me.deletedChats.contains(_chats[position].chatId),
        key: UniqueKey(),
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
        )
    );
  }

  Widget _itemUserForDialog(int position){
    return Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
        width: double.infinity,
        child: ListTile(
            onTap: (){
              if(_providerNavigation.selectedChatUserPositions.contains(position)){
                _providerNavigation.removeSelectedChatUserPositions(position);
              } else _providerNavigation.addSelectedChatUserPositions(position);
              Navigator.pop(context);
              _showChatDialog();
            },
            contentPadding: EdgeInsets.zero,
            leading: _friends[position].imgProfile.isEmpty
                ? Container(width: 40, height: 40, child: icUser)
                : Container(
              width: 40,
              child: CachedNetworkImage(
                  imageUrl: _friends[position].imgProfile,
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
              ),
            ),
            trailing: _providerNavigation.selectedChatUserPositions.contains(position) ? Icon(Icons.check, color: Colors.deepOrange, size: 20) : null,
            title: Text(
                _friends[position].fullName ?? '',
                style: TextStyle(color: Colors.white)
            )
        )
    );
  }



  Future<void>_createChat() async {
    bool chatExists = false;
    bool isGroup = true;

    if(_chatUsers.length == 2){
      // it is not group
      isGroup = false;
      if(_me.chattedFriends.containsKey(_chatUsers[0].uid)){
        // chat already exists
        chatExists = true;
      }
    }

    if(!chatExists){
      // create new chat
      Message chat = Message()
        ..usersForWrite = []
        ..senderId      = _me.uid
        ..senderName    = _me.fullName
        ..senderImg     = _me.imgProfile
        ..date          = Timestamp.now();

      _chatUsers.forEach((user){
        chat.usersForWrite.add(MyChatUser(uid: user.uid, name: user.fullName, img: user.imgProfile).toMap());
      });

      String chatId = await Database.instance.createChat(chat);
      _me.chats.add(chatId);
      await Database.instance.updateUserData(_me);

      _chatUsers.forEach((user) async {
        if(user.uid != _me.uid){
          user.chats.add(chatId);
          await Database.instance.updateOtherUser(user);
        }
      });
    }

    else if(!isGroup){
      String chatId = _me.chattedFriends[_chatUsers[0].uid];

      if(_me.deletedChats.contains(chatId)){
        // show old chat
        _me.deletedChats.remove(chatId);
        await Database.instance.updateUserData(_me);
      }
    }
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

  Future<void>_showChatDialog() async {
    if(_friends != null && _friends.length != 0){
      //_providerNavigation.selectedChatUserPositions = [];

      await showDialog(
          context: context,
          builder: (BuildContext _context){
            return Scaffold(
                body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ListView.builder(
                              itemCount: _friends.length,
                              shrinkWrap: true,
                              itemBuilder: (context, position) => _itemUserForDialog(position)
                          ),
                          Container(
                            height: 30,
                            width: 50,
                            child: RaisedButton(
                              onPressed: (){
                                Navigator.pop(context);
                                _chatUsers = [];
                                _providerNavigation.selectedChatUserPositions.forEach((position){
                                  _chatUsers.add(_friends[position]);
                                });
                                _chatUsers.add(_me);
                                _createChat();
                              },
                              child: Text(
                                'ok',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.deepOrange,
                            ),
                          )
                        ]
                    )
                )
            );
          }
      );
    }
  }
}