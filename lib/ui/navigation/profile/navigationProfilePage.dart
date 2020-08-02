import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/ui/navigation/profile/editPage.dart';
import 'package:share_me/ui/navigation/profile/emailPage.dart';
import 'package:share_me/ui/navigation/profile/passwordPage.dart';

class ProfilePage extends StatefulWidget {

  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {

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
    return LayoutBuilder(
      builder: (context, constraints){
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: constraints.maxHeight
              ),
              child: Column(
                  children: <Widget>[
                    _imageAndName(constraints.maxHeight),
                    Container(
                      height: constraints.maxHeight / 2,
                      child: Center(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _editProfileField(),
                                  _line(),
                                  _changePasswordField(),
                                  _line(),
                                  _notificationField(),
                                  _line(),
                                  _logout()
                                ]
                            )
                        )
                      ),
                    )
                  ]
              )
            ),
          ),
        );
      }
    );
  }

  Widget _imageAndName(maxHeight){
    return Container(
        height: maxHeight / 2,
        width: double.infinity,
        child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                  height: maxHeight / 3,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                        imageUrl: _user?.imgCover ?? '',
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(20))),
                        fit: BoxFit.cover
                    )
                  )
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
                              errorWidget: (context, url, error) => icUser,
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
                        ]
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                              '${_user?.name ?? ''} ${_user?.surname ?? ''}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25
                              )
                          )
                      )
                    ],
                  )
              )
            ]
        )
    );
  }

  Widget _editProfileField(){
    return GestureDetector(
      onTap: (){
        Navigator
            .of(context)
            .push(MaterialPageRoute(
            builder: (_) => EditPage(user: _user)
        ));
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
        color: Colors.transparent,
        child: Row(
            children: <Widget>[
              Icon(Icons.edit, color: Colors.deepOrange, size: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                    'Edit profile',
                    style: TextStyle(color: Colors.white, fontSize: 20)
                )
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.keyboard_arrow_right, color: Colors.deepOrange, size: 20)
                )
              )
            ]
        )
      ),
    );
  }

  Widget _changeEmailField(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: RaisedButton(
        onPressed: (){
          Navigator
              .of(context)
              .push(MaterialPageRoute(
              builder: (_) => EmailPage()
          ));
        },
        color: Colors.deepOrange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
            children: <Widget>[
              Icon(Icons.email, color: Colors.white, size: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                    'Change email',
                    style: TextStyle(color: Colors.white)
                ),
              )
            ]
        ),
      )
    );
  }

  Widget _changePasswordField(){
    return GestureDetector(
      onTap: (){
            Navigator
                .of(context)
                .push(MaterialPageRoute(
                builder: (_) => PasswordPage()
            ));
          },
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        color: Colors.transparent,
        child: Row(
                children: <Widget>[
                  Icon(Icons.lock, color: Colors.deepOrange, size: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                        'Change password',
                        style: TextStyle(color: Colors.white, fontSize: 20)
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.keyboard_arrow_right, color: Colors.deepOrange, size: 20)
                    ),
                  )
                ]
            ),
      ),
    );
  }

  Widget _notificationField(){
    return GestureDetector(
      onTap: (){

      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        color: Colors.transparent,
        child: Row(
            children: <Widget>[
              Icon(Icons.notifications, color: Colors.deepOrange, size: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                    'Notification setting',
                    style: TextStyle(color: Colors.white, fontSize: 20)
                ),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.keyboard_arrow_right, color: Colors.deepOrange, size: 20)
                  )
              )
            ]
        ),
      ),
    );
  }

  Widget _line(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 25, 15),
      child: Container(
        width: double.infinity,
        height: 1,
        color: colorApp
      )
    );
  }

  Widget _logout(){
    return GestureDetector(
      onTap: () => showExitDialog(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        color: Colors.transparent,
        width: double.infinity,
        child: Row(
            children: <Widget>[
              Icon(Icons.exit_to_app, color: Colors.deepOrange, size: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 20)
                ),
              )
            ]
        ),
      ),
    );
  }
}