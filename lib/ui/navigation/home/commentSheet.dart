import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/comment.dart';
import 'package:share_me/model/commentDetail.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigationHome.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/search/targetProfile.dart';

class CommentSheet extends StatefulWidget {

  final ScrollController scrollController;
  CommentSheet({@required this.scrollController});

  @override
  CommentSheetState createState() => CommentSheetState();
}


class CommentSheetState extends State<CommentSheet> {

  ProviderNavigationHome _providerNavigationHome;
  Post _post;
  Comment _comments;
  User _me;

  TextEditingController _controllerMyComment, _controllerEditingComment;
  FocusNode _focusNode;
  int _positionReply;
  int _selectedCommentPosition;
  String _selectedCommentKey;
  bool _isEditEnable;
  int _countComment;


  @override
  void initState() {
    super.initState();
    _positionReply = 0;
    _countComment = 0;
    _selectedCommentPosition = 0;
    _isEditEnable = false;
    _focusNode = FocusNode();
    _controllerMyComment = TextEditingController();
    _controllerEditingComment = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _providerNavigationHome.visibilityReplies = [];
      _providerNavigationHome.comments = [];
      _providerNavigationHome.replyTag = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    _providerNavigationHome = Provider.of<ProviderNavigationHome>(context);
    _me                     = Provider.of<User>(context);
    _post                   = Provider.of<Post>(context);
    _comments               = Provider.of<Comment>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _comments == null ? Container() : _body()
    );
  }


  Widget _body(){
    return Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Stack(
            children: <Widget>[
              _commentView(widget.scrollController),
              _myComment()
            ]
        )
    );
  }

  Widget _myComment(){
    return Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _replyTagInCommentField(),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black26
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                          controller: _controllerMyComment,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              hintText: 'Write comment',
                              hintStyle: TextStyle(color: Colors.white, fontSize: 12),
                              contentPadding: EdgeInsets.only(left: 10, right: 10),
                              border: InputBorder.none
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (data){
                            if(data.length == 0){
                              _providerNavigationHome.hasText = false;
                            } else {
                              if(!_providerNavigationHome.hasText){
                                _providerNavigationHome.hasText = true;
                              }
                            }
                          }
                      ),
                    ),
                    Visibility(
                        visible: _providerNavigationHome.hasText,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                                onTap: _sendComment,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  child: Icon(Icons.send, color: Colors.white),
                                )
                            )
                        )
                    )
                  ]
                )
            )
          ]
        )
    );
  }

  Widget _replyTagInCommentField(){
    return Visibility(
      visible: _providerNavigationHome.replyTag.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => _providerNavigationHome.replyTag = '',
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.close, color: Colors.white, size: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueGrey
                  )
                )
              )
            ),
            Container(
              height: 30,
              padding: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(30)
              ),
              child: Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'reply to: ',
                          style: TextStyle(color: Colors.lightGreen, fontSize: 11)
                      ),
                      TextSpan(
                          text: _providerNavigationHome.replyTag,
                          style: TextStyle(color: Colors.white, fontSize: 11)
                      )
                    ]
                  )
                )
              )
            )
          ]
        )
      )
    );
  }

  Widget _commentView(ScrollController controller){
    _countComment = 0;

    return _comments.commentsForRead.length == 0
        ? Center(child: Icon(Icons.add_comment, color: Colors.deepOrange, size: 100))
        : Padding(
        padding: EdgeInsets.only(
            bottom: _providerNavigationHome.hasText || _providerNavigationHome.keyboardState
                ? _providerNavigationHome.replyTag.isNotEmpty ? 92 : 50
                : 50
        ),
        child: ListView.builder(
            padding: EdgeInsets.only(bottom: 20),
            shrinkWrap: true,
            controller: controller,
            itemCount: _comments.commentsForRead.length,
            itemBuilder: (context, positionComment){
              bool hasReplies = _comments.commentsForRead[positionComment].length > 1;
              _providerNavigationHome.visibilityReplies.add(hasReplies);

              if(_isEditEnable){
                // comment selected for edit
                _comments.commentsForRead[_selectedCommentPosition][_selectedCommentKey].editable = true;
              }

              return !hasReplies
                  ? _itemComment(positionComment, '0')
                  : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _comments.commentsForRead[positionComment].length,
                  itemBuilder: (context, positionReply){
                    String keyCommentDetail = _comments.commentsForRead[positionComment].keys.elementAt(positionReply);

                    return  positionReply == 0
                        ? _itemComment(positionComment, keyCommentDetail)
                        : _itemReply(positionComment, keyCommentDetail);
                  }
              );
            }
        )
    );
  }

  Widget _itemComment(int positionComment, String keyCommentDetail){
    _countComment++;
    CommentDetail comment = _comments.commentsForRead[positionComment][keyCommentDetail];
    bool isEditedComment = _isEditEnable && _selectedCommentPosition == positionComment && _selectedCommentKey == keyCommentDetail;

    return Padding(
        key: UniqueKey(),
        padding: const EdgeInsets.only(top: 20),
        child: GestureDetector(
          onLongPress: (){
            _isEditEnable = false;
            _selectedCommentPosition = positionComment;
            _selectedCommentKey = keyCommentDetail;
            _showCommentOptions(comment, false);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _userIcon(comment),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: isEditedComment ? Colors.blueGrey : Colors.black26
                          ),
                          child: TextFormField(
                              controller: isEditedComment ? _controllerEditingComment : null,
                              initialValue: isEditedComment ? null : comment.comment,
                              enabled: comment.editable,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: comment.name,
                                  labelStyle: TextStyle(color: Colors.orangeAccent, fontSize: 15),
                                  contentPadding: EdgeInsets.all(10),
                                  border: InputBorder.none
                              ),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white
                              )
                          )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 5),
                            child: InkWell(
                                onTap: () => _showReplyTag(comment, positionComment),
                                child: Text(
                                    'Reply',
                                    style: TextStyle(color: Colors.white, fontSize: 11)
                                )
                            )
                          ),
                          Visibility(
                            visible: isEditedComment,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 5, right: 5),
                                child: InkWell(
                                    onTap: () => _finisEditingComment(comment),
                                    child: Text(
                                        'Finish edit',
                                        style: TextStyle(color: Colors.white, fontSize: 11)
                                    )
                                )
                            ),
                          )
                        ]
                      ),
                      Visibility(
                        visible: _providerNavigationHome.visibilityReplies[positionComment] && _comments.commentsForRead[positionComment].length - 1 > 0,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 5, top: 10),
                            child: InkWell(
                                onTap: () => _showReplies(positionComment),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Icon(Icons.subdirectory_arrow_right, color: Colors.white, size: 15)
                                    ),
                                    Text(
                                        '${_comments.commentsForRead[positionComment].length - 1} Replies',
                                        style: TextStyle(color: Colors.white, fontSize: 11)
                                    )
                                  ]
                                )
                            )
                        )
                      )
                    ]
                  )
              )
            ]
          )
        )
    );
  }

  Widget _itemReply(int positionComment, String keyCommentDetail){
    _countComment++;
    CommentDetail comment = _comments.commentsForRead[positionComment][keyCommentDetail];
    bool isEditedComment = _isEditEnable && _selectedCommentPosition == positionComment && _selectedCommentKey == keyCommentDetail;

    return Visibility(
        key: UniqueKey(),
        visible: !_providerNavigationHome.visibilityReplies[positionComment],
        child: Padding(
            padding: const EdgeInsets.only(left: 40, top: 15),
            child: GestureDetector(
                onLongPress: (){
                  _isEditEnable = false;
                  _selectedCommentPosition = positionComment;
                  _selectedCommentKey = keyCommentDetail;
                  _showCommentOptions(comment, true);
                },
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _userIcon(comment),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: isEditedComment ? Colors.blueGrey : Colors.black54
                                  ),
                                  child: TextFormField(
                                      controller: isEditedComment ? _controllerEditingComment : null,
                                      initialValue: isEditedComment ? null : comment.comment,
                                      enabled: comment.editable,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                          labelText: comment.name,
                                          labelStyle: TextStyle(color: Colors.orangeAccent, fontSize: 15),
                                          contentPadding: EdgeInsets.all(10),
                                          border: InputBorder.none
                                      ),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white
                                      )
                                  )
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.only(left: 5, top: 5),
                                        child: InkWell(
                                            onTap: () => _showReplyTag(comment, positionComment),
                                            child: Text(
                                                'Reply',
                                                style: TextStyle(color: Colors.white, fontSize: 11)
                                            )
                                        )
                                    ),
                                    Visibility(
                                        visible: isEditedComment,
                                        child: Padding(
                                            padding: const EdgeInsets.only(top: 5, right: 5),
                                            child: InkWell(
                                                onTap: () => _finisEditingComment(comment),
                                                child: Text(
                                                    'Finish edit',
                                                    style: TextStyle(color: Colors.white, fontSize: 11)
                                                )
                                            )
                                        )
                                    )
                                  ]
                              )
                            ],
                          )
                      )
                    ]
                )
            )
        )
    );
  }

  Widget _userIcon(CommentDetail commentDetail){
    return GestureDetector(
      onTap: () => _openProfile(commentDetail),
      child: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: commentDetail.img.isEmpty
            ? Container(width: 40, height: 40, child: icUser)
            : CachedNetworkImage(
            imageUrl: commentDetail.img,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Container(width: 40, height: 40, child: icUser),
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider){
              return Container(
                  width: 40,
                  height: 38,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover
                      )
                  )
              );
            }
        )
      )
    );
  }

  Widget _optionsSheet(CommentDetail comment, bool isMyComment, bool isReply){
    return !_isPostAvailable()
        ? Container()
        : Scaffold(
        backgroundColor: colorApp,
        body: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                mainAxisAlignment: isMyComment ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: isMyComment,
                    child: GestureDetector(
                      onTap: () => _editComment(comment),
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Row(
                            children: <Widget>[
                              Icon(Icons.edit, color: Colors.deepOrange, size: 20),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ]
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isMyComment,
                    child: GestureDetector(
                      onTap: () => _deleteComment(isReply),
                      child: Container(
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Row(
                              children: <Widget>[
                                Icon(Icons.delete, color: Colors.deepOrange, size: 20),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ]
                          )
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () => _copyComment(comment),
                      child: Container(
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Row(
                              children: <Widget>[
                                Icon(Icons.content_copy, color: Colors.deepOrange, size: 20),
                                Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                        'Copy',
                                        style: TextStyle(color: Colors.white)
                                    )
                                )
                              ]
                          )
                      )
                  )
                ]
            )
        )
    );
  }



  void _showCommentOptions(CommentDetail comment, bool isReply){
    bool isMyComment = comment.uid == Auth.instance.uid;

    showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: false,
        context: context,
        builder: (BuildContext context){
          return ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                  height: isMyComment ? 150 : 70,
                  child: _optionsSheet(comment, isMyComment, isReply)
              )
          );
        }
    );

  }

  void _showReplies(int positionComment){
    _providerNavigationHome.visibilityReplies[positionComment] = false;
    // for setState at bottomSheet
    _providerNavigationHome.hasText = true;
    _providerNavigationHome.hasText = false;
  }

  Future<void>_showReplyTag(CommentDetail commentDetail, int positionComment) async {
    if(_isPostAvailable()){
      _positionReply = positionComment;
      _providerNavigationHome.replyTag = commentDetail.name;
    }
  }


  Future<void> _sendComment() async {
    _providerNavigationHome.replyTag.isEmpty ? await _writeNewComment() : await _writeReplyComment();
  }

  Future<void>_writeNewComment() async {
    if(_isPostAvailable()){
      _comments.commentsForWrite = [];
      Map<String, dynamic> emptyMap = Map();

      _comments.commentsForRead.forEach((map1){
        int index = _comments.commentsForRead.indexOf(map1);
        _comments.commentsForWrite.add(Map<String, dynamic>());

        map1.forEach((key, map2){
          _comments.commentsForWrite[index][key] = map2.toMap();
        });
      });

      // add new comment
      CommentDetail comment = CommentDetail();
      comment.uid     = _me.uid;
      comment.name    = _me.fullName;
      comment.img     = _me.imgProfile;
      comment.comment = _controllerMyComment.text;
      emptyMap['0'] = comment.toMap();
      _comments.commentsForWrite.add(emptyMap);

      _controllerMyComment.text = '';
      _providerNavigationHome.hasText = false;
      await Database.instance.updateComments(_comments);

      _post.countComment = _countComment;
      await Database.instance.updatePost(_post);
    }
  }

  Future<void>_writeReplyComment() async {
    if(_isPostAvailable()){
      _comments.commentsForWrite = [];
      String newKey;

      _comments.commentsForRead.forEach((map1){
        int index = _comments.commentsForRead.indexOf(map1);
        _comments.commentsForWrite.add(Map<String, dynamic>());

        map1.forEach((key, map2){
          _comments.commentsForWrite[index][key] = map2.toMap();
        });

        if(index == _positionReply){
          newKey = (int.parse(map1.keys.last) + 1).toString();
        }
      });

      // add new comment
      Map<String, dynamic> oldComments = _comments.commentsForWrite[_positionReply];
      CommentDetail comment = CommentDetail();
      comment.uid     = _me.uid;
      comment.name    = _me.fullName;
      comment.img     = _me.imgProfile;
      comment.comment = _controllerMyComment.text;
      oldComments[newKey] = comment.toMap();
      _comments.commentsForWrite[_positionReply] = oldComments;

      _controllerMyComment.text = '';
      _providerNavigationHome.hasText = false;
      await Database.instance.updateComments(_comments);

      _post.countComment = _countComment;
      await Database.instance.updatePost(_post);
    }
  }


  Future<void>_editComment(CommentDetail comment) async {
    if(_isPostAvailable()){
      _isEditEnable = true;
      comment.editable = true;
      _controllerEditingComment.text = comment.comment;
      Navigator.pop(context);
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  Future<void>_finisEditingComment(CommentDetail comment) async {
    if(_isPostAvailable()){
      if(comment.comment != _controllerEditingComment.text.trim() && _controllerEditingComment.text.isNotEmpty){
        comment.comment = _controllerEditingComment.text.trim();
        _comments.commentsForRead[_selectedCommentPosition][_selectedCommentKey]  = comment;
        _comments.commentsForWrite[_selectedCommentPosition][_selectedCommentKey] = comment.toMap();

        await Database.instance.updateComments(_comments);
        _isEditEnable = false;
        comment.editable = false;
        FocusScope.of(context).unfocus();
      } else {
        _isEditEnable = false;
        comment.editable = false;
        FocusScope.of(context).unfocus();
      }
    }
  }

  Future<void>_deleteComment(bool isReply) async {
    if(_isPostAvailable()){
      isReply
          ? _post.countComment = _countComment - 1
          : _post.countComment = _countComment - _comments.commentsForRead.elementAt(_selectedCommentPosition).length;

      isReply
          ? _comments.commentsForWrite.elementAt(_selectedCommentPosition).remove(_selectedCommentKey)
          : _comments.commentsForWrite.removeAt(_selectedCommentPosition);

      isReply
          ? _comments.commentsForRead.elementAt(_selectedCommentPosition).remove(_selectedCommentKey)
          : _comments.commentsForRead.removeAt(_selectedCommentPosition);

      Navigator.pop(context);
      await Database.instance.updateComments(_comments);
      await Database.instance.updatePost(_post);
    }
  }

  Future<void>_copyComment(CommentDetail comment) async {
    await Clipboard.setData(ClipboardData(text: comment.comment));
    Navigator.pop(context);
    Scaffold
        .of(context)
        .showSnackBar(
        SnackBar(
            content: Text('Text copied', style: TextStyle(color: Colors.lightGreenAccent)),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.black
        )
    );
  }


  void _openProfile(CommentDetail comment){
    showMaterialModalBottomSheet(
        context: context,
        expand: true,
        builder: (context, scrollController){
          return MultiProvider(
              providers: [
                StreamProvider.value(value: Database.instance.userById(comment.uid)),
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
                          ),
                        ),
                      )
                  )
              )
          );
        }
    );
  }

  bool _isPostAvailable(){
    if(_post == null){
      showToast('Post had been removed', true);
      return false;
    }
    return true;
  }
}