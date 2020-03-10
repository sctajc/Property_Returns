import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/models/user.dart';

class SettingsForm extends StatefulWidget {
  static String id = 'setting_form_screen';
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentName;
  int _currentLeaseNotificationDays;
  int _currentTaskNotificationDays;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
      stream: DatabaseServices(uid: user.userUid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data;
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(
                'Update your settings',
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        initialValue: userData.userName,
                        decoration: kTextInputDecoration.copyWith(
                            hintText: 'your name'),
                        validator: (val) =>
                            val.isEmpty ? 'Please enter your name' : null,
                        onChanged: (val) => setState(() => _currentName = val),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Task Notification: ',
                            style: kFieldHeading,
                          ),
                          Text(
                            ' $_currentTaskNotificationDays ',
                            style: kInputText,
                          ),
                          Text(
                            'days',
                            style: kFieldHeading,
                          ),
                        ],
                      ),
                      Slider(
//                        divisions: 10,
                        min: 0,
                        max: 100,
//                        label:
//                            '${_currentTaskNotificationDays ?? userData.taskNotificationDays}',
                        value: (_currentTaskNotificationDays ??
                                userData.taskNotificationDays)
                            .toDouble(),
                        onChanged: (newVal) => setState(() =>
                            _currentTaskNotificationDays = newVal.round()),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Lease Notification: ',
                            style: kFieldHeading,
                          ),
                          Text(
                            ' $_currentLeaseNotificationDays ',
                            style: kInputText,
                          ),
                          Text(
                            'days',
                            style: kFieldHeading,
                          ),
                        ],
                      ),
                      Slider(
//                        divisions: 10,
                        min: 0,
                        max: 100,
//                        label:
//                            '${_currentLeaseNotificationDays ?? userData.leaseNotificationDays}',
                        value: (_currentLeaseNotificationDays ??
                                userData.leaseNotificationDays)
                            .toDouble(),
                        onChanged: (newVal) => setState(() =>
                            _currentLeaseNotificationDays = newVal.round()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                      child: Text(
                        'Update',
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await DatabaseServices(uid: user.userUid)
                              .updateUserDetails(
                                  _currentName ?? userData.userName,
                                  _currentLeaseNotificationDays ??
                                      userData.leaseNotificationDays,
                                  _currentTaskNotificationDays ??
                                      userData.taskNotificationDays);
                          Navigator.pop(context);
                        }
                      })
                ],
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
