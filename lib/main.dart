import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_me/providers/navigationProvider.dart';
import 'package:share_me/providers/providerFab.dart';
import 'package:share_me/providers/providerNavigationHome.dart';

import 'ui/sign/signPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome
      .setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value){
    runApp(
        MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ProviderNavigation()),
              ChangeNotifierProvider(create: (_) => ProviderNavigationHome()),
              ChangeNotifierProvider(create: (_) => ProviderFab())
            ],
            child: MyApp()
        )
    );
  });
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignPage()
    );
  }
}