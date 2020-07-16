import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/utils/customValues.dart';

class NavigationProfilePage extends StatefulWidget {

  @override
  _NavigationProfilePageState createState() => _NavigationProfilePageState();
}

class _NavigationProfilePageState extends State<NavigationProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorApp,
      body: _body(),
    );
  }


  Widget _body(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _imageAndName(),
        SizedBox(height: 50),
        _logout(),
        _logout(),
        _logout(),
        _logout(),
        Spacer()
      ]
    );
  }

  Widget _imageAndName(){
    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage('https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__340.jpg')
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
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRFU7U2h0umyF0P6E_yhTX45sGgPEQAbGaJ4g&usqp=CAU')
                            )
                        )
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'John Doe',
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
        onPressed: (){

        },
        color: Colors.deepOrange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.exit_to_app, color: Colors.white, size: 30),
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