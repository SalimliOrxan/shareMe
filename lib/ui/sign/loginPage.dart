import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/helper/validation.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/ui/sign/registerPage.dart';

class LoginPage extends StatefulWidget {

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  GlobalKey<FormState>_keyForm;
  User _user;
  TextEditingController _controllerEmail;
  Timer _timer;
  Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _keyForm = GlobalKey();
    _user = User();
    _controllerEmail = TextEditingController();
  }

  @override
  void dispose() {
    if(_timer != null)  _timer.cancel();
    if(_stopwatch != null && _stopwatch.isRunning)  _stopwatch.stop();
    _controllerEmail.dispose();
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
        padding: EdgeInsets.fromLTRB(38, 0, 38, 18),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _title(),
              _description(),
              _form(),
              _login(),
              _register()
            ]
        )
      ),
    );
  }

  Widget _title(){
    return Text(
      'Share Me',
      style: TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.bold,
          fontSize: 25
      ),
    );
  }

  Widget _description(){
    return Text(
      'Hello there!\nWelcome Back',
      style: TextStyle(
          fontSize: 25,
          color: Colors.white
      ),
    );
  }

  Widget _form(){
    return Form(
      key: _keyForm,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _controllerEmail,
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
          ),
          TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white)
            ),
            keyboardType: TextInputType.visiblePassword,

            obscureText: true,
            onSaved: (password) => _user.password = password.trim()
          ),
          _forgot()
        ]
      ),
    );
  }

  Widget _forgot(){
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: (){
            if(_controllerEmail.text.isNotEmpty && _controllerEmail.text != null){
              showLoading(context);
              Auth
                  .instance
                  .resetPassword(_controllerEmail.text)
                  .whenComplete(() => Navigator.of(context).pop());
            } else showToast('Fill email address', true);
          },
          child: Text(
            'Forgot your password?',
            style: TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.w500
            ),
          )
        ),
      ),
    );
  }

  Widget _login(){
    return Container(
      width: double.infinity,
      child: RaisedButton(
        onPressed: _loginApi,
        padding: EdgeInsets.all(10),
        color: Colors.deepOrange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
            side: BorderSide(color: Colors.deepOrange)
        ),
        child: Text(
            'Sign In',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 18
            )
        ),

      ),
    );
  }

  Widget _register(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: Colors.grey
          )
        ),
        InkWell(
          onTap: (){
            Navigator
                .of(context)
                .pushReplacement(
                MaterialPageRoute(
                    builder: (_) => RegisterPage()
                )
            );
          },
          child: Text(
            "Register",
            style: TextStyle(color: Colors.deepOrange)
          ),
        )
      ]
    );
  }


  void _loginApi() async {
    if(_keyForm.currentState.validate()){
      _keyForm.currentState.save();

       showLoading(context);

      Auth.instance.login(_user.email, _user.password).then((user) async {
        if(user != null){
          if(user.isEmailVerified){
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            _stopwatch = showVerificationDialog(context);

            _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
              await FirebaseAuth.instance.currentUser()..reload();
              var user = await FirebaseAuth.instance.currentUser();
              if(user.isEmailVerified){
                if(_stopwatch.isRunning) _stopwatch.stop();
                timer.cancel();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            });
          }
        } else Navigator.of(context).pop();
      }).catchError((error){
        Navigator.of(context).pop();
      });
    } // else registerData = RequestRegisterData();
  }
}