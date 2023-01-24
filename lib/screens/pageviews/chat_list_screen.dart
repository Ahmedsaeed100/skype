// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/utils/Utilities.dart';
import 'package:skype/utils/call_utilities.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/appbar.dart';
import 'package:skype/widgets/custom_tile.dart';

class ChatlistScreen extends StatefulWidget {
  const ChatlistScreen({super.key});

  @override
  State<ChatlistScreen> createState() => _ChatlistScreenState();
}

// global
final FirebaseRepository _repository = FirebaseRepository();

class _ChatlistScreenState extends State<ChatlistScreen> {
  String? currentuserId;
  String? initials;
  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      setState(() {
        currentuserId = user.uid;
        initials = Utils.getInitials(user.displayName!);
      });
    });
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      title: UserCircle(
        text: initials!,
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/search_screen");
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      floatingActionButton: const NewChatButton(),
      body: ChatListContainer(
        currentUserId: currentuserId!,
      ),
    );
  }
}

class ChatListContainer extends StatefulWidget {
  final String currentUserId;
  const ChatListContainer({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ChatListContainer> createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 2,
        itemBuilder: (context, index) {
          return CustomTile(
            mini: false,
            onTap: () {},
            onLongPress: () {},
            title: const Text(
              "Ahmed",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            subtitle: const Text(
              "Hello",
              style: TextStyle(color: Colors.white),
            ),
            leading: Container(
              constraints: const BoxConstraints(
                maxHeight: 60,
                maxWidth: 60,
              ),
              child: Stack(
                children: [
                  const CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                        "https://scontent-hbe1-1.xx.fbcdn.net/v/t1.18169-9/29025416_1823406801026901_7349438713908421_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=nNQwSHKqGPsAX9eusz4&_nc_ht=scontent-hbe1-1.xx&oh=00_AfBev6AuJ3u_WGN3T4HvqIyCypAC3VCTkJlQgK5TfNZjFg&oe=63E3FC25"),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 17,
                      width: 17,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: UniversalVariables.onlineDotColor,
                        border: Border.all(
                          color: UniversalVariables.blackColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            icon: Container(),
            trailing: Container(),
          );
        });
  }
}

class UserCircle extends StatelessWidget {
  final String text;
  const UserCircle({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: UniversalVariables.separatorColor,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: UniversalVariables.lightBlueColor,
                fontSize: 13,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UniversalVariables.blackColor,
                  width: 2,
                ),
                color: UniversalVariables.onlineDotColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NewChatButton extends StatelessWidget {
  const NewChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: UniversalVariables.fabGradient,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(15),
      child: const Icon(
        Icons.edit,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}
