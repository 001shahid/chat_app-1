import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/modals/ChatRoomModal.dart';
import 'package:flutter_application_1/modals/UIHelper.dart';
import 'package:flutter_application_1/modals/userModals.dart';
import 'package:flutter_application_1/pages/SignUp.dart';
import 'package:flutter_application_1/pages/completeprofile.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/tabbar.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
      print("Please fill all the!");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Logging In");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "an error", ex.message.toString());
      print(ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModal userModal =
          UserModal.fromMap(userData.data() as Map<String, dynamic>);
      Navigator.popUntil(context, (route) => route.isFirst);
      //print("Log in Successful");
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return HomePage(
            userModal: userModal,
            firebaseUser: credential!.user!,
          );
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assests/download.jpeg"),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Chat App",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email Address"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      prefixIcon: Icon(Icons.lock),
                      labelText: "Password"),
                ),
                SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  child: Text("Login In"),
                  onPressed: () {
                    checkValues();
                  },
                  color: Theme.of(context).colorScheme.secondary,
                ),
                TextButton(onPressed: () {}, child: Text(" OR Login with OTP")),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await registerUserWithGoogle();
                      },
                      child: Image.asset(
                        "assests/download.png",
                        width: 50,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        signInWithFacebook();
                      },
                      child: Icon(
                        Icons.facebook,
                        size: 60,
                        color: Colors.blue,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have a account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
                child: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpPage()));
                })
          ],
        ),
      ),
    );
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      if (context.mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      userModal: UserModal(),
                      firebaseUser: userCredential.user!,
                    )));
      }
    } catch (e) {
      // Handle and display the error to the user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in with Facebook failed: ${e.toString()}"),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  // Future<void> signInwithGoogle() async {
  //   FirebaseAuth _auth = FirebaseAuth.instance;
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser!.authentication;
  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  //   // ignore: unused_local_variable
  //   final UserCredential userCredential =
  //       await _auth.signInWithCredential(credential);
  //   if (context.mounted) {
  //     Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => HomePage(
  //                 userModal: UserModal(), firebaseUser: userCredential.user!)));
  //   }
  // }

  // Future<void> signInWithGoogle() async {
  //   FirebaseAuth _auth = FirebaseAuth.instance;
  //   final GoogleSignIn googleSignIn = GoogleSignIn();

  //   UIHelper.showLoadingDialog(context, "Signing In with Google");

  //   try {
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser!.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  //     final UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);

  //     if (context.mounted) {
  //       // Successfully signed in with Google
  //       Navigator.popUntil(context, (route) => route.isFirst);
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) {
  //             return Tabbar(
  //               userModal: UserModal(),firebaseUser: userCredential.user!,

  //             );
  //             //  HomePage(
  //             //   userModal: UserModal(), // You can customize this user model
  //             //   firebaseUser: userCredential.user!,
  //             // );
  //           },
  //         ),
  //       );
  //     }
  //   } catch (error) {
  //     // Handle Google Sign-In error
  //     Navigator.pop(context); // Close the loading dialog
  //     UIHelper.showAlertDialog(
  //         context, "Google Sign-In Error", error.toString());
  //     print(error.toString());
  //   }
  // }
// Future<void> signInWithGoogle(BuildContext context) async {
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn googleSignIn = GoogleSignIn();

//   UIHelper.showLoadingDialog(context, "Signing In with Google");

//   try {
//     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser!.authentication;
//     final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
//     final UserCredential userCredential =
//         await _auth.signInWithCredential(credential);

//     if (context.mounted) {
//       // Successfully signed in with Google
//       final User? user = userCredential.user;

//       // Create a UserModel instance with the user's data
//       UserModal userModel = UserModel(
//         uid: user!.uid,
//         email: user.email ?? '',
//       );

//       // Store the UserModel data in Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userModel.uid)
//           .set(userModel.toMap());

//       Navigator.popUntil(context, (route) => route.isFirst);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) {
//             // Replace with your desired screen and pass the userModel
//             return CompleteProfile(userModal: UserModal(), firebaseUser:user);
//           },
//         ),
//       );
//     }
//   } catch (error) {
//     // Handle Google Sign-In error
//     Navigator.pop(context); // Close the loading dialog
//     UIHelper.showAlertDialog(context, "Google Sign-In Error", error.toString());
//     print(error.toString());
//   }
// }

  Future<void> registerUserWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      // Sign in with Google using Firebase Authentication
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Create an instance of UserModal with user information
      UserModal userModel = UserModal(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        fullname: userCredential.user!.displayName ?? '',
        profilepic: userCredential.user!.photoURL ?? '',
      );

      // Store the user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            // Replace with your desired screen and pass the userModel
            return HomePage(
              userModal: UserModal(),
              firebaseUser: userCredential.user!,
            );
          },
        ),
      );

      // Registration successful
      print('User registered with Google Sign-In successfully');
    } catch (error) {
      // Handle registration errors
      print('Google Sign-In error: $error');
      // You can display an error message to the user here
    }
  }
}
