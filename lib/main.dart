import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/localData.dart';
import 'package:share_me/providers/navigationProvider.dart';
import 'package:share_me/providers/providerFab.dart';
import 'package:share_me/providers/providerNavigationHome.dart';
import 'package:share_me/ui/navigation/navigationPage.dart';

import 'ui/sign/signPage.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome
      .setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    Widget page = await isLogin();
    runApp(
        MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ProviderNavigation()),
              ChangeNotifierProvider(create: (_) => ProviderNavigationHome()),
              ChangeNotifierProvider(create: (_) => ProviderFab())
            ],
            child: MyApp(page: page)
        )
    );
  });
}

Future<Widget> isLogin() async {
  await LocalData.instance.initSP();
  bool isLogin = LocalData.instance.getBool(LocalData.instance.login);
  return isLogin ? NavigationPage() : SignPage();
}

class MyApp extends StatelessWidget {

  final Widget page;
  MyApp({@required this.page});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: page
    );
  }
}