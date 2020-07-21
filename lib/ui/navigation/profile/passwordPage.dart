import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/validation.dart';
import 'package:share_me/model/updateCredential.dart';
import 'package:share_me/service/auth.dart';

class PasswordPage extends StatefulWidget {

  @override
  _PasswordPageState createState() => _PasswordPageState();
}


class _PasswordPageState extends State<PasswordPage> {

  GlobalKey<FormState> _keyForm;
  TextEditingController _controllerNewPassword;
  final _credential = UpdateCredential();

  @override
  void initState() {
    _keyForm = GlobalKey();
    _controllerNewPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerNewPassword.dispose();
    super.dispose();
  }

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(38, 0, 38, 20),
        child: Form(
          key: _keyForm,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                    children: <Widget>[
                      _currentPassword(),
                      _newPassword(),
                      _newPasswordAgain()
                    ]
                ),
                _changeButton()
              ]
          ),
        ),
      ),
    );
  }

  Widget _currentPassword(){
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Current password',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          validator: (password){
            return validatePassword(password) ? null : 'password is wrong';
          },
          onSaved: (password) => _credential.currentPassword = password.trim()
      ),
    );
  }

  Widget _newPassword(){
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
          controller: _controllerNewPassword,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'New password',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          validator: (password){
            return validatePassword(password) ? null : 'password is weak';
          },
          onSaved: (password) => _credential.newPassword = password.trim()
      ),
    );
  }

  Widget _newPasswordAgain(){
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'New password again',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          validator: (password2){
            return validatePasswordAgain(_controllerNewPassword.text, password2) ? null : "passwords don't match";
          },
          onSaved: (password) => _credential.newPasswordAgain = password.trim()
      )
    );
  }

  Widget _changeButton(){
    return Container(
        width: double.infinity,
        child: RaisedButton(
            onPressed: () async {
              if(_keyForm.currentState.validate()){
                _keyForm.currentState.save();
                Auth.instance.updatePassword(_credential.currentPassword, _credential.newPassword);
              }
            },
            padding: EdgeInsets.all(10),
            color: Colors.deepOrange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
            ),
            child: Text(
                'Change',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 18
                )
            )
        )
    );
  }
}