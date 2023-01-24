import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype/models/message.dart';
import 'package:skype/models/users.dart';
import 'package:skype/utils/Utilities.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      firestore.collection("users");

  // Myusers Class model
  Myusers myusers = Myusers();

  User? currentUser;
  Future<User> getCurrentUser() async {
    if (_auth.currentUser != null) {
      currentUser = _auth.currentUser!;
      bool userExist = await authentcateUser(currentUser!);
      userExist ? addDataToDb(currentUser!) : null;
    } else {
      currentUser = null;
    }
    return currentUser!;
  }

// Get users Details
  Future<Myusers> getuserDetails() async {
    User currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();
    return Myusers.fromMap(documentSnapshot.data());
  }

//
  /// Google SignUp
  Future googleSignUp() async {
    final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

    if (googleAccount != null) {
      GoogleSignInAuthentication signInAuthentication =
          await googleAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: signInAuthentication.idToken,
        accessToken: signInAuthentication.accessToken,
      );
      _auth.signInWithCredential(credential);
    }
  }

  Future<bool> authentcateUser(User user) async {
    QuerySnapshot result = await firestore
        .collection("users")
        .where("Email", isEqualTo: user.email)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    // if users is Registered then lenght of list > 0 or else less than 0
    return docs.isEmpty ? true : false;
  }

  Future<void> addDataToDb(User user) async {
    String userName = Utils.getUserName(user.email!);
    myusers = Myusers(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      profilePhoto: user.photoURL,
      username: userName,
    );

    firestore.collection("users").doc(user.uid).set(myusers.toMap(myusers));
  }

// Sign Out
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

// get All users Exept Current User
  Future<List<Myusers>> getAllUsersByID(User currentUser) async {
    List<Myusers> userList = <Myusers>[];

    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where("uid", isNotEqualTo: currentUser.uid)
        .get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].data() != currentUser.uid) {
        userList.add(Myusers.fromMap(querySnapshot.docs[i].data()));
      }
    }
    return userList;
  }

  Future<void> addMessageToDb(
      Message message, Myusers sender, Myusers receiver) async {
    var map = message.toMap();
    await firestore
        .collection("messages")
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    await firestore
        .collection("messages")
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }
}
