import 'package:flutter/material.dart';
import 'package:skype/models/call.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skype/screens/callscreens/call-screen.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  const PickupScreen({
    super.key,
    required this.call,
  });

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 50),
            Image.network(
              widget.call.callerPic!.toString(),
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 15),
            Text(
              widget.call.callerName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () {
                    setState(() {
                      callMethods.endCall(call: widget.call);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pop(context);
                      });
                    });
                  },
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async {
                    var camera = await Permission.camera.status;
                    var microphone = await Permission.microphone.status;
                    if (camera.isGranted || microphone.isGranted) {
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallScreen(call: widget.call),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
