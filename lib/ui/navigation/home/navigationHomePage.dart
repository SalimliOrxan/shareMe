import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigationHome.dart';
import 'package:share_me/ui/navigation/home/videoView.dart';
import 'package:share_me/ui/navigation/home/youtubeVideoView.dart';

enum Fab {audio, location, snippet, link, video, photo}

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  ProviderNavigationHome _providerNavigationHome;
  List<Post> _posts;
  User _me;
  RefreshController _refreshController;
  TextEditingController _controllerMyComment;

  StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _refreshController   = RefreshController(initialRefresh: false);
    _controllerMyComment = TextEditingController();

    _initShareReceiver();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _controllerMyComment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initParams();

    return Scaffold(
        backgroundColor: colorApp,
        body: _posts == null || _posts.length == 0
            ? _emptyBody()
            : _body(),
        floatingActionButton: _fab()
    );
  }


  Widget _body(){
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            header: ClassicHeader(),
            child: _postView()
        )
    );
  }

  Widget _emptyBody(){
    return Center(
        child: Icon(Icons.share, color: Colors.deepOrange, size: 100)
    );
  }

  Widget _fab(){
    return SpeedDial(
      marginRight: 18,
      marginBottom: 18,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: _providerNavigationHome.dialVisible,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.transparent,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(Icons.keyboard_voice),
            backgroundColor: Colors.purple,
            label: 'Voice',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _pressedItemsFAB(Fab.audio)
        ),
        SpeedDialChild(
            child: Icon(Icons.add_location),
            backgroundColor: Colors.orange,
            label: 'Location',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _pressedItemsFAB(Fab.location)
        ),
        SpeedDialChild(
            child: Icon(Icons.code),
            backgroundColor: Colors.green,
            label: 'Snippet',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _pressedItemsFAB(Fab.snippet)
        ),
        SpeedDialChild(
            child: Icon(Icons.link),
            backgroundColor: Colors.red,
            label: 'Link',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _pressedItemsFAB(Fab.link)
        ),
        SpeedDialChild(
            child: Icon(Icons.image),
            backgroundColor: Colors.blue,
            label: 'Photo/Video',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _pressedItemsFAB(Fab.photo)
        )
      ],
    );
  }

  Widget _postView(){
    return ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, position){
          String postId = _posts[position].postId;
          return _me.postsHidden.contains(postId)
              ? _postHiddenItem(position)
              :_postItem(position);
        }
    );
  }

  Widget _postItem(int position){
    return Padding(
        key: UniqueKey(),
        padding: const EdgeInsets.only(bottom: 15),
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            color: Colors.black87,
            elevation: 5,
            child: Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                              children: <Widget>[
                                _userIcon(position),
                                _nameAndHour(position)
                              ]
                          ),
                          _more(position)
                        ],
                      ),
                      _title(position),
                      _posts[position].fileUrl.isEmpty ? SizedBox(height: 20) : _containerData(position),
                      Container(
                          width: double.infinity,
                          child: Column(
                              children: <Widget>[
                                _reactions(position),
                                Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 0),
                                    child: Container(
                                        height: 0.5,
                                        width: double.infinity,
                                        color: Colors.white
                                    )
                                ),
                                _buttons(position)
                              ]
                          )
                      )
                    ]
                )
            )
        )
    );
  }

  Widget _postHiddenItem(int position){
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        color: Colors.black87,
        elevation: 5,
        child: Container(
            padding: EdgeInsets.all(10),
            height: 50,
            width: double.infinity,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                      'This post is hidden',
                      style: TextStyle(color: Colors.white)
                  ),
                  InkWell(
                    onTap: () => _providerNavigationHome.showPost(_me, _posts[position].postId),
                    child: Container(
                      height: 30,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                            'show',
                            style: TextStyle(color: Colors.blueAccent)
                        ),
                      ),
                    ),
                  )
                ]
            )
        )
    );
  }

  Widget _userIcon(int position){
    return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: GestureDetector(
            onTap: () => _providerNavigationHome.openProfile(context, _posts[position].uid),
            child: _posts.elementAt(position).userImg.isEmpty
                ? Container(width: 40, height: 40, child: icUser)
                : CachedNetworkImage(
                imageUrl: _posts.elementAt(position).userImg,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(width: 40, height: 40, child: icUser),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
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

  Widget _nameAndHour(int position){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              _posts?.elementAt(position)?.fullName ?? '',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
              )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
                _posts[position].date.toDate().toString().substring(0, 16),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                )
            ),
          )
        ]
    );
  }

  Widget _title(int positionPost){
    return GestureDetector(
      onTap: (){
        _providerNavigationHome.maxLines = _providerNavigationHome.maxLines == 5 ? 20 : 5;
      },
      child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
              _posts[positionPost].title,
              maxLines: _providerNavigationHome.maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white
              )
          )
      ),
    );
  }

  Widget _more(int positionPost){
    return Container(
      height: 50,
      width: 30,
      color: Colors.transparent,
      child: PopupMenuButton(
          onSelected: (value) => _pressedItemsPopup(value, _posts[positionPost]),
          color: colorApp,
          icon: Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (BuildContext context){
            return <PopupMenuEntry<String>>[
              _posts[positionPost].uid == _me.uid ? PopupMenuItem(
                  height: 25,
                  value: 'Delete',
                  child: Text(
                      'Delete',
                      style: TextStyle(fontSize: 12, color: Colors.white)
                  )
              ) : null,
              PopupMenuItem(
                  height: 25,
                  value: 'Hide',
                  child: Text(
                      'Hide',
                      style: TextStyle(fontSize: 12, color: Colors.white)
                  )
              ),
              PopupMenuItem(
                  height: 25,
                  value: 'Ban',
                  child: Text(
                      'Never see this post',
                      style: TextStyle(fontSize: 12, color: Colors.white)
                  )
              )
            ];
          }
      ),
    );
  }

  Widget _containerData(int position){
    String fileType = _posts[position].fileType;
    Fab type = Fab.values.firstWhere((e) => e.toString() == fileType);
    Widget view;

    switch(type){
      case Fab.audio:
        view = Center(
            child: Container(
              height: 50,
              width: double.infinity,
              color: Colors.transparent,
              child: Icon(
                  Icons.music_note,
                  color: Colors.pinkAccent,
                  size: 60
              )
            )
        );
        break;
      case Fab.location:
        break;
      case Fab.snippet:
        break;
      case Fab.link:
        if(_posts.elementAt(position).fileUrl.contains('youtu')){
          view = AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubeView(url: _posts.elementAt(position).fileUrl)
          );
        }
        break;
      case Fab.video:
        String url = _posts.elementAt(position).fileUrl;
        view = url.isEmpty ? null : _videoView(url);
        break;
      case Fab.photo:
        String url = _posts.elementAt(position).fileUrl;
        view = url.isEmpty ? null : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: _photoView(url)
        );
        break;
    }

    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        width: double.infinity,
        child: GestureDetector(
            onTap: () => _pressedPostData(type, position),
            child: view
        )
    );
  }

  Widget _reactions(int positionPost){
    int lengthLikedUsers = _posts[positionPost].likedUsers.length;

    return Row(
        children: <Widget>[
          Visibility(
            visible: lengthLikedUsers > 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                Icons.stars,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
          Visibility(
            visible: lengthLikedUsers > 0,
            child: Text(
                lengthLikedUsers.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12
                )
            ),
          ),
          Spacer(),
          Visibility(
            visible: _posts[positionPost].countComment > 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Text(
                  _posts[positionPost].countComment.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                  )
              ),
            ),
          ),
          Visibility(
            visible: _posts[positionPost].countComment > 0,
            child: GestureDetector(
              onTap: () => _providerNavigationHome.showCommentsBottomSheet(context, _posts[positionPost]),
              child: Text(
                  _posts[positionPost].countComment == 1 ? 'Comment' : 'Comments',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                  )
              ),
            ),
          ),
          Visibility(
            visible: _posts[positionPost].countComment > 0 && _posts[positionPost].countShare > 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Icon(Icons.brightness_1, color: Colors.white, size: 3),
            ),
          ),
          Visibility(
            visible: _posts[positionPost].countShare > 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Text(
                  _posts[positionPost].countShare.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                  )
              ),
            ),
          ),
          Visibility(
            visible: _posts[positionPost].countShare > 0,
            child: Text(
                _posts[positionPost].countShare == 1 ? 'Share' : 'Shares',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12
                )
            ),
          )
        ]
    );
  }

  Widget _buttons(int position){
    bool hasStar = _posts[position].likedUsers.contains(_me.uid);

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
              onTap: () => _providerNavigationHome.like(_posts[position]),
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                  child: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Icon(hasStar ? Icons.star : Icons.star_border, color: hasStar ? Colors.blueAccent : Colors.white, size: 17)
                        ),
                        Text(
                            'Star',
                            style: TextStyle(
                                color: _posts[position].likedUsers.contains(_me.uid) ? Colors.blueAccent : Colors.white,
                                fontSize: 12
                            )
                        )
                      ]
                  )
              )
          ),
          GestureDetector(
            onTap: () => _providerNavigationHome.showCommentsBottomSheet(context, _posts[position]),
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
              child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(Icons.comment, color: Colors.white, size: 17),
                    ),
                    Text(
                        'Comment',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                        )
                    )
                  ]
              ),
            ),
          ),
          GestureDetector(
              onTap: () => _providerNavigationHome.share(_posts[position].fileUrl),
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                  child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(Icons.share, color: Colors.white, size: 17),
                        ),
                        Text(
                            'Share',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12
                            )
                        )
                      ]
                  )
              )
          )
        ]
    );
  }

  Widget _photoView(String fileUrl){
    return CachedNetworkImage(
        imageUrl: fileUrl,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error, size: 30, color: Colors.white),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none
    );
  }

  Widget _videoView(String fileUrl){
    return AspectRatio(
        aspectRatio: 4 / 3,
        child: VideoView(url: fileUrl, file: null)
    );
  }



  void _initParams(){
    _providerNavigationHome = Provider.of<ProviderNavigationHome>(context);
    _posts                  = Provider.of<List<Post>>(context);
    _me                     = Provider.of<User>(context);

    WidgetsBinding.instance.addPostFrameCallback((_){
      _refreshController?.position?.addListener((){
        if(_refreshController.position.userScrollDirection == ScrollDirection.reverse){
          if(_providerNavigationHome.dialVisible){
            _providerNavigationHome.dialVisible = false;
          }
        } else {
          if(_refreshController.position.userScrollDirection == ScrollDirection.forward){
            if(!_providerNavigationHome.dialVisible) {
              _providerNavigationHome.dialVisible = true;
            }
          }
        }});

      KeyboardVisibility.onChange.listen((bool visible){
        _providerNavigationHome.keyboardState = visible;
      });
    });
  }

  void _initShareReceiver(){
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
      if(files != null){
        _providerNavigationHome.showPhotoOrVideoSheet(context, _me?.friends, files, null);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> files) {
      if(files != null){
        _providerNavigationHome.showPhotoOrVideoSheet(context, _me?.friends, files, null);
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String text) {
      if(text != null){
        text.contains('http')
            ? _providerNavigationHome.showLinkSheet(context, _me?.friends, text)
            : _providerNavigationHome.showPhotoOrVideoSheet(context, _me?.friends, null, text);
      }
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String text) {
      if(text != null){
        _providerNavigationHome.showPhotoOrVideoSheet(context, _me?.friends, null, text);
      }
    });
  }

  void _pressedItemsFAB(Fab status){
    switch(status){
      case Fab.audio:
        _providerNavigationHome.showAudioSheet(context, _me.friends, true, null);
        break;
      case Fab.location:
        break;
      case Fab.snippet:
        break;
      case Fab.link:
        _providerNavigationHome.showLinkSheet(context, _me.friends, null);
        break;
      case Fab.video:
        _providerNavigationHome.showPhotoOrVideoSheet(context, _me.friends, null, null);
        break;
      case Fab.photo:
        _providerNavigationHome.showPhotoOrVideoSheet(context, _me.friends, null, null);
        break;
    }
  }

  void _pressedPostData(Fab status, int position){
    switch(status){
      case Fab.audio:
        _providerNavigationHome.showAudioSheet(context, _me.friends, false, _posts.elementAt(position).fileUrl);
        break;
      case Fab.location:
        break;
      case Fab.snippet:
        break;
      case Fab.link:
        break;
      case Fab.video:
        break;
      case Fab.photo:
        showImageDialog(context, _posts.elementAt(position).fileUrl);
        break;
    }
  }

  void _pressedItemsPopup(String value, Post post){
    switch(value){
      case 'Delete':
        _providerNavigationHome.deletePost(post);
        break;
      case 'Hide':
        _providerNavigationHome.hidePost(_me, post.postId);
        break;
      case 'Ban':
        _providerNavigationHome.banPost(_me, post.postId);
        break;
    }
  }

  void _onRefresh() async {
    _refreshController.refreshCompleted();
//    var response = await Future.wait([
//      _model.getGuestHouses(),
//      _model.getHotTours(),
//      _model.getReview()
//    ]);
//
//    for(var result in response){
//      if(result != Status.Success){
//        _refreshController.refreshFailed();
//        return;
//      }
//    }
//    _refreshController.refreshCompleted();
  }
}