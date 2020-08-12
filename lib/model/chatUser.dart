class MyChatUser {

  String uid;
  String name;
  String img;
  int color;

  MyChatUser({this.uid, this.name, this.img, this.color});

  Map<String, dynamic> toMap(){
    return {
      'uid':   uid,
      'name':  name,
      'img':   img,
      'color': color
    };
  }

  MyChatUser.fromMap(map){
    this.uid   = map['uid'] ?? '';
    this.name  = map['name'] ?? '';
    this.img   = map['img'] ?? '';
    this.color = map['color'] ?? 0;
  }
}