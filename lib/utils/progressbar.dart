import 'package:flutter/material.dart';

class progressbar {
  static void showProgresBar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.grey.shade200, // Background color
            strokeWidth: 4.0, // Thickness of the progress indicator
          ),
        );
      },
    );
  }

  static void hideProgressBar(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss the dialog
  }
}
