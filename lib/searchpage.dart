import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/ChatRoomModel.dart';
import 'chatpage.dart';
import 'main.dart';
import 'models/userModel.dart';

class SearchPage extends StatefulWidget {

  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController emailController = TextEditingController();

  Future<ChatRoomModel?> getChatRoom(UserModel targetUser) async{

    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true).get();

    if(snapshot.docs.isNotEmpty){
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      log("Chatroom already created.");
      chatRoom=existingChatRoom;
    }
    else{
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true
        }
      );
      await FirebaseFirestore.instance.collection("chatrooms")
          .doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());
      log("Chatroom Created Successfully.");
      chatRoom=newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("SearchPage"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Search users by their Email Account!",
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: "Email", icon: Icon(Icons.email_sharp)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text("Search User",
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                  const SizedBox(height: 15),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("users")
                      .where("email", isEqualTo: emailController.text.trim())
                      .where("email", isNotEqualTo: widget.userModel.email)
                      .snapshots(),
                      builder: (context, snapshot){

                        if(snapshot.connectionState == ConnectionState.active){
                          if(snapshot.hasData && snapshot.data!=null){

                            QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                            if(dataSnapshot.docs.isNotEmpty){

                              Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;
                              UserModel searchedUser = UserModel.fromMap(userMap);

                              return GestureDetector(
                                onTap: () async {
                                  ChatRoomModel? chatRoomModel = await getChatRoom(searchedUser);
                                  if(chatRoomModel!=null){
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage(userModel: widget.userModel, targetUser: searchedUser, firebaseUser: widget.firebaseUser, chatRoomModel: chatRoomModel)));
                                  }
                                  },
                                child: ListTile(
                                  title: Text(searchedUser.email!.toString()),
                                  subtitle: Text(searchedUser.email!.toString()),
                                ),
                              );
                            }
                            else{
                              return const Text("No Results Found.");
                            }
                          }
                          else if(snapshot.hasError){
                            return const Text("An Error Occurred.");
                          }
                          else{
                            return const Text("No Results Found.");
                          }
                        }
                        else {
                          return const CircularProgressIndicator();
                        }
                      }
                  )
                ],
              ),
            ),
          )),
    );
  }
}
