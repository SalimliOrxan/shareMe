import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_me/provider/providerNavigation.dart';
import 'package:share_me/service/auth.dart';


final _picker = ImagePicker();


Future<void> showDialogFab(BuildContext context, Widget view) async {
  return await showDialog(
      context: context,
      child: Container(
          height: 200,
          width: 400,
          child: view
      )
  );
}

Future<void> showToast(String message, bool isError) async {
  await Fluttertoast.showToast(
    msg: message,
    backgroundColor: isError ? Colors.red : Colors.green,
    gravity: ToastGravity.CENTER,
    textColor: Colors.white,
  );
}

void showSnackBar(GlobalKey<ScaffoldState> key, String message, bool isError){
  final snack = SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: Duration(seconds: 2),
      content: Text(
          message,
          style: TextStyle(color: Colors.white)
      )
  );
  key.currentState.showSnackBar(snack);
}

Future<bool> hasConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
      return true;
    }
  } on SocketException catch(e){
    print(e.toString());
  }
  return false;
}

Future<void> showLoading(BuildContext context) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _context){
        return WillPopScope(
            onWillPop: () => null,
            child: SpinKitRipple(
              color: Colors.white,
              size: 120.0,
              borderWidth: 20,
              duration: Duration(seconds: 1, milliseconds: 200),
            )
        );
      }
  );
}

Future<Stopwatch> showVerificationDialog(BuildContext context) async {
  Stopwatch stopwatch = Stopwatch();
  String sending = 'Verification email is sending';
  String sent    = 'Verification email has been sent';

  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _context){
        return Consumer<ProviderNavigation>(
            builder: (context, snapshot, child){
              return WillPopScope(
                onWillPop: () => null,
                child: AlertDialog(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                  elevation: 5,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        snapshot.status,
                        style: TextStyle(
                            color: Colors.lightGreenAccent
                        ),
                      ),
                      Text(
                        'Waiting for approving...',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                      Visibility(
                        visible: !snapshot.visibleButton,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            snapshot.time,
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    Visibility(
                      visible: snapshot.visibleButton,
                      child: RaisedButton(
                        onPressed: () async {
                          snapshot.visibleButton = false;
                          snapshot.status = sending;

                          await FirebaseAuth.instance.currentUser()..sendEmailVerification();

                          int time = 60;
                          stopwatch.start();
                          Timer.periodic(Duration(seconds: 1), (timer) async {
                            if(stopwatch.isRunning){
                              if(timer.tick == time){
                                timer.cancel();
                                snapshot.visibleButton = true;
                                snapshot.time = time.toString();
                              } else {
                                snapshot.time = (time - timer.tick).toString();
                              }
                            } else {
                              timer.cancel();
                              snapshot.visibleButton = true;
                              snapshot.time = time.toString();
                            }
                          });
                          snapshot.status = sent;
                        },
                        child: Text('Send again'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        color: Colors.deepOrange,
                      ),
                    )
                  ],
                ),
              );
            }
        );
      }
  );
  return stopwatch;
}

Future<void> showExitDialog(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext _context){
        return AlertDialog(
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
          ),
          elevation: 5,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Are you sure?',
                style: TextStyle(
                    color: Colors.white
                ),
              )
            ]
          ),
          actions: <Widget>[
            RaisedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
              ),
              color: Colors.deepOrange,
            ),
            RaisedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Auth.instance.logout();
              },
              child: Text('Exit'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
              ),
              color: Colors.deepOrange
            )
          ]
        );
      }
  );
}

Future<void> showImageDialog(BuildContext context, String url) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _context){
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white)
          ),
          body: Center(
            child: Container(
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(url),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained * 2,
              )
            )
          )
        );
      }
  );
}

Future<File> pickImage(bool isCamera) async {
  final pickedFile = await _picker.getImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
  return pickedFile != null ? File(pickedFile.path) : null;
}

Future<File> pickVideo(bool isCamera) async {
  final pickedFile = await _picker.getVideo(source: isCamera ? ImageSource.camera : ImageSource.gallery, maxDuration: Duration(minutes: 10));
  return pickedFile != null ? File(pickedFile.path) : null;
}