
import 'package:flutter/material.dart';

Future<void> showDialogFab(BuildContext context, Widget view) async {
  return showDialog(
      context: context,
      child: Container(
        height: 200,
        width: 400,
        child: view
      )
  );
}