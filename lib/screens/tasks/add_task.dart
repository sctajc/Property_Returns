import 'package:flutter/material.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();

  String _currentTitle;
  String _currentDetail;
  int _currentImportance = 5;
  DateTime _currentDueDateTime;
  bool _currentArchived = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Add a task',
                style: heading,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
//                initialValue: 'initial value',
                decoration:
                    textInputDecoration.copyWith(hintText: 'short title'),
                validator: (val) => val.isEmpty
                    ? 'Please enter a brief task description'
                    : null,
                onChanged: (val) => setState(() => _currentTitle = val),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
//                initialValue: 'initial description',
                decoration:
                    textInputDecoration.copyWith(hintText: 'more details'),
                validator: (val) =>
                    val.isEmpty ? 'Please enter task details' : null,
                onChanged: (val) => setState(() => _currentDetail = val),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Importance',
                    style: fieldHeading,
                  ),
                  Slider(
                    divisions: 9,
                    min: 1,
                    max: 10,
                    value: (_currentImportance ?? 5).toDouble(),
                    onChanged: (val) => setState(
                      () => _currentImportance = val.round(),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Due:',
                    style: fieldHeading,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DateTimeField(
                      validator: (val) =>
                          val == null ? 'Please enter a due date' : null,
                      format: DateFormat("E,  MMM d, y  -  HH:mm"),
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(Duration(days: 14)),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));
                        if (date != null) {
                          final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                DateTime.now(),
                              ),
                              builder: (BuildContext context, Widget child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child,
                                );
                              });
                          _currentDueDateTime =
                              DateTimeField.combine(date, time);
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                      initialValue: DateTime.now().add(Duration(days: 14)),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      DateTime _currentEditedDateTime = DateTime.now();
                      await DatabaseServices().addUserTask(
                          user.userUid,
                          _currentTitle,
                          _currentDetail,
                          _currentArchived,
                          _currentImportance,
                          _currentDueDateTime,
                          _currentEditedDateTime);
                      Navigator.pop(context);
                    }
                  })
            ],
          )),
    );
  }
}
