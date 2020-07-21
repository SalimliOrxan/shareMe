import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/validation.dart';
import 'package:share_me/model/updateCredential.dart';
import 'package:share_me/service/auth.dart';

class EmailPage extends StatefulWidget {

  @override
  _EmailPageState createState() => _EmailPageState();
}


class _EmailPageState extends State<EmailPage> {

  GlobalKey<FormState> _keyForm;
  final _credential = UpdateCredential();

  @override
  void initState() {
    _keyForm = GlobalKey();
    super.initState();
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
        padding: const EdgeInsets.fromLTRB(38, 0, 38, 10),
        child: Form(
          key: _keyForm,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                    children: <Widget>[
                      _newEmail(),
                      _password()
                    ]
                ),
                _changeButton()
              ]
          )
        )
      ),
    );
  }

  Widget _newEmail(){
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'New email',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          validator: (email){
            return validateEmail(email) ? null : 'email is wrong';
          },
          onSaved: (email) => _credential.email = email.trim()
      )
    );
  }

  Widget _password(){
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Password',
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

  Widget _changeButton(){
    return Container(
        width: double.infinity,
        child: RaisedButton(
            onPressed: () async {
              if(_keyForm.currentState.validate()){
                _keyForm.currentState.save();
                Auth.instance.updateEmail(_credential.email, _credential.currentPassword);
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