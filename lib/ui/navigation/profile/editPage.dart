import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/validation.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/storage.dart';

class EditPage extends StatefulWidget {

  final User user;
  EditPage({@required this.user});

  @override
  _EditPageState createState() => _EditPageState();
}


class _EditPageState extends State<EditPage> {

  GlobalKey<FormState>_keyForm = GlobalKey();
  User _newUser = User();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: colorApp,
        appBar: _appBar(),
        body: _body()
    );
  }



  Widget _appBar(){
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      actionsIconTheme: IconThemeData(color: Colors.white),
    );
  }

  Widget _body(){
    return LayoutBuilder(
        builder: (context, constraints){
          return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: constraints.maxHeight
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _imageAndName(constraints.maxHeight),
                      Padding(
                        padding: EdgeInsets.fromLTRB(38, 10, 38, 20),
                        child: Form(
                          key: _keyForm,
                          child: Column(
                              children: <Widget>[
                                _name(),
                                _surname(),
                                _password(),
                                _buttonUpdate()
                              ]
                          ),
                        )
                      )
                    ]
                )
            )
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
              _coverField(maxHeight),
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
                              imageUrl: widget.user?.imgProfile ?? '',
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error, size: 30, color: Colors.white),
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider){
                                return Stack(
                                  children: <Widget>[
                                    Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover
                                            )
                                        )
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: _profileImgField()
                                    )
                                  ]
                                );
                              }
                          )
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                              '${widget.user?.name ?? ''} ${widget.user?.surname ?? ''}',
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

  Widget _coverField(maxHeight){
    return Stack(
        children: <Widget>[
          Container(
              height: maxHeight / 3,
              width: double.infinity,
              child: CachedNetworkImage(
                  imageUrl: widget.user?.imgCover ?? '',
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error, size: 30, color: Colors.white),
                  fit: BoxFit.cover
              )
          ),
          Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final file = await pickImage(false);
                  if(file != null) Storage.instance.uploadImageCover(widget.user, file);
                },
                child: Container(
                    height: maxHeight / 3,
                    width: 100,
                    color: Colors.black26,
                    child: Center(
                      child: Text(
                          'upload',
                          style: TextStyle(
                              color: Colors.white
                          )
                      ),
                    )
                ),
              )
          )
        ]
    );
  }

  Widget _profileImgField(){
    return GestureDetector(
      onTap: () async {
        final file = await pickImage(false);
        if(file != null) Storage.instance.uploadImageProfile(widget.user, file);
      },
      child: Container(
          width: 100,
          height: 39,
          decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))
          ),
          child: Center(
              child: Text(
                'upload',
                style: TextStyle(color: Colors.white),
              )
          )
      ),
    );
  }



  Widget _name(){
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white)
            ),
            keyboardType: TextInputType.text,
            onSaved: (name) => _newUser.name = name.trim()
        )
    );
  }

  Widget _surname(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Surname',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.text,
          onSaved: (surname) => _newUser.surname = surname.trim()
      ),
    );
  }

  Widget _password(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          validator: (password) => validateUsername(password) ? null : 'enter password',
          onSaved: (password) => _newUser.password = password.trim()
      )
    );
  }

  Widget _buttonUpdate(){
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
            width: double.infinity,
            child: RaisedButton(
                onPressed: (){
                  if(_keyForm.currentState.validate()){
                    _keyForm.currentState.save();


                  }
                },
                padding: EdgeInsets.all(10),
                color: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                    side: BorderSide(color: Colors.deepOrange)
                ),
                child: Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18
                    )
                )
            )
        )
    );
  }
}