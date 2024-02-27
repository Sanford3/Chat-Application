import 'dart:developer';
import 'package:chat_app1/homepage.dart';
import 'package:chat_app1/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'models/userModel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues () {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email=="" || password==""){
      log("Please fill both the fields");
    }
    else{
      login(email, password);
    }
  }

  void login (String email, String password) async{

    UserCredential? userCredential;

    try{
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      log(ex.code.toString());
    }

    if(userCredential!=null){
      String uid = userCredential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);
      log("Log In Successful");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomePage(userModel: userModel, firebaseUser: userCredential!.user!);
      }));

      // Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage(userModel: userModel, firebaseUser: userCredential!.user!)));
    }
    else{
      log("Login Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  // height: MediaQuery.of(context).size.height*0.35,
                  width: MediaQuery.of(context).size.width,
                  height: 340,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.white24,
                            Colors.purple.shade50,
                            Colors.purple.shade100,
                            Colors.purple.shade200,
                            Colors.purple.shade300,
                            Colors.purple.shade400,
                            Colors.purple.shade500,
                            Colors.purple.shade600,
                            Colors.purple.shade700,
                            Colors.purple.shade800,
                          ]
                      )
                  ),
                  child: Image.asset("assets/logos/login.png"),
                ),
                const SizedBox(height: 25),
                const Text("Log In!", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("To have an Amazing experience along with your friends!"),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  // height: MediaQuery.of(context).size.height*0.50,
                  width: MediaQuery.of(context).size.width,
                  height: 416,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: "Email",
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: "Password",

                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: (){checkValues();}, child: const Text("Log In", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            ),
          )
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Haven't Signed Up?"),
          CupertinoButton(child: const Text("Sign Up"), onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));})
        ],
      ),

    );
  }
}

