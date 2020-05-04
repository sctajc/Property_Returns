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
  int _currentAreaMeasurementM2;
  String _currentCurrencySymbol;

  bool _resultRadioAreaMeasurement;

  void _handleRadioAreaMeasurementChange(int value) {
    setState(() {
      _currentAreaMeasurementM2 = value;
    });
  }

  Widget currencyTemplate(currency) {
    return ChoiceChip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      label: Text(currency),
      selected: false,
      onSelected: (bool selected) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    //TODO why will final userData = Provider.of<UserData>(context) not work?
    return StreamBuilder<UserData>(
      stream: DatabaseServices(uid: user.userUid).userData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        UserData userData = snapshot.data;
        if (_currentAreaMeasurementM2 == null) {
          switch (userData.areaMeasurementM2) {
            case true:
              _currentAreaMeasurementM2 = 0;
              break;
            case false:
              _currentAreaMeasurementM2 = 1;
              break;
          }
        }
        if (_currentCurrencySymbol == null) {
          _currentCurrencySymbol = userData.currencySymbol;
        }
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
                    textFormFieldSettingsName(userData),
                    SizedBox(
                      height: 20,
                    ),
                    sliderTextSettingsTaskNotification(userData),
                    sliderSliderSettingsTaskNotification(userData),
                    SizedBox(
                      height: 20,
                    ),
                    sliderTextSettingsLeaseNotification(userData),
                    sliderSliderSettingsLeaseNotification(userData),
                    SizedBox(
                      height: 20,
                    ),
                    radioSettingsAreaSymbol(),
                    SizedBox(
                      height: 20,
                    ),
                    choiceChipSettingsCurrencySymbol(),
                    SizedBox(
                      height: 20,
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
                      switch (_currentAreaMeasurementM2) {
                        case 0:
                          _resultRadioAreaMeasurement = true;
                          break;
                        case 1:
                          _resultRadioAreaMeasurement = false;
                          break;
                      }
                      await DatabaseServices(uid: user.userUid)
                          .updateUserDetails(
                        _currentName ?? userData.userName,
                        _currentLeaseNotificationDays ??
                            userData.leaseNotificationDays,
                        _currentTaskNotificationDays ??
                            userData.taskNotificationDays,
                        _resultRadioAreaMeasurement,
                        _currentCurrencySymbol,
                      );
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  choiceChipSettingsCurrencySymbol() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Currency Symbol',
            style: kFieldHeading,
          ),
          Wrap(
            spacing: 8,
            children: List<Widget>.generate(
              currencies.length,
              (int index) {
                return ChoiceChip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  label: Text(
                    currencies[index],
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  selected: (currencies[index] == _currentCurrencySymbol)
                      ? true
                      : false,
                  onSelected: (bool selected) {
                    if (selected)
                      setState(() {
                        _currentCurrencySymbol = currencies[index];
                      });
                  },
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  radioSettingsAreaSymbol() {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'Area Measurement (squared): ',
            style: kFieldHeading,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Radio(
                value: 0,
                groupValue: _currentAreaMeasurementM2,
                onChanged: _handleRadioAreaMeasurementChange,
              ),
              Text(
                'Meters',
                style: kInputText,
              ),
              Radio(
                  value: 1,
                  groupValue: _currentAreaMeasurementM2,
                  onChanged: _handleRadioAreaMeasurementChange),
              Text(
                'Feet',
                style: kInputText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  sliderSliderSettingsLeaseNotification(UserData userData) {
    return Slider(
      min: 0,
      max: 100,
//                        label:
//                            '${_currentLeaseNotificationDays ?? userData.leaseNotificationDays}',
      value: (_currentLeaseNotificationDays ?? userData.leaseNotificationDays)
          .toDouble(),
      onChanged: (newVal) => setState(() {
        _currentLeaseNotificationDays = newVal.round();
      }),
    );
  }

  sliderTextSettingsLeaseNotification(UserData userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Lease Notification: ',
          style: kFieldHeading,
        ),
        Text(
          '${_currentLeaseNotificationDays ?? userData.leaseNotificationDays} ',
          style: kInputText.copyWith(fontSize: 18),
        ),
        Text(
          'days',
          style: kFieldHeading,
        ),
      ],
    );
  }

  sliderSliderSettingsTaskNotification(UserData userData) {
    return Slider(
      min: 0,
      max: 100,
//                        label:
//                            '${_currentTaskNotificationDays ?? userData.taskNotificationDays}',
      value: (_currentTaskNotificationDays ?? userData.taskNotificationDays)
          .toDouble(),
      onChanged: (newVal) =>
          setState(() => _currentTaskNotificationDays = newVal.round()),
    );
  }

  sliderTextSettingsTaskNotification(UserData userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Task Notification: ',
          style: kFieldHeading,
        ),
        Text(
          '${_currentTaskNotificationDays ?? userData.taskNotificationDays} ',
          style: kInputText.copyWith(fontSize: 18),
        ),
        Text(
          'days',
          style: kFieldHeading,
        ),
      ],
    );
  }

  textFormFieldSettingsName(UserData userData) {
    return TextFormField(
      keyboardType: TextInputType.text,
      initialValue: userData.userName,
      decoration: kTextInputDecoration.copyWith(
          hintText: 'name', labelStyle: kFieldHeading, labelText: 'Known as'),
      validator: (val) => val.isEmpty ? 'Please enter your name' : null,
      onChanged: (val) => setState(() => _currentName = val),
    );
  }
}
