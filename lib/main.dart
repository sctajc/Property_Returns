import 'package:flutter/material.dart';
import 'package:property_returns/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/services/auth.dart';
import 'package:property_returns/models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
