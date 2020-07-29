import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerNavigationHome.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/fabElements/imageOrVideo.dart';
import 'package:share_me/ui/fabElements/voice.dart';
import 'package:share_me/ui/navigation/home/commentSheet.dart';

enum Fab {voice, location, snippet, link, photo}

class NavigationHomePage extends StatefulWidget {

  @override
  _NavigationHomePageState createState() => _NavigationHomePageState();
}


class _NavigationHomePageState extends State<NavigationHomePage> {

  ProviderNavigationHome _providerNavigationHome;
  List<Post> _posts;
  User _me;
  ScrollController _scrollController;
  RefreshController _refreshController;
  TextEditingController _controllerMyComment;

  @override
  void initState() {
    super.initState();
    _scrollController    = ScrollController();
    _refreshController   = RefreshController(initialRefresh: false);
    _controllerMyComment = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllerMyComment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initParams();

    return Scaffold(
        backgroundColor: colorApp,
        body: _body(),
        floatingActionButton: _fab()
    );
  }


  Widget _body(){
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: ClassicHeader(),
        child:_posts == null ? Container() : _postView()
      )
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
            onTap: () => _pressedItemsFAB(Fab.voice)
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
          return _postItem(position);
        }
    );
  }

  Widget _postItem(int position){
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
                    children: <Widget>[
                      _userIcon(),
                      _nameAndHour(position)
                    ]
                ),
                _title(position),
                _containerData(Fab.photo),
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
                            ),
                          ),
                          _buttons(position)
                        ]
                    )
                )
              ]
          ),
        ),
      ),
    );
  }

  Widget _userIcon(){
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: CircleAvatar(
        maxRadius: 15,
        child: Icon(Icons.person),
      ),
    );
  }

  Widget _nameAndHour(int position){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              'name',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
              )
          ),
          Text(
              _posts[position].date.toDate().toString().substring(11, 16),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
              )
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

  Widget _containerData(Fab status){
    Widget view = Container();

    switch(status){
      case Fab.voice:

        break;
      case Fab.location:
        break;
      case Fab.snippet:
        break;
      case Fab.link:
        break;
      case Fab.photo:
        view = CachedNetworkImage(
            imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHnHamnGAQO6byapKIZIp-6TZNYZksh2x3MQ&usqp=CAU',
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error, size: 30, color: Colors.white),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none
        );
        break;
    }

    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        width: double.infinity,
        child: GestureDetector(
          onTap: (){
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context){
                  return VoiceRecorder(isInsert: false);
                }
            );
          },
          child: Container(
              height: 170,
              child: view
          ),
        )
    );
  }

  Widget _reactions(int positionPost){
    return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: 17,
            ),
          ),
          Text(
              '100',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12
              )
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Text(
                _posts[positionPost].countComment.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12
                )
            ),
          ),
          Text(
              'Comments',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12
              )
          )
        ]
    );
  }

  Widget _buttons(int position){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: (){

            },
            child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(Icons.ac_unit, color: Colors.white, size: 17),
                      ),
                      Text(
                          'Like',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          )
                      )
                    ]
                )
            )
          ),
          GestureDetector(
            onTap: () => _showCommentsBottomSheet(position),
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
            onTap: (){

            },
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
              ),
            ),
          )
        ]
    );
  }



  void _initParams(){
    _providerNavigationHome = Provider.of<ProviderNavigationHome>(context);
    _posts                  = Provider.of<List<Post>>(context);
    _me                     = Provider.of<User>(context);

    WidgetsBinding.instance.addPostFrameCallback((_){
      _refreshController.position.addListener((){
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

  void _showCommentsBottomSheet(int positionPost){
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
                                StreamProvider.value(value: Database.instance.getComments(_posts[positionPost].postId))
                              ],
                              child: CommentSheet(scrollController: scrollController, positionPost: positionPost)
                          )
                      )
                  )
              )
          );
        }
    );
  }

  void _pressedItemsFAB(Fab status){
    switch(status){
      case Fab.voice:
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context){
              return ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  child: VoiceRecorder(isInsert: true)
              );
            }
        );
        break;
      case Fab.location:
        break;
      case Fab.snippet:
        break;
      case Fab.link:
//        showDialogFab(
//            context,
//            LinkPreviewer(
//              link: "https://www.linkedin.com/feed/",
//              direction: ContentDirection.horizontal
//            )
//        );
        break;
      case Fab.photo:
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context){
              return ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: FractionallySizedBox(
                  heightFactor: 0.73,
                  child: MultiProvider(
                    providers: [
                      StreamProvider.value(value: Database.instance.usersByUid(_me.friends)),
                      StreamProvider.value(value: Database.instance.currentUserData)
                    ],
                    child: ImageOrVideo()
                  )
                )
              );
            }
        );
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