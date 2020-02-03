import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

const textInputDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 2,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: colorOrange, width: 2),
  ),
  fillColor: Colors.white,
  filled: true,
);

const colorOrange = Color(0xfffda400);
const colorBlue = Color(0xff1691e6);
const heading =
    TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorOrange);
const fieldHeading =
    TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: colorOrange);

// display FlushBar (toast, snackBar)
void showHelpToast(context, String message) {
  Flushbar(
    messageText: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 20),
    ),
    duration: Duration(seconds: 10),
    backgroundColor: colorBlue,
    flushbarPosition: FlushbarPosition.BOTTOM,
    borderRadius: 10,
  )..show(context);
}
