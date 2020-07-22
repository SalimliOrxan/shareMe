class GroupData {

  Map groups;

  GroupData({this.groups});

  Map<String, dynamic> toMap(){
    return {
      'groups':    groups
    };
  }

  GroupData.fromMap(map){
    this.groups    = map['groups'] ?? Map();
  }
}