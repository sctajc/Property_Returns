import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_returns/screens/home/archived_list.dart';
import 'package:property_returns/screens/home/settings_form.dart';
import 'package:property_returns/screens/properties/add_property.dart';
import 'package:property_returns/screens/properties/add_unit.dart';
import 'package:property_returns/screens/properties/property_list.dart';
import 'package:property_returns/screens/tasks/add_task.dart';
import 'package:property_returns/screens/tasks/edit_task.dart';
import 'package:property_returns/screens/documents/test_flutter_markdown.dart';
import 'package:property_returns/screens/contacts/add_company.dart';
import 'package:property_returns/screens/contacts/company_list.dart';
import 'package:property_returns/screens/wrapper.dart';
import 'package:property_returns/services/auth.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/screens/tasks/task_list.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/screens/leases/lease_list.dart';
import 'package:property_returns/screens/leases/add_lease.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
      primaryTextTheme: GoogleFonts.solwayTextTheme(
        Theme.of(context).textTheme,
      ),
      primaryColor: kColorBlue,
      accentColor: kColorOrange,
      dividerColor: kColorOrange,
      textTheme: GoogleFonts.solwayTextTheme(Theme.of(context).textTheme),
//      textTheme: TextTheme(
//        headline1: GoogleFonts.solway(fontSize: 14),
//        headline2: GoogleFonts.solway(fontSize: 14),
//        headline3: GoogleFonts.solway(fontSize: 14),
//        headline4: GoogleFonts.solway(fontSize: 14),
//        headline5: GoogleFonts.solway(fontSize: 14),
//        headline6: GoogleFonts.solway(fontSize: 14),
//        subtitle1: GoogleFonts.solway(fontSize: 14),
//        subtitle2: GoogleFonts.solway(fontSize: 14),
//        bodyText1: GoogleFonts.solway(fontSize: 14),
//        bodyText2: GoogleFonts.solway(fontSize: 14),
//        caption: GoogleFonts.solway(fontSize: 14),
//        button: GoogleFonts.solway(fontSize: 14),
//      ),
      sliderTheme: SliderThemeData(
        thumbColor: kColorOrange,
        activeTrackColor: kColorOrange,
        inactiveTrackColor: Colors.orange[100],
      ),
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
          PropertyList.id: (context) => PropertyList(),
          AddProperty.id: (context) => AddProperty(),
          AddUnit.id: (context) => AddUnit(),
          AddCompany.id: (context) => AddCompany(),
          CompanyList.id: (context) => CompanyList(),
          LeaseList.id: (context) => LeaseList(),
          AddLease.id: (context) => AddLease(),
          ArchivedList.id: (context) => ArchivedList(),
          TestMarkdown.id: (context) => TestMarkdown(),
        },
      ),
    );
  }
}
