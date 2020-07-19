import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/models/user.dart';
import 'package:share_me/providers/providerNavigation.dart';
import 'package:share_me/ui/sign/signPage.dart';

import 'navigation/navigationPage.dart';

class Detector extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    final nav = Provider.of<ProviderNavigation>(context);

    return user == null ? SignPage() : ((user.isEmailVerified || nav.isVerified) ? NavigationPage() : SignPage());
  }
}