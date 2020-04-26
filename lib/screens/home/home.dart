import 'package:flutter/material.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/screens/contacts/company_list.dart';
import 'package:property_returns/screens/properties/property_list.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/services/auth.dart';
import 'package:property_returns/screens/home/settings_form.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/screens/home/home_page.dart';
import 'package:property_returns/screens/tasks/task_list.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:property_returns/services/database.dart';

class Home extends StatelessWidget {
  // _auth is only required for signOut
  final AuthService _auth = AuthService();

  // display settings panel
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData>(context);
    final userProperties =
        Provider.of<DatabaseServices>(context).userProperties;

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
            onPressed: () => Navigator.pushNamed(context, SettingsForm.id),
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
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
                alignment: Alignment.bottomCenter,
                image: AssetImage('assets/property_returns_logo_drawn.png'),
                fit: BoxFit.fitWidth),
          ),
          child: HomePage(),
        ),
      );
    }
  }

  Drawer buildDrawer(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData>(context);
    final double _minHeight = 40;
    final double _maxHeight = 40;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/property_returns_logo_drawn.png',
                    width: 200,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  userData.userName ?? '',
                  style: kHeading.copyWith(fontSize: 18),
                ),
                SizedBox(height: 7),
                Text(
                  user.userEmail,
                  style: kHeading.copyWith(fontSize: 18),
                ),
              ],
            ),
            decoration: BoxDecoration(color: kColorBlue),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, TaskList.id);
//              Navigator.of(context)
//                  .push(MaterialPageRoute(builder: (context) => TaskList()));
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Tasks'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Lease events'),
            ),
          ),
          Divider(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, PropertyList.id);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Properties'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, CompanyList.id);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Contacts'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, 'test_flutter_markdown_screen');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Documents'),
            ),
          ),
          Divider(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('List Tenants'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('List Trades'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('List Agents'),
            ),
          ),
          Divider(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Property Summary'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Tasks Archived'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Properties Archived'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Units Archived'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
//              Navigator.pushNamed(context, 'task_list');
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
              constraints: BoxConstraints(
                minHeight: _minHeight,
                maxHeight: _maxHeight,
              ),
              child: Text('Past lease Events'),
            ),
          ),
          Divider(
            height: 20,
          ),
          ListTile(
            title: Text('Close'),
            trailing: Icon(Icons.close),
            onTap: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }
}
