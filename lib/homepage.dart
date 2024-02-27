import 'dart:developer';

import 'package:chat_app1/chatpage.dart';
import 'package:chat_app1/loginpage.dart';
import 'package:chat_app1/models/ChatRoomModel.dart';
import 'package:chat_app1/models/FirebaseHelper.dart';
import 'package:chat_app1/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/userModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.firebaseUser, required this.userModel});

  final User firebaseUser;
  final UserModel userModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{

  @override
  void initState() {

    super.initState();
    log("Init State has been called.");
    widget.userModel.status = "Online";
    FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).update({'status': widget.userModel.status}).then((value) => log("Status updated")).catchError((e)=> log(e.toString()));
    widget.userModel.lastSeen = " ";
    FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).update({'lastSeen': widget.userModel.lastSeen}).then((value) => log("Last Seen updated")).catchError((e)=> log(e.toString()));

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState? _appLifecycleState;
  @override
  void didChangeAppLifecycleState (AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appLifecycleState = state;
      print(_appLifecycleState);
      switch(state){
        case AppLifecycleState.inactive:
          widget.userModel.status = "offline";
          FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).update({'status': widget.userModel.status}).then((value) => log("Status updated")).catchError((e)=> log(e.toString()));
          updateLastSeen(widget.userModel.uid.toString(), AppLifecycleState.inactive);
          break;
        case AppLifecycleState.resumed:
          widget.userModel.status = "online";
          FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).update({'status': widget.userModel.status}).then((value) => log("Status updated")).catchError((e)=> log(e.toString()));
          updateLastSeen(widget.userModel.uid.toString(), AppLifecycleState.resumed);
          break;
        default:
          widget.userModel.status = "offline";
          FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).update({'status': widget.userModel.status}).then((value) => log("Status updated")).catchError((e)=> log(e.toString()));
          updateLastSeen(widget.userModel.uid.toString(), state);
          break;
      }
    });
  }

  void updateLastSeen (String uid, AppLifecycleState state) {

    setState(() {
      log("Function Called.");
      String lastSeen;
      lastSeen="   ";

      if(state==AppLifecycleState.paused || state==AppLifecycleState.inactive || state==AppLifecycleState.hidden){
        lastSeen = DateTime.now().toString();
        log(lastSeen);
      }
      if(state==AppLifecycleState.resumed){
        lastSeen = "   ";
      }

      FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).update({'lastSeen': lastSeen}).then((value) => log("Last Seen updated")).catchError((e)=> log(e.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async{
            await FirebaseAuth.instance.signOut();
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
              icon: const Icon(Icons.exit_to_app)
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms")
                .where("participants.${widget.userModel.uid}", isEqualTo: true).snapshots(),
            builder: (context, snapshot){
              // log(DateTime.now().toString());
              if(snapshot.connectionState == ConnectionState.active){
                if(snapshot.hasData){
                  QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                      itemCount: chatRoomSnapshot.docs.length,
                      itemBuilder: (context, index){
                        // To find the Target User, we go to the chatrooms collection and in participants we remove our own email. So only targetUser's email is left.
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String, dynamic>);
                        Map<String, dynamic> participants = chatRoomModel.participants!;
                        List<String> participantKeys = participants.keys.toList();
                        participantKeys.remove(widget.userModel.uid);

                        return FutureBuilder( // used future builder because we want it to run only once.
                            future: FirebaseHelper.getUserModel(participantKeys[0]),
                            builder: (context, userData){
                              if(userData.connectionState == ConnectionState.done){
                                if(userData.data!=null){
                                  UserModel targetUser = userData.data as UserModel;
                                  return ListTile(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => ChatPage(userModel: widget.userModel, targetUser: targetUser, firebaseUser: widget.firebaseUser, chatRoomModel: chatRoomModel))
                                      );
                                    },
                                    title: Text(targetUser.name.toString()),
                                    subtitle: Text(chatRoomModel.lastMessage.toString()),
                                  );
                                }
                                else{
                                  return Container();
                                }
                              }
                              else{
                                return Container();
                              }
                            }
                        );
                      }
                  );
                }
                else if(snapshot.hasError){
                  return const Center(child: Text("An Error Occurred."));
                }
                else{
                  return const Center(child: Text("No Chats"));
                }
              }
              else{
                return const Center(child: CircularProgressIndicator());
              }

            }
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
