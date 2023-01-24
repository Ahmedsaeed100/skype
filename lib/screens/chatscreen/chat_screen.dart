// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skype/models/message.dart';

import 'package:skype/models/users.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/utils/call_utilities.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/appbar.dart';
import 'package:skype/widgets/custom_tile.dart';

class ChatScreen extends StatefulWidget {
  final Myusers receiver;
  const ChatScreen({
    Key? key,
    required this.receiver,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  FirebaseRepository repository = FirebaseRepository();
  final ScrollController _listScrollController = ScrollController();
  // to see is user write something
  Myusers? sender;
  String? currentUserId;
  FocusNode textFieldFocus = FocusNode();
  bool isWriting = false;
  bool showEmojiPicker = false;
  @override
  void initState() {
    super.initState();
    repository.getCurrentUser().then(
      (user) {
        currentUserId = user.uid;
        setState(() {
          sender = Myusers(
            uid: user.uid,
            name: user.displayName,
            profilePhoto: user.photoURL,
          );
        });
      },
    );
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: [
          Flexible(
            child: messageList(),
          ),
          chatControls(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
        ],
      ),
    );
  }

// EmojiPicker
  emojiContainer1() {
    return EmojiPicker(
      textEditingController: textEditingController,
      config: const Config(
        bgColor: UniversalVariables.separatorColor,
        indicatorColor: UniversalVariables.blueColor,
        columns: 7,
      ),
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });
      },
    );
  }

// EmojiPicker
  emojiContainer() {
    return SizedBox(
        height: 250,
        child: EmojiPicker(
          textEditingController: textEditingController,
          onEmojiSelected: (emoji, category) {
            setState(() {
              isWriting = true;
            });
          },
          config: const Config(
            columns: 7,
            // Issue: https://github.com/flutter/flutter/issues/28894

            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            bgColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            backspaceColor: Colors.blue,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            showRecentsTab: true,
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: false,
            noRecents: Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
            loadingIndicator: SizedBox.shrink(),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
            checkPlatformCompatibility: true,
          ),
        ));
  }

// Messages Controllers
  messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("messages")
          .doc(currentUserId)
          .collection(widget.receiver.uid!)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return const CircularProgressIndicator();
        } else {
          // move To when new Message Arrives
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _listScrollController.animateTo(
              _listScrollController.position.minScrollExtent,
              duration: const Duration(microseconds: 250),
              curve: Curves.easeOut,
            );
          });
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            reverse: true,
            // when New Message Arreve
            controller: _listScrollController,
            itemBuilder: (context, index) {
              return chatMessageItem(snapshot.data!.docs[index]);
            },
          );
        }
      },
    );
  }

// chatMessageItem
  chatMessageItem(DocumentSnapshot snapshot) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: snapshot['senderId'] == currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: snapshot['senderId'] == currentUserId
            ? senderLayout(snapshot)
            : receiverLayout(snapshot),
      ),
    );
  }

// when user Send Data
  senderLayout(DocumentSnapshot snapshot) {
    Radius messageRadius = const Radius.circular(10);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(snapshot),
      ),
    );
  }

  ///

// when user receive Data
  receiverLayout(DocumentSnapshot snapshot) {
    Radius messageRadius = const Radius.circular(10);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(snapshot),
      ),
    );
  }

  // get message
  getMessage(DocumentSnapshot snapshot) {
    return Text(
      snapshot['message'],
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

// typeing Text Controllers
  chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(BuildContext context) {
      showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: UniversalVariables.blackColor,
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    ElevatedButton(
                      child: const Icon(
                        Icons.close,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Content and tools",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  children: const [
                    ModalTile(
                      title: "Media",
                      subtitle: "Share Photos and Video",
                      icon: Icons.image,
                    ),
                    ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        icon: Icons.tab),
                    ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts),
                    ModalTile(
                        title: "Location",
                        subtitle: "Share a location",
                        icon: Icons.add_location),
                    ModalTile(
                        title: "Schedule Call",
                        subtitle: "Arrange a skype call and get reminders",
                        icon: Icons.schedule),
                    ModalTile(
                        title: "Create Poll",
                        subtitle: "Share polls",
                        icon: Icons.poll)
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              addMediaModal(context);
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textEditingController,
                  focusNode: textFieldFocus,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  onTap: () => hideEmojiContainer(),
                  onChanged: ((val) {
                    // ignore: prefer_is_empty
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  }),
                  decoration: const InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50.0),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: const Icon(Icons.face),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Icon(Icons.record_voice_over),
                ),
          isWriting ? Container() : const Icon(Icons.camera_alt),
          isWriting
              ? Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                )
              : Container()
        ],
      ),
    );
  }

// When user send Text Message
  sendMessage() {
    String text = textEditingController.text;
    Message _message = Message(
      receiverId: widget.receiver.uid,
      senderId: sender!.uid,
      message: text,
      timestamp: FieldValue.serverTimestamp(),
      type: 'text',
    );
    setState(() {
      isWriting = false;
      textEditingController.clear();
    });
    // Add Message To Firebase DB
    repository.addMessageToDb(_message, sender!, widget.receiver);
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      title: Text(widget.receiver.name.toString()),
      actions: [
        IconButton(
          icon: const Icon(Icons.video_call),
          onPressed: () async {
            var camera = await Permission.camera.status;
            var microphone = await Permission.microphone.status;
            if (camera.isDenied || microphone.isDenied) {
              CallUtils.dial(
                from: sender,
                to: widget.receiver,
                context: context,
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {},
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ModalTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        onTap: () {},
        icon: Container(),
        onLongPress: () {},
        trailing: Container(),
        mini: false,
        leading: Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: UniversalVariables.greyColor,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
