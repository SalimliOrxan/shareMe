import 'package:flutter/material.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/localData.dart';
import 'package:share_me/ui/sign/registerPage.dart';

import 'loginPage.dart';

class SignPage extends StatefulWidget {

  _SignPageState createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {

  @override
  void initState() {
    super.initState();
    LocalData.instance.initSP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _icon(),
            _buttons()
          ],
        ),
      ),
    );
  }

  Widget _icon(){
    return Flexible(
        child: FractionallySizedBox(
            heightFactor: 1,
            child: Container(
                width: double.infinity,
                child: icPeople
            )
        )
    );
  }

  Widget _buttons(){
    return Flexible(
        child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Share Me',
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 25
                      ),
                    ),
                    Text(
                      'Easiest way to\nbe linked',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: (){
                                Navigator
                                    .of(context)
                                    .push(
                                    MaterialPageRoute(
                                        builder: (_) => LoginPage()
                                    )
                                );
                              },
                              padding: EdgeInsets.all(10),
                              color: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                                  side: BorderSide(color: Colors.white)
                              ),
                              child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20
                                  )
                              ),
                            ),
                          ),
                          Expanded(
                            child: RaisedButton(
                              onPressed: (){
                                Navigator
                                    .of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (_) => RegisterPage()
                                  )
                                );
                              },
                              padding: EdgeInsets.all(10),
                              color: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                  side: BorderSide(color: Colors.white)
                              ),
                              child: Text(
                                  'Register',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20
                                  )
                              )
                            )
                          )
                        ]
                    )
                  ]
              ),
            )
        )
    );
  }
}