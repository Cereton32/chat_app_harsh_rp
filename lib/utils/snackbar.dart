import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,        // Text color
          fontSize: 16.0,             // Text size
          fontWeight: FontWeight.w600, // Text weight
        ),
      ),
      backgroundColor: Colors.black87, // Background color
      behavior: SnackBarBehavior.floating, // Floating style
      elevation: 6.0,                // Elevation for shadow
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),                              // Margin around the Snackbar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      duration: Duration(seconds: 3), // Display duration
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.blueAccent,
        onPressed: () {
          // Optional: Dismiss action
        },
      ),
    );

    // Show the Snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
 
}
