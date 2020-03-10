import 'package:flutter/material.dart';

class EditProperty extends StatelessWidget {
  final String propertyUid;
  EditProperty({this.propertyUid});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('$propertyUid'),
    );
  }
}
