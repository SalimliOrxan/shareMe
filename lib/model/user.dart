class User {

  String uid;
  bool isEmailVerified;
  String fullName;
  String name;
  String surname;
  String email;
  String password;
  String passwordAgain;
  String imgCover;
  String imgProfile;
  List<dynamic> friends;
  List<dynamic> followRequests;

  User({
    this.uid,
    this.isEmailVerified,
    this.fullName,
    this.name,
    this.surname,
    this.email,
    this.imgCover,
    this.imgProfile,
    this.friends,
    this.followRequests
  });

  Map<String, dynamic> toMap(){
    return {
      'fullName':       fullName,
      'name':           name,
      'surname':        surname,
      'email':          email,
      'imgCover':       imgCover,
      'imgProfile':     imgProfile,
      'friends':        friends,
      'followRequests': followRequests
    };
  }

  User.fromMap(map){
    this.fullName       = map['fullName'] ?? '';
    this.name           = map['name'] ?? '';
    this.surname        = map['surname'] ?? '';
    this.email          = map['email'] ?? '';
    this.imgCover       = map['imgCover'] ?? '';
    this.imgProfile     = map['imgProfile'] ?? '';
    this.friends        = map['friends'] ?? List<dynamic>();
    this.followRequests = map['followRequests'] ?? List<dynamic>();
  }
}