import 'package:flutter/material.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/user_details.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/services/auth.dart';
import 'package:property_returns/screens/home/settings_form.dart';
import 'package:property_returns/shared/constants.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    void _showSettingsPanel() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SettingsForm();
        },
      );
    }

    return StreamProvider<List<UserDetails>>.value(
      value: DatabaseServices().users,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        'assets/property_returns_logo_drawn.png',
                        width: 200,
                      ),
                    ),
                    Text(
                      'name',
                      style: TextStyle(color: colorOrange, fontSize: 25),
                    ),
                    Text(
                      'email',
                      style: TextStyle(color: colorOrange, fontSize: 25),
                    ),
                  ],
                ),
                decoration: BoxDecoration(color: colorBlue),
              ),
              ListTile(
                title: Text('Tasks'),
                onTap: () {
                  Navigator.pop(context);
                },
                //        onTap: () => Navigator.push(context,
//            MaterialPageRoute(builder: (BuildContext context) => Tasks())),
              ),
              ListTile(
                title: Text('Lease events'),
                onTap: () => null,

//        onTap: () => Navigator.push(context,
//            MaterialPageRoute(builder: (BuildContext context) => Events())),
              ),
              Divider(
                height: 0,
                indent: 15,
                color: Colors.blueAccent,
              ),
              ListTile(
                title: Text('My properties'),
                onTap: () => null,
//        onTap: () => Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (BuildContext context) => Properties())),
              ),
              ListTile(
                title: Text('Tenants'),
                onTap: () => null,
              ),
              ListTile(
                title: Text('Trades'),
                onTap: () => null,
              ),
              ListTile(
                title: Text('Agents'),
                onTap: () => null,
              ),
              ListTile(
                title: Text('Documents'),
                onTap: () => null,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text(''),
          backgroundColor: colorBlue,
          elevation: 0,
          actions: <Widget>[
            FlatButton.icon(
                onPressed: () async {
                  await _auth.signOut();
                },
                icon: Icon(Icons.person),
                label: Text('Log out')),
            FlatButton.icon(
                onPressed: () => _showSettingsPanel(),
                icon: Icon(Icons.settings),
                label: Text('settings'))
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
                alignment: Alignment.bottomCenter,
                image: AssetImage('assets/property_returns_logo_drawn.png'),
                fit: BoxFit.fitWidth),
          ),
        ),
      ),
    );
  }
}
