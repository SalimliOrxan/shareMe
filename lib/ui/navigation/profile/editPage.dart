import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/validation.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerProfile.dart';

class EditPage extends StatefulWidget {

  final User user;
  EditPage({@required this.user});

  @override
  _EditPageState createState() => _EditPageState();
}


class _EditPageState extends State<EditPage> {

  ProviderProfile _providerProfile;
  GlobalKey<FormState>_keyForm = GlobalKey();
  GlobalKey<ScaffoldState> _keyScaffold = GlobalKey();
  User _newUser = User();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _providerProfile.imgCover   = null;
      _providerProfile.imgProfile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _providerProfile = Provider.of<ProviderProfile>(context);

    return Scaffold(
        key: _keyScaffold,
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(38, 0, 38, 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _imageAndName(constraints.maxHeight),
                          Form(
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
                        ]
                    ),
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
                          _profileImgField()
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
              child: _providerProfile.imgCover == null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                    imageUrl: widget.user?.imgCover ?? '',
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(20))),
                    fit: BoxFit.cover
                )
              )
                  : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_providerProfile.imgCover, fit: BoxFit.cover)
              )
          ),
          Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final file = await pickImage(false);
                  _providerProfile.imgCover = file;
                },
                child: Container(
                    height: maxHeight / 3,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))
                    ),
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
    return Stack(
      children: <Widget>[
        _providerProfile.imgProfile == null
        ? CachedNetworkImage(
            imageUrl: widget.user?.imgProfile ?? '',
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => icUser,
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
                    )
                  ]
              );
            }
        )
        : Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: FileImage(_providerProfile.imgProfile),
                    fit: BoxFit.cover
                )
            )
        ),
        Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: () async {
                final file = await pickImage(false);
                _providerProfile.imgProfile = file;
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
            )
        )
      ],
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
                onPressed: update,
                padding: EdgeInsets.all(10),
                color: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
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


  void update(){
    if(_keyForm.currentState.validate()){
      _keyForm.currentState.save();
      bool hasUpdate = false;

      if(_newUser.name.isEmpty){
        _newUser.name = widget.user.name;
      } else hasUpdate = true;

      if(_newUser.surname.isEmpty){
        _newUser.surname = widget.user.surname;
      } else hasUpdate = true;

      if(_providerProfile.imgCover == null){
        _newUser.imgCover = widget.user.imgCover;
      } else hasUpdate = true;

      if(_providerProfile.imgProfile == null){
        _newUser.imgProfile = widget.user.imgProfile;
      } else hasUpdate = true;

      _newUser.email = widget.user.email;

      if(hasUpdate){
        _providerProfile.updateUserData(_keyScaffold, _newUser);
      } else showSnackBar(_keyScaffold, 'There is not any update', true);
    }
  }
}