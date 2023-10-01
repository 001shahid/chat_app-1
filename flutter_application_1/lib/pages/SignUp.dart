// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/modals/UIHelper.dart';
// import 'package:flutter_application_1/modals/userModals.dart';
// import 'package:flutter_application_1/pages/completeprofile.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController cPasswordController = TextEditingController();
//   void checkValues() {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();
//     String cPassword = cPasswordController.text.trim();

//     if (email == "" || password == "" || cPassword == "") {
//       // print("Please fill all the fields!");
//       UIHelper.showAlertDialog(
//           context, "Incomplete fields ", "please Fill the fields");
//     } else if (password != cPassword) {
//       //  print("Password do not match!");
//       UIHelper.showAlertDialog(context, "Password Mismatch",
//           "The Passwords you entered do not match!");
//     } else {
//       signUp(email, password);
//       // print("Sign Up Successful!");
//     }
//   }

//   void signUp(String email, String password) async {
//     UserCredential? credential;
//     UIHelper.showLoadingDialog(context, "Creating  new account");
//     try {
//       credential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);
//     } on FirebaseAuthException catch (ex) {
//       Navigator.pop(context);
//       UIHelper.showAlertDialog(
//           context, "An error occured", ex.message.toString());
//       //print(ex.code.toString());
//     }
//     if (credential != null) {
//       String uid = credential.user!.uid;
//       UserModal newUser = UserModal(
//         uid: uid,
//         email: email,
//         fullname: "",
//         profilepic: "",
//       );
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(uid)
//           .set(newUser.toMap())
//           .then((value) {
//         print("New User Created!");
//         Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return CompleteProfile(
//               userModal: newUser, firebaseUser: credential!.user!);
//         }));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//           child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 40),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Text(
//                   "Chat App",
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.secondary,
//                       fontSize: 50,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 TextField(
//                   controller: emailController,
//                   decoration: InputDecoration(labelText: "Email Address"),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 TextField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(labelText: "Password"),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 TextField(
//                   controller: cPasswordController,
//                   obscureText: true,
//                   decoration: InputDecoration(labelText: " Confirm Password"),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 CupertinoButton(
//                   child: Text("Sign Up"),
//                   onPressed: () {
//                     checkValues();
//                     // Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(
//                     //         builder: (context) => CompleteProfile()));
//                   },
//                   color: Theme.of(context).colorScheme.secondary,
//                 )
//               ],
//             ),
//           ),
//         ),
//       )),
//       bottomNavigationBar: Container(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Already have an account?",
//               style: TextStyle(fontSize: 16),
//             ),
//             CupertinoButton(
//                 child: Text(
//                   "Login In",
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_1/modals/UIHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/modals/userModals.dart';
import 'package:flutter_application_1/pages/completeprofile.dart';
import 'package:flutter_application_1/pages/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void checkValues() {
    if (_formKey.currentState!.validate()) {
      signUp(emailController.text.trim(), passwordController.text.trim());
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Creating new account");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, "An error occurred", ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModal newUser = UserModal(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("New User Created!");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              userModal: newUser, firebaseUser: credential!.user!);
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assests/Rectangle 2206.png",
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Center(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Chat App",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Sign Up to continue !",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 380,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter Email",
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter Password",
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: cPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Confirm Password",
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 370,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(255, 10, 207, 131),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                checkValues();
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: "Already have an account ?",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "Login In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 10, 207, 131),
                                  ),
                                ),
                              ]),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
