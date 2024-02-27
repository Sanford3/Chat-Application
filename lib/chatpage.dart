import 'dart:developer';
import 'package:chat_app1/models/ChatRoomModel.dart';
import 'package:chat_app1/models/MessageModel.dart';
import 'package:chat_app1/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';

class ChatPage extends StatefulWidget {
  final UserModel userModel;
  final UserModel targetUser;
  final User firebaseUser;
  final ChatRoomModel chatRoomModel;
  const ChatPage({super.key, required this.userModel, required this.targetUser, required this.firebaseUser, required this.chatRoomModel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>{

  Stream<DocumentSnapshot>? userStream;

  @override
  void initState() {
    super.initState();

    // Set up a stream to listen for changes in the user document
    userStream = FirebaseFirestore.instance.collection('users').doc(widget.targetUser.uid).snapshots();
  }

  TextEditingController messageController = TextEditingController();

  void sendMessage() async {

    String message = messageController.text.trim();
    messageController.clear();

    if(message!=""){
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        createdOn: DateTime.now(),
        text: message,
        seen: false
      );

      FirebaseFirestore.instance.collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid).collection("messages")
          .doc(newMessage.messageId).set(newMessage.toMap());

      widget.chatRoomModel.lastMessage = message;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatRoomModel.chatroomid).set(widget.chatRoomModel.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.targetUser.name!),
            StreamBuilder<DocumentSnapshot>(
              stream: userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                  var userData = snapshot.data?.data() as Map<String, dynamic>;
                  String status = userData['status'];
                  String lastSeen = userData['lastSeen'];
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Text(
                          status,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          lastSeen,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Text("....."); // Placeholder while data is loading
                }
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatrooms")
                      .doc(widget.chatRoomModel.chatroomid)
                      .collection("messages").orderBy("createdOn", descending: true).snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.active){
                      if(snapshot.hasData){
                        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index){
                              MessageModel currentMessage = MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String, dynamic>);
                              return Row(
                                mainAxisAlignment: (currentMessage.sender == widget.userModel.uid)? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [Container(
                                  margin: const EdgeInsets.symmetric(vertical:2),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender == widget.userModel.uid)? Colors.grey : Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Column(
                                      children: [
                                        Text(currentMessage.text.toString(), style: const TextStyle(color: Colors.white),),
                                        Text(currentMessage.createdOn.toString())
                                      ],
                                    )
                                ),]
                              );
                            }
                        );

                      }
                      else if(snapshot.hasError){
                        return const Center(child: Text("An Error Occurred"));
                      }
                      else{
                        return const Center(
                          child: Text("Say hi to your new Friend!"),
                        );
                      }
                    }
                    else{
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
              ),
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(child:
                      TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter a Message"
                        ),
                    )
                    ),
                    IconButton(
                      onPressed: (){sendMessage();},
                      icon: Icon(
                        Icons.send, color: Theme.of(context).colorScheme.secondary,),

                    )
                  ]
                )
              )
            ]
          ),
        ),
      )
    );
  }
}
