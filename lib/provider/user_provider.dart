import 'package:flutter/cupertino.dart';
import 'package:skype/models/users.dart';
import 'package:skype/resources/firebase_repository.dart';

class UserProvider with ChangeNotifier {
  Myusers? _myusers;
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  Myusers? get getUser => _myusers;
  void refreshUser() async {
    Myusers myusers = await _firebaseRepository.getUserDetails();
    _myusers = myusers;
    notifyListeners();
  }
}
