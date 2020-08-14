import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_me/provider/providerChat.dart';
import 'package:share_me/provider/providerNavigation.dart';
import 'package:share_me/provider/providerFab.dart';
import 'package:share_me/provider/providerNavigationHome.dart';
import 'package:share_me/provider/providerProfile.dart';
import 'package:share_me/provider/providerSearch.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/ui/detector.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome
      .setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    runApp(
        MultiProvider(
            providers: [
              StreamProvider.value(value: Auth.instance.user),
              ChangeNotifierProvider(create: (_) => ProviderNavigation()),
              ChangeNotifierProvider(create: (_) => ProviderNavigationHome()),
              ChangeNotifierProvider(create: (_) => ProviderFab()),
              ChangeNotifierProvider(create: (_) => ProviderProfile()),
              ChangeNotifierProvider(create: (_) => ProviderSearch()),
              ChangeNotifierProvider(create: (_) => ProviderChat())
            ],
            child: MyApp()
        )
    );
  });
}

class MyApp extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Share Me',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            canvasColor: Colors.transparent
        ),
        home: Detector()
    );
  }
}