import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/helper/auth.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/localData.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/helper/validation.dart';
import 'package:share_me/models/user.dart';
import 'package:share_me/ui/navigation/navigationPage.dart';

class RegisterPage extends StatefulWidget {

  @override
  _RegisterPageState createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {

  GlobalKey<FormState>_keyForm;
  User _user;
  Timer _timer;
  TextEditingController _controllerPassword;

  @override
  void initState() {
    super.initState();
    _keyForm = GlobalKey();
    _user = User();
    _controllerPassword = TextEditingController();
  }

  @override
  void dispose() {
    if(_timer != null)  _timer.cancel();
    _controllerPassword.dispose();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.deepOrange)
    );
  }

  Widget _body(){
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(38, 0, 38, 18),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _form(),
              _buttonRegister()
            ]
        ),
      ),
    );
  }

  Widget _form(){
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _keyForm,
          child: Column(
              children: <Widget>[
                _name(),
                _surname(),
                _email(),
                _password(),
                _passwordAgain()
              ]
          ),
        ),
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
          validator: (name){
            return validateUsername(name) ? null : 'fill name';
          },
          onSaved:  (name) => _user.name = name.trim()
      ),
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
          validator: (surname){
            return validateUsername(surname) ? null : 'fill surname';
          },
          onSaved:  (surname) => _user.surname = surname.trim()
      ),
    );
  }

  Widget _email(){
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: Colors.white)
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (email){
              return validateEmail(email) ? null : 'email is wrong';
            },
            onSaved: (email) => _user.email = email.trim()
        )
    );
  }

  Widget _password(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _controllerPassword,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          validator: (password){
            return validatePassword(password) ? null : 'password is weak';
          },
          onSaved: (password) => _user.password = password.trim()
      ),
    );
  }

  Widget _passwordAgain(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Password Again',
              labelStyle: TextStyle(color: Colors.white)
          ),
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          validator: (password2){
            return validatePasswordAgain(_controllerPassword.text, password2) ? null : "passwords don't match";
          },
          onSaved: (password) => _user.passwordAgain = password.trim()
      ),
    );
  }

  Widget _buttonRegister(){
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
          width: double.infinity,
          child: RaisedButton(
              onPressed: _registerApi,
              padding: EdgeInsets.all(10),
              color: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                  side: BorderSide(color: Colors.deepOrange)
              ),
              child: Text(
                  'Register',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18
                  )
              )
          )
      ),
    );
  }


  void _registerApi(){
    if(_keyForm.currentState.validate()){
      _keyForm.currentState.save();
      showLoading(context);

      Auth
          .instance
          .register(_user.email, _user.password)
          .then((user){
            if(user != null){
              Future(() async {
                _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
                  await FirebaseAuth.instance.currentUser()..reload();
                  var user = await FirebaseAuth.instance.currentUser();
                  if(user.isEmailVerified){
                    Navigator.of(context).pop();
                    timer.cancel();
                    await LocalData.instance.setBool(LocalData.instance.login, true);

                    Navigator
                        .of(context)
                        .pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => NavigationPage()
                        )
                    );
                  }
                });
              });
            } else Navigator.of(context).pop();
          }).catchError((onError){
            Navigator.of(context).pop();
          });
    } // else registerData = RequestRegisterData();
  }
}