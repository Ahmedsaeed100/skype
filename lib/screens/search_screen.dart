import 'package:flutter/material.dart';
import 'package:skype/models/users.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skype/screens/chatscreen/chat_screen.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/custom_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseRepository _repository = FirebaseRepository();
  List<Myusers> userList = [];
  String query = "";
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Retrive Details Of Current user
    _repository.getCurrentUser().then((User user) {
      _repository.getAllUsersByID(user).then((List<Myusers> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }

  buildSuggestions(String query) {
    return ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          Myusers searchedUser = Myusers(
            uid: userList[index].uid,
            profilePhoto: userList[index].profilePhoto,
            name: userList[index].name,
            username: userList[index].username,
          );
          return CustomTile(
            mini: false,
            onLongPress: () {},
            margin: const EdgeInsets.all(0),
            trailing: const Text(""),
            icon: const Icon(Icons.safety_check),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ChatScreen(
                      receiver: searchedUser,
                    );
                  },
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage(searchedUser.profilePhoto.toString()),
              backgroundColor: Colors.grey,
            ),
            title: Text(
              searchedUser.username.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              searchedUser.name.toString(),
              style: const TextStyle(
                color: UniversalVariables.greyColor,
              ),
            ),
          );
        });
  }

  //   (Myusers myuser) =>
  //       (myuser.username!.toLowerCase().contains(query) ||
  //           (myuser.name!.toLowerCase().contains(query))),
  //);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: AppBar(
        elevation: 0,
        // ignore: prefer_const_constructors
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              cursorColor: UniversalVariables.blackColor,
              autofocus: true,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 35,
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // WidgetsBinding.instance.addPersistentFrameCallback(
                    //     (_) => searchController.clear());
                    searchController.clear();
                  },
                ),
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Color(0x88ffffff),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggestions(query),
      ),
    );
  }
}
