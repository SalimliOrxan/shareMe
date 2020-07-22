class FullNameData {

  Map fullNames;

  FullNameData({this.fullNames});

  Map<String, dynamic> toMap(){
    return {
      'fullNames': fullNames
    };
  }

  FullNameData.fromMap(map){
    this.fullNames = map['fullNames'] ?? Map();
  }
}