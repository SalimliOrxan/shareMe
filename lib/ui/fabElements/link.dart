import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/comment.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerFab.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/home/navigationHomePage.dart';

class Link extends StatefulWidget {

  final ScrollController controller;
  Link({@required this.controller});

  @override
  _LinkState createState() => _LinkState();
}


class _LinkState extends State<Link> {

  ProviderFab _providerFab;
  List<User>_friendsData;
  User _me;
  TextEditingController _controllerTitle;
  TextEditingController _controllerUrl;

  @override
  void initState() {
    _controllerTitle = TextEditingController();
    _controllerUrl   = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    _controllerUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerFab = Provider.of<ProviderFab>(context);
    _friendsData = Provider.of<List<User>>(context);
    _me          = Provider.of<User>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
            controller: widget.controller,
            child: Column(
                children: <Widget>[
                  _titleField(),
                  _linkField(),
                  _postButton()
                ]
            )
        )
    );
  }

  Widget _titleField(){
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: TextFormField(
          controller: _controllerTitle,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                      color: Colors.blueGrey
                  )
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              )
          ),
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.multiline
      )
    );
  }

  Widget _linkField(){
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: TextFormField(
          controller: _controllerUrl,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Url',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                      color: Colors.blueGrey
                  )
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              )
          ),
          keyboardType: TextInputType.url
      )
    );
  }

  Widget _postButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Container(
        width: double.infinity,
        child: RaisedButton(
          onPressed: _post,
          color: Colors.deepOrange,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
          ),
          child: Text(
            'Post',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }



  void _post() async {
    showLoading(context);

    Post newPost = Post();
    newPost.uid      = _me.uid;
    newPost.fullName = _me.fullName;
    newPost.userImg  = _me.imgProfile;
    newPost.title    = _controllerTitle.text.trim();
    newPost.fileUrl  = _controllerUrl.text.trim();
    newPost.fileType = Fab.link.toString();

    String postId = await Database.instance.createPost(newPost, null);
    await Database.instance.createComments(Comment()..commentId = postId);
    await Database.instance.updateUserData(_me..posts.add(postId));

    Navigator.pop(context);
    Navigator.pop(context);

    for(int i=0; i<_me.friends.length; i++){
      _friendsData[i].posts.add(postId);
      await Database.instance.updateOtherUser(_friendsData[i]);
    }
  }
}