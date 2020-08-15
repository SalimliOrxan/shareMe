import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/chatUser.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerChat.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/chat/chatMessages.dart';
import 'package:share_me/ui/navigation/chat/friendsView.dart';
import 'package:share_me/ui/navigation/chat/groupIcon.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

enum Creation{personal, group}

class _ChatPageState extends State<ChatPage> {

  ProviderChat _providerChat;
  List<User> _friends, _chatUsers = [];
  List<Message> _chats;
  User _me;
  TextEditingController _controllerGroupName;
  ScrollController _scrollController;
  bool _isGroup;

  @override
  void initState() {
    _controllerGroupName = TextEditingController();
    _scrollController    = ScrollController();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _scrollController?.addListener((){
        if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
          if(_providerChat.isFabVisible){
            _providerChat.isFabVisible = false;
          }
        } else {
          if(_scrollController.position.userScrollDirection == ScrollDirection.forward){
            if(!_providerChat.isFabVisible) {
              _providerChat.isFabVisible = true;
            }
          }
        }});
    });
  }

  @override
  void dispose() {
    _controllerGroupName.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerChat = Provider.of(context);
    _friends      = Provider.of<List<User>>(context);
    _chats        = Provider.of<List<Message>>(context);
    _me           = Provider.of<User>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _chats == null || _chats.length == 0 ? _emptyBody() : _body(),
        floatingActionButton: _fab()
    );
  }


  Widget _fab(){
    return SpeedDial(
      marginRight: 18,
      marginBottom: 18,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: _providerChat.isFabVisible,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.transparent,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(Icons.person_add),
            backgroundColor: Colors.purple,
            label: 'Personal chat',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _pressedItemsFAB(Creation.personal)
        ),
        SpeedDialChild(
            child: Icon(Icons.group_add),
            backgroundColor: Colors.orange,
            label: 'Group chat',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _pressedItemsFAB(Creation.group)
        )
      ]
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
        controller: _scrollController,
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

    Message chat = _chats.elementAt(position);

    if(chat.usersForRead[0].uid == _me.uid){
      img  = chat.usersForRead[1].img;
      name = chat.usersForRead[1].name;
    } else {
      img  = chat.usersForRead[0].img;
      name = chat.usersForRead[0].name;
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

  void _pressedItemsFAB(Creation type){
    switch(type){
      case Creation.personal:
        _isGroup = false;
        break;
      case Creation.group:
        _isGroup = true;
        break;
    }
    _showCreateChatDialog();
  }

  Future<void>_deleteChat(int position) async {
    _me.deletedChats.add(_chats[position].chatId);
    await Database.instance.updateUserData(_me);
  }

  Future<void>_showCreateChatDialog() async {
    if(_friends != null && _friends.length != 0){
      _providerChat.selectedChatUserPositions = [];
      _providerChat.groupIcon = null;
      _controllerGroupName.clear();

      await showDialog(
          context: context,
          builder: (BuildContext _context){
            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(10),
              backgroundColor: colorApp,
              content: Container(height: 500, child: FriendsView(friends: _friends, chat: null, forAdmin: false, isGroup: _isGroup)),
              actions: <Widget>[
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.deepOrange, size: 30)
                ),
                IconButton(
                  onPressed: (){
                    if(_providerChat.selectedChatUserPositions.length > 0){
                      Navigator.pop(context);

                      _chatUsers = [];
                      _providerChat.selectedChatUserPositions.forEach((position){
                        _chatUsers.add(_friends[position]);
                      });
                      _chatUsers.add(_me);

                      if(_isGroup){
                        _showGroupDialog();
                      } else _createPersonalChat();
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
                      _createGroupChat();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.deepOrange
                )
              )
            ]
          );
        }
    );
  }

  Future<void>_createPersonalChat() async {
    if(_me.chattedFriends.containsKey(_chatUsers[0].uid)){
      // chat already exists
      String chatId = _me.chattedFriends[_chatUsers[0].uid];

      if(_me.deletedChats.contains(chatId)){
        // show old chat
        _me.deletedChats.remove(chatId);
        await Database.instance.updateUserData(_me);
      }
    } else {
      // create new chat
      int colorPosition = 0;
      Message chat = Message(
          groupName:      _controllerGroupName.text.trim(),
          usersForWrite:  [],
          admins:         [],
          fcmTokens:      [],
          senderFcmToken: _me.fcmToken,
          isGroup:        _isGroup,
          date:           Timestamp.now()
      );

      _chatUsers.forEach((user){
        if(colorPosition == 16) colorPosition = 0;
        chat.fcmTokens.add(user.fcmToken);
        MyChatUser chatUser = MyChatUser(
            uid:   user.uid,
            name:  user.fullName,
            img:   user.imgProfile,
            color: colorPosition
        );
        chat.usersForWrite.add(chatUser.toMap());
        colorPosition++;
      });

      String chatId = await Database.instance.createChat(chat, null);
      _me.chats.add(chatId);
      _me.chattedFriends[_chatUsers[0].uid] = chatId;
      await Database.instance.updateUserData(_me);

      _chatUsers.forEach((user) async {
        if(user.uid != _me.uid){
          user.chats.add(chatId);
          user.chattedFriends[_me.uid] = chatId;
          await Database.instance.updateOtherUser(user);
        }
      });
    }
  }

  Future<void>_createGroupChat() async {
    // create new chat
    int colorPosition = 0;
    Message chat = Message(
        groupName:      _controllerGroupName.text.trim(),
        usersForWrite:  [],
        admins:         [],
        fcmTokens:      [],
        senderFcmToken: _me.fcmToken,
        isGroup:        _isGroup,
        date:           Timestamp.now()
    );


    _chatUsers.forEach((user){
      if(colorPosition == 16) colorPosition = 0;
      chat.fcmTokens.add(user.fcmToken);
      chat.admins.add(_me.uid);

      MyChatUser chatUser = MyChatUser(
          uid:   user.uid,
          name:  user.fullName,
          img:   user.imgProfile,
          color: colorPosition
      );
      chat.usersForWrite.add(chatUser.toMap());
      colorPosition++;
    });

    String chatId = await Database.instance.createChat(chat, _providerChat.groupIcon);
    _me.chats.add(chatId);
    await Database.instance.updateUserData(_me);

    _chatUsers.forEach((user) async {
      if(user.uid != _me.uid){
        user.chats.add(chatId);
        await Database.instance.updateOtherUser(user);
      }
    });
  }
}