import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';

class AddTask extends StatefulWidget {
  static String id = 'add_task_screen';

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();

  List<String> _properties = [
    'none',
    'Rosebank - unit A',
    'Rosebank - Unit B',
    'St George - Unit A',
    'St George - unit B',
  ];
  String _currentPropertySelected = 'none';
  String _currenttenantSelected = 'none';
  String _currentTradeSelected = 'none';
  String _currentAgentSelected = 'none';
  String _currentDocumentSelected = 'none';

  // form values
  String _currentTitle;
  String _currentDetail;
  int _currentImportance = 5;
  DateTime _currentDueDateTime;
  bool _currentArchived = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Add a new task',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Due',
                        style: fieldHeading,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 250,
                          child: DateTimeField(
                            validator: (val) =>
                                val == null ? 'Please enter a due date' : null,
                            format: DateFormat("E,  MMM d, y  -  HH:mm"),
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      DateTime.now().add(Duration(days: 14)),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (date != null) {
                                final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      DateTime.now(),
                                    ),
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
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
                            initialValue:
                                DateTime.now().add(Duration(days: 14)),
                          ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Property',
                        style: fieldHeading,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: _currentPropertySelected,
                          items: _properties.map((String dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (String newPropertySelected) {
                            setState(() {
                              _currentPropertySelected = newPropertySelected;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Tenant',
                        style: fieldHeading,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField(
                            value: 'none',
                            items: _properties.map((String dropDownStringItem) {
                              return DropdownMenuItem(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (String newPropertySelected) {
                              setState(() {
                                _currentPropertySelected = newPropertySelected;
                                print(_currentPropertySelected);
                              });
                            }),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Trade',
                        style: fieldHeading,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField(
                            value: 'none',
                            items: _properties.map((String dropDownStringItem) {
                              return DropdownMenuItem(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (String newPropertySelected) {
                              setState(() {
                                _currentPropertySelected = newPropertySelected;
                                print(_currentPropertySelected);
                              });
                            }),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Agent',
                        style: fieldHeading,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField(
                            value: 'none',
                            items: _properties.map((String dropDownStringItem) {
                              return DropdownMenuItem(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (String newPropertySelected) {
                              setState(() {
                                _currentPropertySelected = newPropertySelected;
                                print(_currentPropertySelected);
                              });
                            }),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Document',
                        style: fieldHeading,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField(
                            value: 'none',
                            items: _properties.map((String dropDownStringItem) {
                              return DropdownMenuItem(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (String newPropertySelected) {
                              setState(() {
                                _currentPropertySelected = newPropertySelected;
                                print(_currentPropertySelected);
                              });
                            }),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
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
        ),
      ),
    );
  }
}
