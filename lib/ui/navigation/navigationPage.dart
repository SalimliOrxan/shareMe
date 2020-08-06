import 'dart:async';
import 'dart:io';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigation.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/chat/chat.dart';
import 'package:share_me/ui/navigation/home/navigationHomePage.dart';
import 'package:share_me/ui/navigation/notification/notification.dart';
import 'package:share_me/ui/navigation/profile/navigationProfilePage.dart';
import 'package:share_me/ui/navigation/search/search.dart';

class NavigationPage extends StatefulWidget {

  _NavigationPageState createState() => _NavigationPageState();
}


class _NavigationPageState extends State<NavigationPage> {

  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  ProviderNavigation _providerNavigation;
  User _me;
  List<Widget>_pages;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _providerNavigation.positionPage = 0;
    });
  }

  @override
  void dispose() {
    iosSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerNavigation = Provider.of<ProviderNavigation>(context);
    _me                 = Provider.of<User>(context);

    _initFcm();
    _initPages();

    return _me == null ? Container() : Scaffold(
      backgroundColor: colorApp,
      body: WillPopScope(
        child: _body(),
        onWillPop: null,
      ),
      bottomNavigationBar: _navigationBar(),
    );
  }



  Widget _body(){
    return SafeArea(
        child: _pages[_providerNavigation.positionPage]
    );
  }

  Widget _navigationBar(){
    return CurvedNavigationBar(
        height: 50,
        color: Colors.black54,
        backgroundColor: Colors.transparent,
        animationDuration: Duration(milliseconds: 600),
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.deepOrange),
          Icon(Icons.chat, size: 30, color: Colors.deepOrange),
          Icon(Icons.search, size: 30, color: Colors.deepOrange),
          Stack(
            children: <Widget>[
              Icon(Icons.notifications, size: 30, color: Colors.deepOrange),
              Visibility(
                visible: _me != null && _me.countNotification > 0,
                child: Positioned(
                    top: -2,
                    right: -1,
                    child: Text(
                        _me?.countNotification.toString() ?? '0',
                        style: TextStyle(fontSize: 10, color: Colors.white)
                    )
                ),
              )
            ],
          ),
          Icon(Icons.person, size: 30, color: Colors.deepOrange)
        ],
        index: 0,
        onTap: (index) => _providerNavigation.positionPage = index
    );
  }


  void _initPages(){
    if(_me != null){
      _pages = List();
      _pages.add(
          StreamProvider.value(
              value: Database.instance.getPosts(_me?.posts),
              child: HomePage()
          )
      );
      _pages.add(
          MultiProvider(
              providers: [
                StreamProvider.value(value: Database.instance.usersByUid(_me?.friends ?? [])),
                StreamProvider.value(value: Database.instance.getChats(_me?.chats?.values?.toList() ?? []))
              ],
              child: ChatPage()
          )
      );
      _pages.add(SearchPage());
      _pages.add(
          StreamProvider.value(
            value: Database.instance.usersByUid(_me?.followRequests ?? []),
            child: NotificationPage()
          )
      );
      _pages.add(ProfilePage());
    }
  }

  Future<void> _initFcm() async {
    // _me?.fcmToken for new registration case after logout
    if(_me != null && (!_providerNavigation.isFcmInitialised || _me.fcmToken.isEmpty)){
      if(Platform.isIOS){
        iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
          // subscribe to a topic here
        });
        _fcm.requestNotificationPermissions(IosNotificationSettings());
      }

      String token = await _fcm.getToken();
      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );


      _me.fcmToken = token;
      await Database.instance.updateUserData(_me);
      _providerNavigation.isFcmInitialised = true;
    }
  }
}