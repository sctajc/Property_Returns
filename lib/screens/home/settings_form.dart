import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/models/user.dart';

class SettingsForm extends StatefulWidget {
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
      child: StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user.userUid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Update your settings',
                    style: heading,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    initialValue: userData.userName,
                    decoration:
                        textInputDecoration.copyWith(hintText: 'your name'),
                    validator: (val) =>
                        val.isEmpty ? 'Please enter your name' : null,
                    onChanged: (val) => setState(() => _currentName = val),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Lease Notification days ',
                    style: fieldHeading,
                  ),
                  Slider(
                    divisions: 10,
                    min: 0,
                    max: 100,
                    label:
                        '${_currentLeaseNotificationDays ?? userData.leaseNotificationDays}',
                    value: (_currentLeaseNotificationDays ??
                            userData.leaseNotificationDays)
                        .toDouble(),
                    onChanged: (newVal) => setState(
                        () => _currentLeaseNotificationDays = newVal.round()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Task Notification days',
                    style: fieldHeading,
                  ),
                  Slider(
                    divisions: 10,
                    min: 0,
                    max: 100,
                    label:
                        '${_currentTaskNotificationDays ?? userData.taskNotificationDays}',
                    value: (_currentTaskNotificationDays ??
                            userData.taskNotificationDays)
                        .toDouble(),
                    onChanged: (newVal) => setState(
                        () => _currentTaskNotificationDays = newVal.round()),
                  ),
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
            );
          } else {
            return Loading();
          }
        },
      ),
    );
  }
}
