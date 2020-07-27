import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/commentDetail.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/provider/providerNavigationHome.dart';
import 'package:share_me/service/database.dart';

class CommentSheet extends StatefulWidget {

  final ScrollController scrollController;
  final int positionPost;
  CommentSheet({@required this.scrollController, @required this.positionPost});

  @override
  CommentSheetState createState() => CommentSheetState();
}


class CommentSheetState extends State<CommentSheet> {

  ProviderNavigationHome _providerNavigationHome;
  TextEditingController _controllerMyComment;
  List<Post> _posts;

  @override
  void initState() {
    super.initState();
    _controllerMyComment = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _providerNavigationHome.visibilityReplies = []);
  }

  @override
  Widget build(BuildContext context) {
    _providerNavigationHome = Provider.of<ProviderNavigationHome>(context);
    _posts                  = Provider.of<List<Post>>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _posts == null ? Container() : _body()
    );
  }


  Widget _body(){
    return Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, 5),
        child: Stack(
            children: <Widget>[
              _commentsWritten(widget.scrollController, widget.positionPost),
              _commentWriteYour()
            ]
        )
    );
  }

  Widget _commentWriteYour(){
    return Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black26
                ),
                child: TextFormField(
                    controller: _controllerMyComment,
                    maxLines: 2,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: 'write comment',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 12),
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        border: InputBorder.none
                    ),
                    style: TextStyle(
                        color: Colors.white
                    ),
                    onChanged: (data){
                      _providerNavigationHome.hasText = data.length > 0;
                    }
                )
            ),
            Visibility(
                visible: _providerNavigationHome.hasText || _providerNavigationHome.keyboardState,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                        onTap: _sendComment,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Icon(Icons.send, color: Colors.white),
                        )
                    )
                )
            )
          ],
        )
    );
  }

  Widget _commentsWritten(ScrollController controller, int positionPost){
    return Padding(
        padding: EdgeInsets.only(bottom: _providerNavigationHome.hasText || _providerNavigationHome.keyboardState ? 95 : 52),
        child: ListView.builder(
            shrinkWrap: true,
            controller: controller,
            itemCount: _posts[widget.positionPost].commentsForRead.length,
            itemBuilder: (context, positionComment){
              bool hasReplies = _posts[widget.positionPost].commentsForRead[positionComment].length > 1;
              CommentDetail commentDetail = _posts[widget.positionPost].commentsForRead[positionComment].values.elementAt(0);
              _providerNavigationHome.visibilityReplies.add(hasReplies);

              return !hasReplies
                  ? _commentItem(positionPost, positionComment, commentDetail)
                  : ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  itemCount: _posts[widget.positionPost].commentsForRead[positionComment].length,
                  itemBuilder: (context, positionReply){
                    CommentDetail commentDetail = _posts[widget.positionPost].commentsForRead[positionComment].values.elementAt(positionReply);

                    return  positionReply == 0
                        ? _commentItem(positionPost, positionComment, commentDetail)
                        : _replyItem(positionPost, positionComment, commentDetail);
                  }
              );
            }
        )
    );
  }

  Widget _commentItem(int positionPost, int positionComment, CommentDetail commentDetail){
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _userIcon(commentDetail),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black26
                        ),
                        child: TextFormField(
                            initialValue: commentDetail.comment,
                            enabled: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                labelText: commentDetail.name,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 5),
                      child: InkWell(
                          onTap: _reply,
                          child: Text(
                              'Reply',
                              style: TextStyle(color: Colors.white, fontSize: 11)
                          )
                      )
                    ),
                    Visibility(
                      visible: _providerNavigationHome.visibilityReplies[positionComment],
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
                                      '${_posts[positionPost].commentsForRead[positionComment].length - 1} Replies',
                                      style: TextStyle(color: Colors.white, fontSize: 11)
                                  )
                                ]
                              )
                          )
                      )
                    )
                  ],
                )
            )
          ],
        )
    );
  }

  Widget _replyItem(int positionPost, int positionComment, CommentDetail commentDetail){
    return Visibility(
      visible: !_providerNavigationHome.visibilityReplies[positionComment],
      child: Padding(
          padding: const EdgeInsets.only(left: 40, top: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _userIcon(commentDetail),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black54
                          ),
                          child: TextFormField(
                              initialValue: commentDetail.comment,
                              enabled: false,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: commentDetail.name,
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
                      Padding(
                          padding: const EdgeInsets.only(left: 5, top: 5),
                          child: InkWell(
                              onTap: _reply,
                              child: Text(
                                  'Reply',
                                  style: TextStyle(color: Colors.white, fontSize: 11)
                              )
                          )
                      )
                    ],
                  )
              )
            ],
          )
      ),
    );
  }

  Widget _userIcon(CommentDetail commentDetail){
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: CachedNetworkImage(
          imageUrl: commentDetail.img ?? '',
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
    );
  }


  Future<void>_sendComment() async {
    Post oldPost = _posts[1];
    oldPost.commentsForWrite = [];
    Map<String, dynamic> map = Map();

    oldPost.commentsForRead.forEach((map1){
      int index = oldPost.commentsForRead.indexOf(map1);
      oldPost.commentsForWrite.add(map);

      map1.forEach((key, map2){
        oldPost.commentsForWrite[index][key] = map2.toMap();
        if(index == 0 && key == '0'){
          oldPost.commentsForWrite[0][key]['comment'] = _controllerMyComment.text;
        }
      });
    });

    await Database.instance.updatePost(oldPost);
    _controllerMyComment.text = '';
    _providerNavigationHome.hasText = false;
  }

  Future<void>_reply() async {

  }

  void _showReplies(int positionComment){
    _providerNavigationHome.visibilityReplies[positionComment] = false;
  }
}