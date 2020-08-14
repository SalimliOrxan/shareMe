import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerChat.dart';

class FriendsView extends StatelessWidget {

  final List<User>friends;
  final Message chat;
  final bool forAdmin;
  FriendsView({@required this.friends, @required this.chat, @required this.forAdmin});

  @override
  Widget build(BuildContext context) {
    ProviderChat providerChat = Provider.of(context);
    List<User>users = _detectFriendsWhoIsNotInChat(providerChat);

    return Scaffold(
      body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _checkBoxGroup(providerChat),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
                itemCount: users.length,
                shrinkWrap: true,
                itemBuilder: (context, position) => _itemUserForDialog(context, providerChat, users, position)
            )
          ]
      )
    );
  }


  Widget _checkBoxGroup(ProviderChat providerChat){
    return Visibility(
      visible: chat == null,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Checkbox(
                onChanged: (value) => providerChat.isGroup = value,
                value: providerChat.isGroup
            ),
            Text(
                'Group',
                style: TextStyle(color: Colors.white)
            )
          ]
      )
    );
  }

  Widget _itemUserForDialog(BuildContext context, ProviderChat providerChat, List<User>users, int position){
    return Container(
        width: double.infinity,
        child: ListTile(
            onTap: (){
              if(providerChat.selectedChatUserPositions.contains(position)){
                providerChat.removeSelectedChatUserPositions(position);
              } else providerChat.addSelectedChatUserPositions(position);

              if(providerChat.selectedChatUserPositions.length > 1 && !providerChat.isGroup){
                providerChat.isGroup = true;
              }
            },
            contentPadding: EdgeInsets.zero,
            leading: users[position].imgProfile.isEmpty
                ? Container(width: 40, height: 40, child: icUser)
                : Container(
              width: 40,
              child: CachedNetworkImage(
                  imageUrl: users[position].imgProfile,
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
            trailing: providerChat.selectedChatUserPositions.contains(position) ? Icon(Icons.check, color: Colors.deepOrange, size: 20) : null,
            title: Text(
                users[position].fullName ?? '',
                style: TextStyle(color: Colors.white)
            )
        )
    );
  }

  List<User> _detectFriendsWhoIsNotInChat(ProviderChat providerChat){
    List<User> users = [];

    if(chat != null){
      if(forAdmin){
        chat.usersForRead.forEach((chatUser){
          bool found = true;

          for(var uid in chat.admins){
            if(chatUser.uid == uid){
              found = false;
              break;
            }
          }
          if(found) users.add(User(uid: chatUser.uid, fullName: chatUser.name, imgProfile: chatUser.img));
        });
        providerChat.friendsIsNotInChat.addAll(users);
      } else {
        friends.forEach((friend){
          bool found = true;

          for(var user in chat.usersForRead){
            if(friend.uid == user.uid){
              found = false;
              break;
            }
          }
          if(found) users.add(friend);
        });
        providerChat.friendsIsNotInChat.addAll(users);
      }
    } else users.addAll(friends);
    return users;
  }
}