import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/screens/authenticate/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/screens/home/home.dart';
import 'package:property_returns/services/database.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {
//      print('Wrapper: ${user.userUid}');
//      print('Wrapper: ${user.userEmail}');
      return MultiProvider(
        providers: [
          StreamProvider<UserData>(
              create: (_) => DatabaseServices(uid: user.userUid).userData),
          StreamProvider<List<TaskDetails>>(
              create: (_) =>
                  DatabaseServices(uid: user.userUid).userTasksByImportance),
          StreamProvider<QuerySnapshot>(
              create: (_) => DatabaseServices(uid: user.userUid).allTasks),
          StreamProvider<List<PropertyDetails>>(
            create: (_) => DatabaseServices(uid: user.userUid).userProperties,
          )
        ],
        child: Home(),
      );
    }
  }
}
