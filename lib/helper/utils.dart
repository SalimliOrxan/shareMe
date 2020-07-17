import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'file:///C:/Users/MSI%20GAMING/code/Flutter/ShareMe/share_me/lib/helper/customValues.dart';



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
            onWillPop: (){},
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