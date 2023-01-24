import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/call.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/screens/callscreens/pickup/pickup-screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    super.key,
    required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    // ignore: unnecessary_null_comparison
    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: userProvider.getUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                Call call =
                    Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

                if (!call.hasDialled!) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupScreen(call: call),
                    ),
                  );
                }
              }
              return scaffold;
            },
          )
        : const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
  }
}
