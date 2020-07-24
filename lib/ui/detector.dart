import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigation.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/sign/signPage.dart';

import 'navigation/navigationPage.dart';

class Detector extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    final nav = Provider.of<ProviderNavigation>(context);
    _getUid();

    return user == null
        ? SignPage()
        : ((user.isEmailVerified || nav.isVerified)
        ? StreamProvider.value(value: Database.instance.currentUserData, child: NavigationPage())
        : SignPage());
  }

  Future<void>_getUid() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Auth.instance.uid = user?.uid;
  }
}