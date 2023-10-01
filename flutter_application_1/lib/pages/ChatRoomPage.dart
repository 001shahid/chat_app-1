import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

import 'package:flutter_application_1/modals/ChatRoomModal.dart';
import 'package:flutter_application_1/modals/Messagemodel.dart';
import 'package:flutter_application_1/modals/userModals.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModal targetUser;
  final ChatRoomModel chatroom;
  final UserModal userModal;
  final User firebaseUser;
  ChatRoomModel? selectedChatRoom;

  ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModal,
      required this.firebaseUser,
      this.selectedChatRoom})
      : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Message send
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.targetUser.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("send message!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
              onTap: () async {
                await deleteChat();
                Navigator.of(context).pop;
              },
              child: Icon(Icons.delete))
        ],
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullname.toString())
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              // This is where the chat will go
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("messages")
                        .orderBy("createdon", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>,
                              );
                              return Dismissible(
                                key: UniqueKey(),
                                background: Container(
                                  color: Colors.red,
                                  child: Align(
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                                onDismissed: (direction) async {
                                  if (direction ==
                                          DismissDirection.startToEnd &&
                                      currentMessage.sender !=
                                          widget.userModal.uid) {
                                    DocumentReference chatRoomRef =
                                        FirebaseFirestore.instance
                                            .collection("chatrooms")
                                            .doc(widget.chatroom.chatroomid);

                                    // Delete a message (you might have implemented this already)
                                    await FirebaseFirestore.instance
                                        .collection("chatrooms")
                                        .doc(widget.chatroom.chatroomid)
                                        .collection("messages")
                                        .doc(currentMessage.messageid)
                                        .delete();

                                    // Fetch the remaining messages and get the latest one
                                    QuerySnapshot messagesSnapshot =
                                        await chatRoomRef
                                            .collection("messages")
                                            .orderBy("createdon",
                                                descending: true)
                                            .get();

                                    if (messagesSnapshot.docs.isNotEmpty) {
                                      // Get the latest message after deletion
                                      String latestMessage =
                                          messagesSnapshot.docs.first["text"];

                                      // Update the lastMessage field of the chat room

                                      await FirebaseFirestore.instance
                                          .collection("chatrooms")
                                          .doc(widget.chatroom.chatroomid)
                                          .set({"lastmessage": latestMessage},
                                              SetOptions(merge: true));
                                    } else {
                                      // If there are no remaining messages, you can set lastMessage to an empty string or a default value.
                                      await chatRoomRef.update({
                                        "lastmessage": "",
                                      });
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Message deleted'),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: (currentMessage.sender ==
                                          widget.userModal.uid)
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: (currentMessage.sender ==
                                                widget.userModal.uid)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        currentMessage.text.toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                "An error occurred. Please check your internet connection."),
                          );
                        } else {
                          return Center(
                            child: Text("Say hi to your new friend!"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Enter Message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteChat() async {
    // Delete all messages in the chat room
    final messagesCollection = FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages");

    final messagesSnapshot = await messagesCollection.get();
    for (final doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Update the lastMessage field of the chatroom to indicate no messages.
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .set({"lastmessage": ""}, SetOptions(merge: true));

    // Optionally, delete the chat room itself
    // await FirebaseFirestore.instance
    //     .collection("chatrooms")
    //     .doc(widget.chatroom.chatroomid)
    //     .delete();

    // Optionally, reset the selected chat room
    setState(() {
      widget.selectedChatRoom = null;
    });
  }
}

// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/main.dart';

// import 'package:flutter_application_1/modals/ChatRoomModal.dart';
// import 'package:flutter_application_1/modals/Messagemodel.dart';
// import 'package:flutter_application_1/modals/userModals.dart';

// class ChatRoomPage extends StatefulWidget {
//   final UserModal targetUser;
//   final ChatRoomModel chatroom;
//   final UserModal userModal;
//   final User firebaseUser;
//   ChatRoomModel? selectedChatRoom;

//   ChatRoomPage(
//       {Key? key,
//       required this.targetUser,
//       required this.chatroom,
//       required this.userModal,
//       required this.firebaseUser,
//       this.selectedChatRoom})
//       : super(key: key);

//   @override
//   State<ChatRoomPage> createState() => _ChatRoomPageState();
// }

// class _ChatRoomPageState extends State<ChatRoomPage> {
//   TextEditingController messageController = TextEditingController();
//   bool isUserOnline = false; // Track user's online status

//   void sendMessage() async {
//     String msg = messageController.text.trim();
//     messageController.clear();

//     if (msg != "") {
//       // Message send
//       MessageModel newMessage = MessageModel(
//         messageid: uuid.v1(),
//         sender: widget.targetUser.uid,
//         createdon: DateTime.now(),
//         text: msg,
//         seen: false,
//       );
//       FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(widget.chatroom.chatroomid)
//           .collection("messages")
//           .doc(newMessage.messageid)
//           .set(newMessage.toMap());
//       widget.chatroom.lastMessage = msg;
//       FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(widget.chatroom.chatroomid)
//           .set(widget.chatroom.toMap());

//       log("send message!");
//     }
//   }

//   // Update user status to online
//   void updateStatus(bool isOnline) {
//     final userRef = FirebaseFirestore.instance
//         .collection("users")
//         .doc(widget.userModal.uid);

//     userRef.update({"isOnline": isOnline});
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Update user status to online when entering the chat
//     updateStatus(true);
//   }

//   @override
//   void dispose() {
//     // Update user status to offline when leaving the chat
//     updateStatus(false);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           InkWell(
//             onTap: () async {
//               await deleteChat();
//               Navigator.of(context).pop();
//             },
//             child: Icon(Icons.delete),
//           )
//         ],
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.grey,
//               backgroundImage:
//                   NetworkImage(widget.targetUser.profilepic.toString()),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.targetUser.fullname.toString()),
//                 StreamBuilder<DocumentSnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection("users")
//                       .doc(widget.targetUser.uid)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       final userData = snapshot.data as DocumentSnapshot;
//                       final isOnline = userData["isOnline"] ?? false;
//                       return Text(
//                         isOnline ? "Online" : "Offline",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: isOnline ? Colors.white : Colors.red,
//                         ),
//                       );
//                     }
//                     return Container();
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           child: Column(
//             children: [
//               // This is where the chat will go
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection("chatrooms")
//                         .doc(widget.chatroom.chatroomid)
//                         .collection("messages")
//                         .orderBy("createdon", descending: true)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.active) {
//                         if (snapshot.hasData) {
//                           QuerySnapshot dataSnapshot =
//                               snapshot.data as QuerySnapshot;
//                           return ListView.builder(
//                             reverse: true,
//                             itemCount: dataSnapshot.docs.length,
//                             itemBuilder: (context, index) {
//                               MessageModel currentMessage =
//                                   MessageModel.fromMap(
//                                 dataSnapshot.docs[index].data()
//                                     as Map<String, dynamic>,
//                               );
//                               return Dismissible(
//                                 key: UniqueKey(),
//                                 background: Container(
//                                   color: Colors.red,
//                                   child: Align(
//                                     child: Icon(
//                                       Icons.delete,
//                                       color: Colors.white,
//                                     ),
//                                     alignment: Alignment.centerLeft,
//                                   ),
//                                 ),
//                                 onDismissed: (direction) async {
//                                   if (direction ==
//                                           DismissDirection.startToEnd &&
//                                       currentMessage.sender !=
//                                           widget.userModal.uid) {
//                                     DocumentReference chatRoomRef =
//                                         FirebaseFirestore.instance
//                                             .collection("chatrooms")
//                                             .doc(widget.chatroom.chatroomid);

//                                     // Delete a message (you might have implemented this already)
//                                     await FirebaseFirestore.instance
//                                         .collection("chatrooms")
//                                         .doc(widget.chatroom.chatroomid)
//                                         .collection("messages")
//                                         .doc(currentMessage.messageid)
//                                         .delete();

//                                     // Fetch the remaining messages and get the latest one
//                                     QuerySnapshot messagesSnapshot =
//                                         await chatRoomRef
//                                             .collection("messages")
//                                             .orderBy("createdon",
//                                                 descending: true)
//                                             .get();

//                                     if (messagesSnapshot.docs.isNotEmpty) {
//                                       // Get the latest message after deletion
//                                       String latestMessage =
//                                           messagesSnapshot.docs.first["text"];

//                                       // Update the lastMessage field of the chat room

//                                       await FirebaseFirestore.instance
//                                           .collection("chatrooms")
//                                           .doc(widget.chatroom.chatroomid)
//                                           .set({"lastmessage": latestMessage},
//                                               SetOptions(merge: true));
//                                     } else {
//                                       // If there are no remaining messages, you can set lastMessage to an empty string or a default value.
//                                       await chatRoomRef.update({
//                                         "lastmessage": "",
//                                       });
//                                     }

//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('Message deleted'),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 child: Row(
//                                   mainAxisAlignment: (currentMessage.sender ==
//                                           widget.userModal.uid)
//                                       ? MainAxisAlignment.start
//                                       : MainAxisAlignment.end,
//                                   children: [
//                                     Container(
//                                       margin: EdgeInsets.symmetric(vertical: 2),
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 10, vertical: 10),
//                                       decoration: BoxDecoration(
//                                         color: (currentMessage.sender ==
//                                                 widget.userModal.uid)
//                                             ? Theme.of(context)
//                                                 .colorScheme
//                                                 .secondary
//                                             : Colors.grey,
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Text(
//                                         currentMessage.text.toString(),
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           );
//                         } else if (snapshot.hasError) {
//                           return Center(
//                             child: Text(
//                                 "An error occurred. Please check your internet connection."),
//                           );
//                         } else {
//                           return Center(
//                             child: Text("Say hi to your new friend!"),
//                           );
//                         }
//                       } else {
//                         return Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(50)),
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Row(
//                   children: [
//                     Flexible(
//                       child: TextField(
//                         controller: messageController,
//                         maxLines: null,
//                         decoration: InputDecoration(
//                           hintText: "Enter Message",
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         sendMessage();
//                       },
//                       icon: Icon(
//                         Icons.send,
//                         color: Theme.of(context).colorScheme.secondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> deleteChat() async {
//     // Delete all messages in the chat room
//     final messagesCollection = FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(widget.chatroom.chatroomid)
//         .collection("messages");

//     final messagesSnapshot = await messagesCollection.get();
//     for (final doc in messagesSnapshot.docs) {
//       await doc.reference.delete();
//     }

//     // Update the lastMessage field of the chatroom to indicate no messages.
//     await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(widget.chatroom.chatroomid)
//         .set({"lastmessage": ""}, SetOptions(merge: true));

//     // Optionally, delete the chat room itself
//     // await FirebaseFirestore.instance
//     //     .collection("chatrooms")
//     //     .doc(widget.chatroom.chatroomid)
//     //     .delete();

//     // Optionally, reset the selected chat room
//     setState(() {
//       widget.selectedChatRoom = null;
//     });
//   }
// }
