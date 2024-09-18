

import 'dart:io';

import 'package:chat_app_harsh_rp/auth/login_screen.dart';
import 'package:chat_app_harsh_rp/utils/progressbar.dart';
import 'package:chat_app_harsh_rp/utils/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_app_harsh_rp/provider/auth_provider.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../provider/auth_provider.dart'; // Adjust the path as necessary

class Authentication {
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Check if the user cancelled the sign-in process
      if (googleUser == null) {
          CustomSnackbar.show(context,'Sign-in process cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential;
    } catch (error) {
      // Handle and print the error
     CustomSnackbar.show(context,error.toString());
      // Optionally, you can display a user-friendly message here
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    progressbar.showProgresBar(context);
    try {

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Sign out from Google Sign-In
      await GoogleSignIn().signOut();


      // Update the AuthProvider state

     CustomSnackbar.show(context,"SignOut");
    } catch (error) {
      // Handle and print the error
     CustomSnackbar.show(context, error.toString());
      // Optionally, you can display a user-friendly message here
    }
  }
}
