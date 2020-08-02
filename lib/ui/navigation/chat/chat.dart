import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/helper/customValues.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorApp,
      body: _body()
    );
  }


  Widget _body(){
    return Center(child: Icon(Icons.chat, size: 100, color: Colors.deepOrange));
  }
}