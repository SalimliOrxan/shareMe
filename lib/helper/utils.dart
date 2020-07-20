import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_me/provider/providerNavigation.dart';


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

void showLoading(BuildContext context){
  showDialog(
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

Stopwatch showVerificationDialog(BuildContext context){
  Stopwatch stopwatch = Stopwatch();
  String sending = 'Verification email is sending';
  String sent    = 'Verification email has been sent';

  showDialog(
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

Future<File> pickImage(bool isCamera) async {
  final pickedFile = await _picker.getImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
  return pickedFile != null ? File(pickedFile.path) : null;
}

Future<File> pickVideo(bool isCamera) async {
  final pickedFile = await _picker.getVideo(source: isCamera ? ImageSource.camera : ImageSource.gallery, maxDuration: Duration(minutes: 10));
  return pickedFile != null ? File(pickedFile.path) : null;
}