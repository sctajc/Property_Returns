import 'package:flutter/material.dart';
import 'package:property_returns/models/lease_details.dart';
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
          StreamProvider<List<LeaseEventDetails>>(
              create: (_) =>
                  DatabaseServices(uid: user.userUid).allLeaseEventsForUser),
        ],
        child: Home(),
      );
    }
  }
}
