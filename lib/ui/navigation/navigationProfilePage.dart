import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/service/storage.dart';

class NavigationProfilePage extends StatefulWidget {

  @override
  _NavigationProfilePageState createState() => _NavigationProfilePageState();
}


class _NavigationProfilePageState extends State<NavigationProfilePage> {

  User _user;

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
    
    return Scaffold(
      backgroundColor: colorApp,
      body: _body()
    );
  }


  Widget _body(){
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _imageAndName(),
            SizedBox(height: 50),
            _logout()
          ]
      ),
    );
  }

  Widget _imageAndName(){
    return Container(
      height: 400,
      width: double.infinity,
      child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                final file = await pickImage(false);
                if(file != null) Storage.instance.uploadImageCover(_user, file);
              },
              child: Container(
                  height: 300,
                  width: double.infinity,
                  child: CachedNetworkImage(
                      imageUrl: _user?.imgCover ?? '',
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error, size: 30, color: Colors.white),
                      fit: BoxFit.cover
                  )
              ),
            ),
            Positioned(
              bottom: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorApp
                          )
                      ),
                      CachedNetworkImage(
                          imageUrl: _user?.imgProfile ?? '',
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Icon(Icons.error, size: 30, color: Colors.white),
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider){
                            return Container(
                                width: 100,
                                height: 100,
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _user?.name ?? '',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                      ),
                    ),
                  )
                ],
              ),
            )
          ]
      ),
    );
  }

  Widget _logout(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: RaisedButton(
        onPressed: () => Auth.instance.logout(),
        color: Colors.deepOrange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
            children: <Widget>[
              Icon(Icons.exit_to_app, color: Colors.white, size: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white)
                ),
              )
            ]
        ),
      ),
    );
  }
}