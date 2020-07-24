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
import 'package:share_me/ui/navigation/home/navigationHomePage.dart';
import 'package:share_me/ui/navigation/myPosts/navigationMyPostsPage.dart';
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
  User _userData;
  List<Widget>_pages;

  @override
  void initState() {
    super.initState();

    _initFcm();
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
    _userData           = Provider.of<User>(context);
    _initPages();

    return Scaffold(
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
          Icon(Icons.list, size: 30, color: Colors.deepOrange),
          Icon(Icons.search, size: 30, color: Colors.deepOrange),
          Icon(Icons.notifications, size: 30, color: Colors.deepOrange),
          Icon(Icons.person, size: 30, color: Colors.deepOrange)
        ],
        index: 0,
        onTap: (index) => _providerNavigation.positionPage = index
    );
  }

  void _initPages(){
    _pages = List();
    _pages.add(NavigationHomePage());
    _pages.add(NavigationMyPostsPage());
    _pages.add(NavigationSearchPage());
    _pages.add(
        StreamProvider.value(
            value: Database.instance.usersByUid(_userData?.followRequests ?? []),
            child: NavigationNotificationPage()
        )
    );
    _pages.add(NavigationProfilePage());
  }

  void _initFcm(){
    if(Platform.isIOS){
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.getToken().then((token){
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
    });
  }
}