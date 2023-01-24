import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:skype/models/call.dart';

class CallMethods {
  final CollectionReference callcollection =
      FirebaseFirestore.instance.collection("call");
  Stream<DocumentSnapshot> callStream({String? uid}) {
    return callcollection.doc(uid).snapshots();
  }

  // Make Call Function
  Future<bool> makeCall({Call? call}) async {
    try {
      call!.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);
      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);
      await callcollection.doc(call.callerId).set(hasDialledMap);
      await callcollection.doc(call.receiverId).set(hasNotDialledMap);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // End Call
  // these fucation made for delete doc
  Future<bool> endCall({Call? call}) async {
    try {
      await callcollection.doc(call!.callerId).delete();
      await callcollection.doc(call.receiverId).delete();

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
