import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:skype/models/message.dart';
import 'package:skype/models/users.dart';
import 'package:skype/resources/firebase_methods.dart';

class FirebaseRepository {
  final FirebaseMethods _firebaseMethods = FirebaseMethods();
  Future<User> getCurrentUser() => _firebaseMethods.getCurrentUser();
  Future googleSignUp() => _firebaseMethods.googleSignUp();

  Future<bool> authenticateUser(User user) =>
      _firebaseMethods.authentcateUser(user);
  Future<void> addDataToDb(User user) => _firebaseMethods.addDataToDb(user);

  // responsible for sign out
  Future<void> signOut() => _firebaseMethods.signOut();

  ///
  Future<Myusers> getUserDetails() => _firebaseMethods.getuserDetails();

  ///
  // get all Users Except current user
  Future<List<Myusers>> getAllUsersByID(User user) =>
      _firebaseMethods.getAllUsersByID(user);

  // Add Message To Db Firebase
  Future<void> addMessageToDb(
      Message message, Myusers sender, Myusers receiver) async {
    try {
      await _firebaseMethods.addMessageToDb(message, sender, receiver);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
