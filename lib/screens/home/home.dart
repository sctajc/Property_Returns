import 'package:flutter/material.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/screens/contacts/company_list.dart';
import 'package:property_returns/screens/leases/lease_list.dart';
import 'package:property_returns/screens/properties/property_list.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/services/auth.dart';
import 'package:property_returns/screens/home/settings_form.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/screens/home/home_page.dart';
import 'package:property_returns/screens/tasks/task_list.dart';
import 'package:property_returns/shared/loading.dart';

class Home extends StatelessWidget {
  // _auth is only required for signOut
  final AuthService _auth = AuthService();

  // display settings panel
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData>(context);

    // display log out & settings buttons
    var appBar = AppBar(
      elevation: 0,
      actions: <Widget>[
        FlatButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: Icon(Icons.person),
            label: Text('Log out')),
        FlatButton.icon(
//            onPressed: () => Navigator.pushNamed(context, SettingsForm.id), // cant use as need to pass userUid to settings form
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingsForm(
                      userUid: user.userUid,
                    ))),
            icon: Icon(Icons.settings),
            label: Text('settings'))
      ],
    );
    if (userData == null) {
      return Loading();
    } else {
      return Scaffold(
        drawer: buildDrawer(context),
        backgroundColor: Colors.blueAccent[50],
        appBar: appBar,
        body: HomePage(),
      );
    }
  }

  Drawer buildDrawer(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: kColorBlue),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Image.asset(
                  'assets/property_returns_logo_drawn.png',
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  userData.userName ?? '',
                  style: kHeading.copyWith(fontSize: 18),
                ),
                SizedBox(
                  height: 20,
                  child: Text(
                    user.userEmail,
                    style: kHeading.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, TaskList.id);
//              Navigator.of(context)
//                  .push(MaterialPageRoute(builder: (context) => TaskList()));
              },
              child: Text('Tasks'),
            ),
          ),
          Divider(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, PropertyList.id);
              },
              child: Text('Properties'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, CompanyList.id);
              },
              child: Text('Contacts'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, LeaseList.id);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LeaseList(
                          userUid: user.userUid,
                          userName: userData.userName,
                        )));
              },
              child: Text('Leases'),
            ),
          ),
          Divider(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('List Tenants'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('List Trades'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('List Agents'),
            ),
          ),
          Divider(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('Property Summary'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('Tasks Archived'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('Properties Archived'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('Units Archived'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
              },
              child: Text('Past lease Events'),
            ),
          ),
          Divider(
            height: 20,
          ),
          ListTile(
            title: Text('Close'),
            onTap: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }
}
