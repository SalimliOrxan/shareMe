import 'package:flutter/material.dart';
import 'package:share_me/ui/navigation/navigationPage.dart';
import 'package:share_me/utils/customValues.dart';

class LoginPage extends StatefulWidget {

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  GlobalKey<FormState>_keyForm;

  @override
  void initState() {
    super.initState();
    _keyForm = GlobalKey();
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
      'People',
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
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: Colors.white)
            ),
            keyboardType: TextInputType.emailAddress
          ),
          TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white)
            ),
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
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
          onTap: (){},
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
        onPressed: (){
          Navigator
              .of(context)
              .pushReplacement(
              MaterialPageRoute(
                  builder: (_) => NavigationPage()
              )
          );


          if(_keyForm.currentState.validate()){
            _keyForm.currentState.save();
          } // else registerData = RequestRegisterData();
        },
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
        Text(
          "Register",
          style: TextStyle(color: Colors.deepOrange)
        )
      ]
    );
  }
}