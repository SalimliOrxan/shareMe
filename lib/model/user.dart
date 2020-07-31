class User {

  String uid;
  String fcmToken;
  bool isEmailVerified;
  String fullName;
  String name;
  String surname;
  String email;
  String password;
  String passwordAgain;
  String imgCover;
  String imgProfile;
  int countNotification = 0;
  List<dynamic> friends = [];
  List<dynamic> followRequests = [];
  List<dynamic> searchKeys = [];
  List<dynamic> posts = [];
  List<dynamic> postsHidden = [];
  List<dynamic> postsBanned = [];

  User({
    this.uid,
    this.fcmToken,
    this.isEmailVerified,
    this.fullName,
    this.name,
    this.surname,
    this.email,
    this.imgCover,
    this.imgProfile,
    this.countNotification,
    this.friends,
    this.followRequests,
    this.searchKeys,
    this.posts,
    this.postsHidden
  });

  Map<String, dynamic> toMap(){
    return {
      'uid':               uid,
      'fcmToken':          fcmToken,
      'fullName':          fullName,
      'name':              name,
      'surname':           surname,
      'email':             email,
      'imgCover':          imgCover,
      'imgProfile':        imgProfile,
      'countNotification': countNotification,
      'friends':           friends,
      'followRequests':    followRequests,
      'searchKeys':        searchKeys,
      'posts':             posts,
      'postsHidden':       postsHidden
    };
  }

  User.fromMap(map){
    this.uid               = map['uid'] ?? '';
    this.fullName          = map['fullName'] ?? '';
    this.fcmToken          = map['fcmToken'] ?? '';
    this.name              = map['name'] ?? '';
    this.surname           = map['surname'] ?? '';
    this.email             = map['email'] ?? '';
    this.imgCover          = map['imgCover'] ?? '';
    this.imgProfile        = map['imgProfile'] ?? '';
    this.countNotification = map['countNotification'] ?? 0;
    this.friends           = map['friends'] ?? List<dynamic>();
    this.followRequests    = map['followRequests'] ?? List<dynamic>();
    this.searchKeys        = map['searchKeys'] ?? List<dynamic>();
    this.posts             = map['posts'] ?? List<dynamic>();
    this.postsHidden       = map['postsHidden'] ?? List<dynamic>();
  }
}