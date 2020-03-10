import 'package:flutter/material.dart';

class AddUnit extends StatelessWidget {
  final String propertyUid;
  final String propertyName;
  AddUnit({this.propertyUid, this.propertyName});

  static String id = 'add_unit_screen';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('$propertyUid - $propertyName'),
    );
  }
}
