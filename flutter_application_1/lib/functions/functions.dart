import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser != null) {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Navigate to the next screen after successful login
        // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
      }
    } catch (e) {
      // Handle and display the error to the user
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text("Sign in with Google failed: ${e.toString()}"),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

Future<void> signInWithFacebook() async {
  try {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    if (userCredential.user != null) {
      // Navigate to the next screen after successful login
      // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
    }
  } catch (e) {
    // Handle and display the error to the user
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(
        content: Text("Sign in with Facebook failed: ${e.toString()}"),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
