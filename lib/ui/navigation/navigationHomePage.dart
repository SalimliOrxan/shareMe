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
import 'package:share_me/providers/providerNavigationHome.dart';
import 'package:share_me/ui/fabElements/voice.dart';

enum Fab {voice, location, snippet, link, photo}

class NavigationHomePage extends StatefulWidget {

  @override
  _NavigationHomePageState createState() => _NavigationHomePageState();
}


class _NavigationHomePageState extends State<NavigationHomePage> {

  ProviderNavigationHome _providerNavigationHome;
  ScrollController _scrollController;
  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _scrollController  = ScrollController();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        child: _cards(),
      ),
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

  Widget _cards(){
    return ListView.builder(
        itemCount: 9,
        itemBuilder: (context, position){
          return _cardItem(position);
        }
    );
  }

  Widget _cardItem(int position){
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
                      _nameAndHour()
                    ]
                ),
                _title(),
                _containerData(Fab.photo),
                Container(
                    width: double.infinity,
                    child: Column(
                        children: <Widget>[
                          _reactions(),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 0),
                            child: Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.white
                            ),
                          ),
                          _buttons()
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

  Widget _nameAndHour(){
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
              'hour',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
              )
          )
        ]
    );
  }

  Widget _title(){
    return GestureDetector(
      onTap: (){
        _providerNavigationHome.maxLines = _providerNavigationHome.maxLines == 5 ? 20 : 5;
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
            'Title',
            maxLines: _providerNavigationHome.maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white
            )
        ),
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

  Widget _reactions(){
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
                '3',
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

  Widget _buttons(){
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
            onTap: (){
              _showCommentsBottomSheet();
            },
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

  Widget _commentWriteYour(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blueGrey
              ),
              child: TextFormField(
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
                      onTap: (){

                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Icon(Icons.send, color: Colors.white),
                      )
                  )
              )
          )
        ],
      ),
    );
  }

  Widget _commentsWritten(ScrollController controller){
    return Padding(
      padding: EdgeInsets.only(bottom: _providerNavigationHome.hasText || _providerNavigationHome.keyboardState ? 95 : 52),
      child: ListView.builder(
          shrinkWrap: true,
          controller: controller,
          itemCount: 30,
          itemBuilder: (context, position){
            return _commentItem();
          }
      ),
    );
  }

  Widget _commentItem(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _userIcon(),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blueGrey
                  ),
                  child: TextFormField(
                      initialValue: 'First comment',
                      enabled: false,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          labelText: 'John Wick',
                          labelStyle: TextStyle(color: Colors.orangeAccent, fontSize: 15),
                          contentPadding: EdgeInsets.all(10),
                          border: InputBorder.none
                      ),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white
                      )
                  )
              )
          )
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(){
    showMaterialModalBottomSheet (
        context: context,
        expand: true,
        builder: (context, scrollController){
          return Scaffold(
            backgroundColor: colorApp,
            body: Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 5),
              child: Stack(
                  children: <Widget>[
                    _commentsWritten(scrollController),
                    _commentWriteYour()
                  ]
              ),
            ),
          );
        }
    );
  }

  void _initParams(){
    _providerNavigationHome = Provider.of<ProviderNavigationHome>(context);

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

      KeyboardVisibility.onChange.listen((bool visible) {
        _providerNavigationHome.keyboardState = visible;
      });
    });
  }

  void _pressedItemsFAB(Fab status){
    switch(status){
      case Fab.voice:
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context){
              return VoiceRecorder(isInsert: true);
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