import 'package:flutter/material.dart';
import 'package:property_returns/screens/home/settings_form.dart';
import 'package:property_returns/screens/tasks/add_task.dart';
import 'package:property_returns/screens/tasks/edit_task.dart';
import 'package:property_returns/screens/tasks/task_list.dart';
import 'package:property_returns/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/services/auth.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
        sliderTheme: SliderThemeData(
            activeTrackColor: colorOrange,
            inactiveTrackColor: Colors.orange[100]),
        primaryColor: colorBlue,
        accentColor: colorOrange,
        fontFamily: 'Roboto',
        dividerColor: colorOrange,
        dividerTheme: DividerThemeData(
          color: colorOrange,
          thickness: 2,
          indent: 15,
          endIndent: 75,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: colorOrange, // Background color (orange in my case).
          textTheme: ButtonTextTheme.accent,
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(secondary: Colors.white), // Text color
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          elevation: 10,
          backgroundColor: colorOrange,
        ));

    return MultiProvider(
      providers: [
        StreamProvider<User>.value(value: AuthService().user),
      ],
      child: MaterialApp(
        theme: themeData,
        home: Wrapper(),
        routes: {
          SettingsForm.id: (context) => SettingsForm(),
          TaskList.id: (context) => TaskList(),
          AddTask.id: (context) => AddTask(),
          EditTask.id: (context) => EditTask(),
//          'lease_events': (context) => LeaseEvents(),
//          'properties': (context) => Properties(),
//          'tenants': (context) => Tenants(),
//          'trades': (context) => Trades(),
//          'agents': (context) => Agents(),
//          'display_documents': (context) => DisplayDocuments(),
        },
      ),
    );
  }
}
