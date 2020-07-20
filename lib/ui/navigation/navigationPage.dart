import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/provider/providerNavigation.dart';
import 'package:share_me/ui/navigation/navigationHomePage.dart';
import 'package:share_me/ui/navigation/navigationMyPostsPage.dart';
import 'package:share_me/ui/navigation/navigationProfilePage.dart';

class NavigationPage extends StatefulWidget {

  _NavigationPageState createState() => _NavigationPageState();
}


class _NavigationPageState extends State<NavigationPage> {

  ProviderNavigation _providerNavigation;
  List<Widget>_pages;

  @override
  void initState() {
    _pages = List();
    _pages.add(NavigationHomePage());
    _pages.add(NavigationMyPostsPage());
    _pages.add(NavigationProfilePage());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _providerNavigation.positionPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _providerNavigation = Provider.of<ProviderNavigation>(context);

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
          Icon(Icons.person, size: 30, color: Colors.deepOrange)
        ],
        index: 0,
        onTap: (index) => _providerNavigation.positionPage = index
    );
  }
}