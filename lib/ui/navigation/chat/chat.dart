import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/chat/chatMessages.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  List<User> _friends;
  List<Message> _chats;
  User _me;
  User _selectedUser;

  @override
  Widget build(BuildContext context) {
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
        onPressed: (){
          _showChatDialog(context, _friends);
        },
        mini: true,
        child: Icon(Icons.edit)
    );
  }

  Widget _body(){
    return _messageView();
  }

  Widget _emptyBody(){
    return Center(child: Icon(Icons.chat, size: 100, color: Colors.deepOrange));
  }

  Widget _messageView(){
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _chats.length,
        itemBuilder: (context, position){
          return _itemMessage(position);
        }
    );
  }

  Widget _itemMessage(int position){
    String img;
    String name;
    String otherUserId;

    if(_chats.elementAt(position).senderId == _me.uid){
      otherUserId = _chats.elementAt(position).receiverId;
      img         = _chats.elementAt(position).receiverImg;
      name        = _chats.elementAt(position).receiverName;
    } else {
      otherUserId  = _chats.elementAt(position).senderId;
      img          = _chats.elementAt(position).senderImg;
      name         = _chats.elementAt(position).senderName;
    }

    return Visibility(
      visible: _me.chatsVisibility[otherUserId],
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
                    _selectedUser = _friends.firstWhere((user) => user.uid == otherUserId);
                    _itemMessagePressed(position);
                  },
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  leading: img.isEmpty
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
                      name,
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
                  _selectedUser = _friends.firstWhere((user) => user.uid == otherUserId);
                  _deleteChat(position);
                }
            )
          ]
      )
    );
  }

  Widget _itemUserForDialog(User user){
    return Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
        width: double.infinity,
        child: ListTile(
            onTap: () => _itemDialogPressed(user),
            contentPadding: EdgeInsets.zero,
            leading: user.imgProfile.isEmpty
                ? Container(width: 40, height: 40, child: icUser)
                : Container(
              width: 40,
              child: CachedNetworkImage(
                  imageUrl: user.imgProfile,
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
            trailing: Icon(Icons.check, color: Colors.deepOrange, size: 20),
            title: Text(
                user.fullName ?? '',
                style: TextStyle(color: Colors.white)
            )
        )
    );
  }



  Future<void>_showChatDialog(BuildContext context, List<User>friends) async {
    if(friends != null && friends.length != 0){
      await showDialog(
          context: context,
          builder: (BuildContext _context){
            return Scaffold(
                body: Center(
                  child: ListView.builder(
                      itemCount: friends.length,
                      shrinkWrap: true,
                      itemBuilder: (context, position){
                        return _itemUserForDialog(friends[position]);
                      }
                  ),
                )
            );
          }
      );
    }
  }

  Future<void>_itemDialogPressed(User user) async {
    _selectedUser = user;
    Navigator.pop(context);

    if(!_me.chats.containsKey(_selectedUser.uid)){
      // create new chat
      Message chat = Message()
        ..receiverId   = _selectedUser.uid
        ..receiverName = _selectedUser.fullName
        ..receiverImg  = _selectedUser.imgProfile
        ..senderId     = _me.uid
        ..senderName   = _me.fullName
        ..senderImg    = _me.imgProfile
        ..date         = Timestamp.now();

      String chatId = await Database.instance.createChat(chat);
      _me.chats[_selectedUser.uid] = chatId;
      _me.chatsVisibility[_selectedUser.uid] = true;
      _selectedUser.chats[_me.uid] = chatId;
      _selectedUser.chatsVisibility[_me.uid] = false;
      await Database.instance.updateUserData(_me);
      await Database.instance.updateOtherUser(_selectedUser);
    }
    else if(!_me.chatsVisibility[_selectedUser.uid]){
      // show old chat if was deleted
      _me.chatsVisibility[_selectedUser.uid] = true;
      _selectedUser.chatsVisibility[_me.uid] = true;
      await Database.instance.updateUserData(_me);
      await Database.instance.updateOtherUser(_selectedUser);
    }
  }

  Future<void>_itemMessagePressed(int position) async {
    Navigator
        .of(context)
        .push(MaterialPageRoute(
        builder: (_) => StreamProvider.value(
            value: Database.instance.getChatById(_chats[position].chatId),
            child: ChatMessages(me: _me, receiver: _selectedUser)
        )
    ));
  }

  Future<void>_deleteChat(int position) async {
    _me.chatsVisibility[_selectedUser.uid] = false;
    await Database.instance.updateUserData(_me);
  }
}