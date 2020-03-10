import 'package:flutter/material.dart';

class EditUnit extends StatelessWidget {
  final String unitName;
  final String unitUid;
  EditUnit({this.unitUid, this.unitName});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('$unitUid - $unitName'),
    );
  }
}
