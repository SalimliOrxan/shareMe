import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/commentDetail.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/home/commentSheet.dart';
import 'package:share_me/ui/navigation/search/targetProfile.dart';

class ProviderNavigationHome with ChangeNotifier {

  List<bool> _visibilityReplies = [];
  List<CommentDetail>_comments  = [];
  bool _hasText                 = false;
  bool _keyboardState           = false;
  bool _dialVisible             = true;
  int _maxLines                 = 5;
  String _replyTag              = '';



  List<bool> get visibilityReplies => _visibilityReplies;

  set visibilityReplies(List<bool> value) {
    _visibilityReplies = value;
    notifyListeners();
  }


  List<CommentDetail> get comments => _comments;

  set comments(List<CommentDetail> value) {
    _comments = value;
    notifyListeners();
  }


  bool get hasText => _hasText;

  set hasText(bool value) {
    _hasText = value;
    notifyListeners();
  }


  bool get keyboardState => _keyboardState;

  set keyboardState(bool value) {
    _keyboardState = value;
    notifyListeners();
  }


  bool get dialVisible => _dialVisible;

  set dialVisible(bool value) {
    _dialVisible = value;
    notifyListeners();
  }


  int get maxLines => _maxLines;

  set maxLines(int value) {
    _maxLines = value;
    notifyListeners();
  }


  String get replyTag => _replyTag;

  set replyTag(String value) {
    _replyTag = value;
    notifyListeners();
  }






  void showCommentsBottomSheet(BuildContext context, Post post){
    showMaterialModalBottomSheet (
        context: context,
        expand: true,
        builder: (context, scrollController){
          return Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                  heightFactor: 0.96,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      child: Scaffold(
                          body: MultiProvider(
                              providers: [
                                StreamProvider.value(value: Database.instance.currentUserData),
                                StreamProvider.value(value: Database.instance.getPostById(post.postId)),
                                StreamProvider.value(value: Database.instance.getComments(post.postId))
                              ],
                              child: CommentSheet(scrollController: scrollController)
                          )
                      )
                  )
              )
          );
        }
    );
  }

  void openProfile(BuildContext context, String uid){
    showMaterialModalBottomSheet(
        context: context,
        expand: true,
        builder: (context, scrollController){
          return MultiProvider(
              providers: [
                StreamProvider.value(value: Database.instance.userById(uid)),
                StreamProvider.value(value: Database.instance.currentUserData)
              ],
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                      heightFactor: 0.97,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          child: Scaffold(
                              backgroundColor: colorApp,
                              body: Padding(
                                  padding: EdgeInsets.fromLTRB(18, 18, 18, 5),
                                  child: TargetProfilePage(position: -1, fromSearch: false)
                              )
                          )
                      )
                  )
              )
          );
        }
    );
  }

  Future<void>like(Post post) async {
    post.likedUsers.contains(Auth.instance.uid) ? post.likedUsers.remove(Auth.instance.uid) : post.likedUsers.add(Auth.instance.uid);
    await Database.instance.updatePost(post);
  }

  void share(){

  }

  Future<void>deletePost(Post post) async {
    await Database.instance.deletePostById(post);
  }
}