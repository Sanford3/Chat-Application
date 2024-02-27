import 'package:chat_app1/loginpage.dart';
import 'package:chat_app1/models/FirebaseHelper.dart';
import 'package:chat_app1/models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'homepage.dart';

var uuid = Uuid();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  if(currentUser!=null){

    UserModel? thisuserModel = await FirebaseHelper.getUserModel(currentUser.uid);

    if(thisuserModel!=null){
      runApp(MyAppLoggedIn(firebaseUser: currentUser, userModel: thisuserModel));
    }
    else{
      runApp(const MyApp());
    }
  }
  else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  const MyAppLoggedIn({super.key, required this.firebaseUser, required this.userModel});

  final User firebaseUser;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(firebaseUser: firebaseUser, userModel: userModel,),
    );
  }
}

