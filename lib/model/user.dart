class User {

  String uid;
  bool isEmailVerified;
  String name;
  String surname;
  String email;
  String password;
  String passwordAgain;
  String imgCover;
  String imgProfile;

  User({
    this.uid,
    this.isEmailVerified,
    this.name,
    this.surname,
    this.email,
    this.imgCover,
    this.imgProfile
  });

  Map<String, dynamic> toMap(){
    return {
      'name':       name,
      'surname':    surname,
      'email':      email,
      'imgCover':   imgCover,
      'imgProfile': imgProfile
    };
  }

  User.fromMap(map){
    this.uid        = map['uid'] ?? '';
    this.name       = map['name'] ?? '';
    this.surname    = map['surname'] ?? '';
    this.email      = map['email'] ?? '';
    this.imgCover   = map['imgCover'] ?? '';
    this.imgProfile = map['imgProfile'] ?? '';
  }
}