class MyChatUser {

  String uid;
  String name;
  String img;

  MyChatUser({this.uid, this.name, this.img});

  Map<String, dynamic> toMap(){
    return {
      'uid':  uid,
      'name': name,
      'img':  img
    };
  }

  MyChatUser.fromMap(map){
    this.uid  = map['uid'] ?? '';
    this.name = map['name'] ?? '';
    this.img  = map['img'] ?? '';
  }
}