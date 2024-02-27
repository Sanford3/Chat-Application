import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'loginpage.dart';
import 'models/userModel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  void signup() async{

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();
    String name = nameController.text;

    if(email=="" || password=="" || cpassword==""){
      log("Please fill all the fields.");
    }
    else if(password!=cpassword){
      log("Passwords don't match");
    }
    else{
      UserCredential? userCredential;
      try{
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        log("User Created!");
      } on FirebaseAuthException catch(ex) {
        log(ex.code.toString());
        log("Unable to create user.");
      }
      if(userCredential!=null){
        String uid = userCredential.user!.uid;
        UserModel newUser =  UserModel(
            uid: uid,
            email: email,
            name: name,
            status: "offline"
        );
        await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value){
          log("New User Created");
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        }
        ); // set wants a map to be passed
      }
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
                  child: SvgPicture.asset("assets/logos/signup.svg"),
                ),
                const SizedBox(height: 25),
                const Text("Sign Up!", style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("To have an Amazing experience along with your friends!"),
                const SizedBox(height: 20),
                Container(
                  // height: MediaQuery.of(context).size.height*0.50,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      TextField(
                        controller: cpasswordController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: "Confirm Password",
                        ),
                        obscureText: true,
                      ),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: "Name",
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(onPressed: () {signup();},
                          child: const Text("Sign Up", style: TextStyle(
                              fontWeight: FontWeight.bold)
                          )
                      ),
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
          const Text("Already Signed Up?"),
          CupertinoButton(child: const Text("Login"), onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));})
        ],
      ),
    );
  }
}
