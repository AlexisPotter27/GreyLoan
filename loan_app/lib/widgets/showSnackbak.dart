// lib/snackbar_utils.dart

import 'package:flutter/material.dart';

// Function to show the Snackbar
void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.teal,
      duration: Duration(seconds: 7),
    ),
  );
}
