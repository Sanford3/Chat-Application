class UserModel{

  String? uid;
  String? email;
  String? name;
  String? status;
  String? lastSeen;

  UserModel({this.uid, this.email, this.name, this.status, this.lastSeen});

  UserModel.fromMap(Map<String, dynamic> map){
    uid = map["uid"];
    email = map["email"];
    name = map["name"];
    status = map["status"];
    lastSeen = map["lastSeen"];
  }

  Map<String, dynamic> toMap() {
    return{
      "uid" : uid,
      "email" : email,
      "name" : name,
      "status" : status,
      "lastSeen" : lastSeen
    };
  }
}