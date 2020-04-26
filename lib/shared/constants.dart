import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

const kTextInputDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 2,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kColorOrange, width: 2),
  ),
  fillColor: Colors.white,
  filled: true,
);

const kColorOrange = Color(0xfffda400);
const kColorBlue = Color(0xff1691e6);
const kHeading =
    TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kColorOrange);
const kFieldHeading =
    TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: kColorOrange);
const kInputText =
    TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black);

// display FlushBar (toast, snackBar)
void kShowHelpToast(context, String message) {
  Flushbar(
    messageText: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 20),
    ),
    duration: Duration(seconds: 10),
    backgroundColor: kColorBlue,
    flushbarPosition: FlushbarPosition.BOTTOM,
    borderRadius: 10,
  )..show(context);
}

const List<String> currencies = [
  '\$',
  '€',
  '¥',
  '£',
  '元',
  'kr',
  '₩',
  '₹',
  '₽',
  'R',
  'zł',
  '฿',
  '₪'
];

Pattern emailPattern = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
    "\\@" +
    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
    "(" +
    "\\." +
    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
    ")+";
RegExp emailRegex = RegExp(emailPattern);

// need a website regexp that works
Pattern webPattern = "http(s)?://)?([\w-]+\.)+[\w-]+(/[\w- ;,./?%&=]*";
RegExp webRegex = RegExp(webPattern);
