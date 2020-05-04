import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/company_details.dart';

class EditTask extends StatefulWidget {
  static String id = 'edit_task_screen';
  final TaskDetails tasksDetails;
  EditTask({this.tasksDetails});

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  bool _archiveTask = false;
  final _formKey = GlobalKey<FormState>();
  Map _propertyUnitNames = Map<String, String>();
  Map<String, String> _mapProperties = {'none': 'none'};
  Map _tenantCompanyPersonNames = Map<String, String>();
  Map<String, String> _mapTenantCompanies = {'none': 'none'};

  // form values
  String _currentTaskTitle;
  String _currentTaskDetail;
  int _currentTaskImportance;
  DateTime _currentTaskDueDateTime;
  String _currentPropertySelected;
  String _currentTenantSelected;
  String _currentTradeSelected = 'none';
  String _currentAgentSelected = 'none';
  String _currentDocumentSelected = 'none';
  bool _currentTaskArchived = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final taskID = widget.tasksDetails.taskID;

    return StreamBuilder<TaskDetails>(
      stream:
          DatabaseServices(uid: user.userUid, taskID: taskID).taskByDocumentID,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        TaskDetails tasksDetails = snapshot.data;
        print('edit task: ${tasksDetails.taskUnitUid}');
        return StreamBuilder<List<PropertyDetails>>(
            stream: DatabaseServices(uid: user.userUid).userProperties,
            builder: (context, userProperties) {
              if (!userProperties.hasData) return Loading();
              for (PropertyDetails userProperty in userProperties.data) {
                _mapProperties[userProperty.propertyUid] =
                    userProperty.propertyName;
              }
              return StreamBuilder<List<CompanyDetails>>(
                  stream: DatabaseServices(uid: user.userUid).userTenants,
                  builder: (context, userTenants) {
                    if (!userTenants.hasData) return Loading();
                    for (CompanyDetails userTenant in userTenants.data) {
//                print(
//                    'tenant company uid: ${userTenant.companyUid} - tenant name: ${userTenant.companyName}');
                      _mapTenantCompanies[userTenant.companyUid] =
                          userTenant.companyName;
                    }
//              print('_mapTenantCompanies: $_mapTenantCompanies');
                    return Scaffold(
                      resizeToAvoidBottomPadding: false,
                      appBar: AppBar(
                        title: Text(
                          'Edit task',
                        ),
                      ),
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                _displayTaskTitleField(tasksDetails),
                                SizedBox(
                                  height: 10,
                                ),
                                _displayTaskDetailsField(tasksDetails),
                                SizedBox(
                                  height: 10,
                                ),
                                _displayTaskImportanceField(tasksDetails),
                                // display task due date
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Due',
                                      style: kFieldHeading,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: DateTimeField(
                                        validator: (val) => val == null
                                            ? 'Please enter a due date'
                                            : null,
                                        format: DateFormat(
                                            "E,  MMM d, y  -  HH:mm"),
                                        onShowPicker:
                                            (context, currentValue) async {
                                          final date = await showDatePicker(
                                              context: context,
                                              initialDate: tasksDetails
                                                  .taskDueDateTime
                                                  .toDate(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2100));
                                          if (date != null) {
                                            final time = await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    TimeOfDay.fromDateTime(
                                                        tasksDetails
                                                            .taskDueDateTime
                                                            .toDate()),
                                                builder: (BuildContext context,
                                                    Widget child) {
                                                  return MediaQuery(
                                                    data: MediaQuery.of(context)
                                                        .copyWith(
                                                            alwaysUse24HourFormat:
                                                                true),
                                                    child: child,
                                                  );
                                                });
                                            _currentTaskDueDateTime =
                                                DateTimeField.combine(
                                                    date, time);
                                            return DateTimeField.combine(
                                                date, time);
                                          } else {
                                            return currentValue;
                                          }
                                        },
                                        initialValue: tasksDetails
                                            .taskDueDateTime
                                            .toDate(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                _displayTaskPropertyField(user, tasksDetails),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        'Tenant',
                                        style: kFieldHeading,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: StreamBuilder<List<PersonDetails>>(
                                        stream:
                                            DatabaseServices(uid: user.userUid)
                                                .allPersonsForUser,
                                        builder: (context, allUserPersons) {
                                          if (!allUserPersons.hasData)
                                            return Loading();
                                          else {
                                            _tenantCompanyPersonNames['none'] =
                                                ' none';
                                            for (int i = 0;
                                                i < allUserPersons.data.length;
                                                i++) {
                                              if ((_mapTenantCompanies[
                                                      '${allUserPersons.data[i].companyUid}']) !=
                                                  null) {
                                                _tenantCompanyPersonNames[
                                                        allUserPersons.data[i]
                                                            .personUid] =
                                                    '${_mapTenantCompanies['${allUserPersons.data[i].companyUid}']} - ${allUserPersons.data[i].personName}';
                                              }

                                              // TODO is this a good way to fudge a SQL like join?
                                              //  getting property name and unit names into one map from Firestore
                                              // ie ('unitUid', 'George St - RHS front warehouse')
//                                        print(
//                                            'person name: ${allUserPersons.data[i].personName}');
//                                        print(
//                                            'company Uid: ${allUserPersons.data[i].companyUid}');
//                                        print(
//                                            'company name: ${_mapTenantCompanies['${allUserPersons.data[i].companyUid}']}');
                                            }
                                          }
                                          Map _sortedTenantCompanyPersonNames =
                                              Map.fromEntries(
                                                  _tenantCompanyPersonNames
                                                      .entries
                                                      .toList()
                                                        ..sort((e1, e2) =>
                                                            e1.value.compareTo(
                                                                e2.value)));
//                                    print(
//                                        '_tenantCompanyPersonNames: $_sortedTenantCompanyPersonNames');
                                          return DropdownButtonFormField<
                                              String>(
                                            isExpanded: true,
                                            value: _currentTenantSelected ??
                                                tasksDetails.taskTenantUid,
                                            items:
                                                _sortedTenantCompanyPersonNames
                                                    .map(
                                                      (key, value) {
                                                        return MapEntry(
                                                          key,
                                                          DropdownMenuItem<
                                                              String>(
                                                            child: Text(value),
                                                            value: key,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                    .values
                                                    .toList(),
                                            onChanged:
                                                (String newTenantSelected) {
                                              setState(() {
                                                _currentTenantSelected =
                                                    newTenantSelected;
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        'Trade',
                                        style: kFieldHeading,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: DropdownButtonFormField(
                                        value: 'none',
                                        items: _listPropertiesUnits.map(
                                          (String dropDownStringItem) {
                                            return DropdownMenuItem(
                                              value: dropDownStringItem,
                                              child: Text(dropDownStringItem),
                                            );
                                          },
                                        ).toList(),
                                        onChanged:
                                            (String newPropertySelected) {
                                          setState(() {
                                            _currentPropertySelected =
                                                newPropertySelected;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        'Agent',
                                        style: kFieldHeading,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: DropdownButtonFormField(
                                        value: 'none',
                                        items: _listPropertiesUnits.map(
                                          (String dropDownStringItem) {
                                            return DropdownMenuItem(
                                              value: dropDownStringItem,
                                              child: Text(dropDownStringItem),
                                            );
                                          },
                                        ).toList(),
                                        onChanged:
                                            (String newPropertySelected) {
                                          setState(() {
                                            _currentPropertySelected =
                                                newPropertySelected;
                                            print(_currentPropertySelected);
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        'Document',
                                        style: kFieldHeading,
                                        softWrap: false,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: DropdownButtonFormField(
                                        value: 'none',
                                        items: _listPropertiesUnits.map(
                                          (String dropDownStringItem) {
                                            return DropdownMenuItem(
                                              value: dropDownStringItem,
                                              child: Text(dropDownStringItem),
                                            );
                                          },
                                        ).toList(),
                                        onChanged:
                                            (String newPropertySelected) {
                                          setState(
                                            () {
                                              _currentPropertySelected =
                                                  newPropertySelected;
                                              print(_currentPropertySelected);
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                _displayTaskArchiveField(context),
                                SizedBox(
                                  height: 10,
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
                              child: Text('Update'),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
//                        print('edit line 149: ${widget.tasksDetails.taskID}');
                                  await DatabaseServices().updateUserTask(
                                    widget.tasksDetails.taskID,
                                    user.userUid,
                                    _currentTaskTitle ?? tasksDetails.taskTitle,
                                    _currentTaskDetail ??
                                        tasksDetails.taskDetail,
                                    _currentTaskArchived ??
                                        tasksDetails.taskArchived,
                                    _currentTaskImportance ??
                                        tasksDetails.taskImportance,
                                    _currentTaskDueDateTime ??
                                        tasksDetails.taskDueDateTime.toDate(),
                                    _currentPropertySelected ??
                                        tasksDetails.taskUnitUid,
                                    _currentTenantSelected ??
                                        tasksDetails.taskTenantUid,
                                    Timestamp.now(),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  });
            });
      },
    );
  }

  _displayTaskTitleField(TaskDetails tasksDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      initialValue: tasksDetails.taskTitle,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Short Title',
          labelStyle: kFieldHeading,
          hintText: 'short title'),
      validator: (val) =>
          val.isEmpty ? 'Please enter a brief task description' : null,
      onChanged: (val) => setState(() => _currentTaskTitle = val),
    );
  }

  _displayTaskDetailsField(TaskDetails tasksDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      initialValue: tasksDetails.taskDetail,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Details',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
      validator: (val) => val.isEmpty ? 'Please enter task details' : null,
      onChanged: (val) => setState(() => _currentTaskDetail = val),
    );
  }

  _displayTaskImportanceField(TaskDetails tasksDetails) {
    return Row(
      children: <Widget>[
        Text(
          'Importance',
          style: kFieldHeading,
        ),
        Slider(
          label: _currentTaskImportance.toString(),
          divisions: 9,
          min: 1,
          max: 10,
          value: (_currentTaskImportance ?? tasksDetails.taskImportance)
              .toDouble(),
          onChanged: (val) =>
              setState(() => _currentTaskImportance = val.round()),
        )
      ],
    );
  }

  _displayTaskPropertyField(User user, TaskDetails tasksDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Text(
            'Property',
            style: kFieldHeading,
          ),
        ),
        SizedBox(
          width: 30,
        ),
        Flexible(
          flex: 3,
          child: StreamBuilder<List<UnitDetails>>(
            stream: DatabaseServices(uid: user.userUid).allUnitsForUser,
            builder: (context, allUserUnits) {
              if (!allUserUnits.hasData)
                return Loading();
              else {
                _propertyUnitNames['none'] = 'none';
                for (int i = 0; i < allUserUnits.data.length; i++) {
                  _propertyUnitNames[allUserUnits.data[i].unitUid] =
                      '${_mapProperties['${allUserUnits.data[i].propertyUid}']} - ${allUserUnits.data[i].unitName}';
                  // TODO is this a good way to fudge a SQL like join?
                  //  getting property name and unit names into one map from Firestore
                  // ie ('unitUid', 'George St - RHS front warehouse')
//                                  print(
//                                      'unit name: ${allUserUnits.data[i].unitName}');
//                                  print(
//                                      'property Uid: ${allUserUnits.data[i].propertyUid}');
//                                  print(
//                                      'property name: ${mapProperties['${allUserUnits.data[i].propertyUid}']}');
                }
              }
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentPropertySelected ?? tasksDetails.taskUnitUid,
                items: _propertyUnitNames
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
                onChanged: (String newPropertySelected) {
                  setState(() {
                    _currentPropertySelected = newPropertySelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }

  _displayTaskArchiveField(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Archive task?',
          style: kFieldHeading,
        ),
        SizedBox(
          width: 20,
        ),
        Checkbox(
          value: _archiveTask,
          onChanged: (value) {
            setState(() {
              _archiveTask = value;
              _currentTaskArchived = _archiveTask;
            });
          },
        ),
        SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () => kShowHelpToast(context,
              "If selected the task will be removed from your displayed tasks. These will normally be tasks which are completed. These tasks can be accessed through 'Tasks Archived"),
          child: Icon(
            Icons.help_outline,
            color: kColorOrange,
          ),
        ),
      ],
    );
  }
}

List<String> _listPropertiesUnits = [
  'none',
  'Rosebank - unit A',
  'Rosebank - Unit B',
  'St George - Unit A',
  'St George - unit B',
];
