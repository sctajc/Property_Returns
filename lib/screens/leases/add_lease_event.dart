import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/lease_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/shared/loading.dart';

class AddLeaseEvent extends StatefulWidget {
  static String id = 'add_lease_event_screen';
  final String leaseUid;
  final String leaseTenantName;
  final String leasePropertyName;

  AddLeaseEvent({this.leaseUid, this.leasePropertyName, this.leaseTenantName});

  @override
  _AddLeaseEventState createState() => _AddLeaseEventState();
}

class _AddLeaseEventState extends State<AddLeaseEvent> {
  bool leaseEventHappened = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, String> _mapLeaseEventTypes = {'none': 'Select Event'};

  // form values
  String _currentLeaseEventType = 'none';
  DateTime _currentLeaseEventDate;
  bool _currentLeaseEventHappened = false;
  String _currentLeaseEventComment = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<List<LeaseEventTypeDetails>>(
        stream: DatabaseServices().allLeaseEventTypes,
        builder: (context, leaseEventTypes) {
          if (!leaseEventTypes.hasData) return Loading();
          for (LeaseEventTypeDetails leaseEventType in leaseEventTypes.data) {
            _mapLeaseEventTypes[leaseEventType.leaseEventTypeUid] =
                leaseEventType.leaseEventTypeName;
//            print(
//                '${leaseEventType.leaseEventTypeUid}: ${leaseEventType.leaseEventTypeOrder}: ${leaseEventType.leaseEventTypeName}');
          }
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(
                'Lease Event: ${widget.leaseTenantName}',
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
                          height: 10,
                        ),
                        Text(
                          widget.leasePropertyName,
                          style: kFieldHeading,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _displayLeaseEventType(),
                        SizedBox(
                          height: 10,
                        ),
                        // display lease event date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Date',
                                  style: kFieldHeading,
                                ),
                                Text(
                                  'for',
                                  style: kFieldHeading,
                                ),
                                Text(
                                  'event',
                                  style: kFieldHeading,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 200,
                                    child: DateTimeField(
                                      validator: (val) => val == null
                                          ? 'Please enter an event date'
                                          : null,
                                      initialValue: null,
                                      format: DateFormat("E,  MMM d, y"),
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1950),
                                          lastDate: DateTime(2100),
                                        );
                                        if (date != null) {
                                          _currentLeaseEventDate = date;
                                          return _currentLeaseEventDate;
                                        } else {
                                          return currentValue;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _displayLeaseEventHappened(context),
                        SizedBox(
                          height: 10,
                        ),
                        _displayLeaseEventComment(),
                        SizedBox(
                          // so keyboard does not hide bottom textfield
                          height: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ],
                    )),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                      child: Text('Add'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await DatabaseServices().addUserLeaseEvent(
                            widget.leaseUid,
                            user.userUid,
                            _currentLeaseEventType,
                            _currentLeaseEventDate,
                            _currentLeaseEventHappened,
                            _currentLeaseEventComment,
                            Timestamp.now(),
                            Timestamp.now(),
                          );
                          Navigator.pop(context);
                        }
                      })
                ],
              ),
            ),
          );
        });
  }

  _displayLeaseEventComment() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Comment',
          labelStyle: kFieldHeading,
          hintText: 'any notes'),
//      validator: (val) => val.isEmpty ? 'Please enter comments' : null,
      onChanged: (val) => setState(() => _currentLeaseEventComment = val),
    );
  }

  _displayLeaseEventHappened(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Happened??',
        style: kFieldHeading,
      ),
      value: leaseEventHappened,
      onChanged: (value) {
        setState(() {
          leaseEventHappened = value;
          _currentLeaseEventHappened = leaseEventHappened;
        });
      },
      secondary: GestureDetector(
        onTap: () =>
            kShowHelpToast(context, "Select if event has already happened"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }

  _displayLeaseEventType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Text(
            'Event Type',
            style: kFieldHeading,
          ),
        ),
        SizedBox(
          width: 30,
        ),
        Flexible(
            flex: 3,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: 'none',
              items: _mapLeaseEventTypes
                  .map(
                    (key, value) {
                      return MapEntry(
                        key,
                        DropdownMenuItem<String>(
                          child: Text(value),
                          value: key,
                        ),
                      );
                    },
                  )
                  .values
                  .toList(),
              onChanged: (String val) {
                setState(() {
                  _currentLeaseEventType = val;
                });
              },
              validator: (val) =>
                  val.contains('none') ? 'Please select a lease event' : null,
            ))
      ],
    );
  }
}
