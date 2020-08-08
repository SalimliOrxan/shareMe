import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/provider/providerNavigation.dart';

class GroupIcon extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    ProviderNavigation providerNavigation = Provider.of(context);

    return _groupIcon(providerNavigation);
  }

  Widget _groupIcon(ProviderNavigation providerNavigation){
    return Stack(
        children: <Widget>[
          providerNavigation.groupIcon == null
              ? CircleAvatar(maxRadius: 30, child: Icon(Icons.group, color: Colors.white, size: 50))
              : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: FileImage(providerNavigation.groupIcon),
                      fit: BoxFit.cover
                  )
              )
          ),
          Positioned(
              bottom: 0,
              child: GestureDetector(
                  onTap: () async {
                    final file = await pickImage(false);
                    providerNavigation.groupIcon = file;
                  },
                  child: Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))
                      ),
                      child: Center(child: Icon(Icons.file_upload, color: Colors.deepOrange))
                  )
              )
          )
        ]
    );
  }
}