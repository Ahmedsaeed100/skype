// ignore_for_file: public_member_api_docs, sort_constructors_first

class Myusers {
  String? uid;
  String? name;
  String? email;
  String? username;
  String? status;
  int? state;
  String? profilePhoto;

  Myusers({
    this.uid,
    this.name,
    this.email,
    this.username,
    this.status,
    this.state,
    this.profilePhoto,
  });

  Map<String, dynamic> toMap(Myusers myusers) {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'status': status,
      'state': state,
      'profilePhoto': profilePhoto,
    };
  }

  // Named constructor
  Myusers.fromMap(mapData) {
    uid = mapData['uid'];
    name = mapData['name'];
    email = mapData['email'];
    username = mapData['username'];
    status = mapData['status'];
    state = mapData['state'];
    profilePhoto = mapData['profilePhoto'];
  }

  Myusers.fromjson(Map<String, dynamic> mapData) {
    uid = mapData['uid'];
    name = mapData['name'];
    email = mapData['email'];
    username = mapData['username'];
    status = mapData['status'];
    state = mapData['state'];
    profilePhoto = mapData['profilePhoto'];
  }
}
