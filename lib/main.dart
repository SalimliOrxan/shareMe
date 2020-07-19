import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/auth.dart';
import 'package:share_me/providers/providerNavigation.dart';
import 'package:share_me/providers/providerFab.dart';
import 'package:share_me/providers/providerNavigationHome.dart';
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
              ChangeNotifierProvider(create: (_) => ProviderFab())
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
        ),
        home: Detector()
    );
  }
}