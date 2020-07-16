import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/utils/customValues.dart';

class NavigationMyPostsPage extends StatefulWidget {

  @override
  _NavigationMyPostsPageState createState() => _NavigationMyPostsPageState();
}

class _NavigationMyPostsPageState extends State<NavigationMyPostsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorApp,
      body: _body(),
    );
  }


  Widget _body(){
    return Center(child: Text('My Posts'));
  }
}