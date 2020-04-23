import 'package:flutter/material.dart';
import 'package:property_returns/screens/home/settings_form.dart';
import 'package:property_returns/screens/properties/add_property.dart';
import 'package:property_returns/screens/properties/add_unit.dart';
import 'package:property_returns/screens/properties/property_list.dart';
import 'package:property_returns/screens/tasks/add_task.dart';
import 'package:property_returns/screens/tasks/edit_task.dart';
import 'package:property_returns/screens/documents/test_flutter_markdown.dart';
import 'package:property_returns/screens/wrapper.dart';
import 'package:property_returns/services/auth.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/screens/tasks/task_list.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
      textTheme: TextTheme(
        display4: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: kColorOrange,
        activeTrackColor: kColorOrange,
        inactiveTrackColor: Colors.orange[100],
      ),
      primaryColor: kColorBlue,
      accentColor: kColorOrange,
      fontFamily: 'Roboto',
      dividerColor: kColorOrange,
      dividerTheme: DividerThemeData(
        color: kColorOrange,
        space: 50,
        thickness: 2,
        indent: 15,
        endIndent: 75,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: kColorOrange, // Background color (orange in my case).
        textTheme: ButtonTextTheme.accent,
        colorScheme: Theme.of(context)
            .colorScheme
            .copyWith(secondary: Colors.white), // Text color
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        elevation: 10,
        backgroundColor: kColorOrange,
      ),
    );

    return MultiProvider(
      providers: [
        StreamProvider<User>(create: (_) => AuthService().user),
        ProxyProvider<User, DatabaseServices>(
          update: (_, user, __) => DatabaseServices(uid: user?.userUid),
        ),
//        StreamProvider<UserData>(
//            create: (_) => DatabaseServices(uid: user.userUid).userData),
//        StreamProvider<QuerySnapshot>(
//            create: (_) => DatabaseServices(uid: 'user.userUid').allTasks),
//        StreamProvider<List<TaskDetails>>(
//            create: (_) =>
//                DatabaseServices(uid: 'user.userUid').userTasksByImportance),
// TODO this should work but ProxyProvider does not work with StreamProvider???
//      Instead have a StreamBuilder in relevant class (eg AddTask())
//        StreamProvider<List<PropertyDetails>>(
//          create: (_) => DatabaseServices(uid: 'UuO2DO0JUVbVD0R1JqIclI7fprF3')
//              .userProperties,
//        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: Wrapper(),
        routes: {
          SettingsForm.id: (context) => SettingsForm(),
          TaskList.id: (context) => TaskList(),
          AddTask.id: (context) => AddTask(),
          EditTask.id: (context) => EditTask(),
//          'lease_events': (context) => LeaseEvents(),
          PropertyList.id: (context) => PropertyList(),
          AddProperty.id: (context) => AddProperty(),
          AddUnit.id: (context) => AddUnit(),
//          'tenants': (context) => Tenants(),
//          'trades': (context) => Trades(),
//          'agents': (context) => Agents(),
          TestMarkdown.id: (context) => TestMarkdown(),
        },
      ),
    );
  }
}
