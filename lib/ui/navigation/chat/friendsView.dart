import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/chatUser.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigation.dart';

class FriendsView extends StatelessWidget {

  final List<User>friends;
  final List<MyChatUser>chatUsers;
  FriendsView({@required this.friends, @required this.chatUsers});

  @override
  Widget build(BuildContext context) {
    ProviderNavigation providerNavigation = Provider.of(context);
    List<User>users = _detectFriendsWhoIsNotInChat(providerNavigation);

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
              itemCount: users.length,
              shrinkWrap: true,
              itemBuilder: (context, position) => _itemUserForDialog(context, providerNavigation, users, position)
          )
        ]
    );
  }


  Widget _itemUserForDialog(BuildContext context, ProviderNavigation providerNavigation, List<User>users, int position){
    return Container(
        width: double.infinity,
        child: ListTile(
            onTap: (){
              if(providerNavigation.selectedChatUserPositions.contains(position)){
                providerNavigation.removeSelectedChatUserPositions(position);
              } else providerNavigation.addSelectedChatUserPositions(position);
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
            trailing: providerNavigation.selectedChatUserPositions.contains(position) ? Icon(Icons.check, color: Colors.deepOrange, size: 20) : null,
            title: Text(
                users[position].fullName ?? '',
                style: TextStyle(color: Colors.white)
            )
        )
    );
  }

  List<User> _detectFriendsWhoIsNotInChat(ProviderNavigation providerNavigation){
    List<User> users = [];

    if(chatUsers != null){
      friends.forEach((friend){
        bool found = true;

        for(var user in chatUsers) {
          if(friend.uid == user.uid){
            found = false;
            break;
          }
        }
        if(found)users.add(friend);
      });
      providerNavigation.friendsIsNotInChat.addAll(users);
    } else users.addAll(friends);
    return users;
  }
}