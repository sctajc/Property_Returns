import 'package:flutter/material.dart';

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
    filled: true);

const colorOrange = Color(0xfffda400);
const colorBlue = Color(0xff1691e6);
const heading =
    TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorOrange);
const fieldHeading =
    TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: colorOrange);
