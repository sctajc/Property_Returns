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
  Map _tradeCompanyPersonNames = Map<String, String>();
  Map<String, String> _mapTradeCompanies = {'none': 'none'};
  Map _agentCompanyPersonNames = Map<String, String>();
  Map<String, String> _mapAgentCompanies = {'none': 'none'};

  // form values
  String _currentTaskTitle;
  String _currentTaskDetail;
  int _currentTaskImportance;
  DateTime _currentTaskDueDateTime;
  String _currentPropertySelected;
  String _currentTenantSelected;
  String _currentTradeSelected;
  String _currentAgentSelected;
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
                      _mapTenantCompanies[userTenant.companyUid] =
                          userTenant.companyName;
                    }
                    return StreamBuilder<List<CompanyDetails>>(
                        stream: DatabaseServices(uid: user.userUid).userTrades,
                        builder: (context, userTrades) {
                          if (!userTrades.hasData) return Loading();
                          for (CompanyDetails userTrade in userTrades.data) {
                            _mapTradeCompanies[userTrade.companyUid] =
                                userTrade.companyName;
                          }
                          return StreamBuilder<List<CompanyDetails>>(
                              stream: DatabaseServices(uid: user.userUid)
                                  .userAgents,
                              builder: (context, userAgents) {
                                if (!userAgents.hasData) return Loading();
                                for (CompanyDetails userAgent
                                    in userAgents.data) {
                                  _mapAgentCompanies[userAgent.companyUid] =
                                      userAgent.companyName;
                                }
                                return Scaffold(
                                  resizeToAvoidBottomPadding: false,
                                  appBar: _buildAppBar(),
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
                                            _displayTaskTitle(tasksDetails),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            _displayTaskDetails(tasksDetails),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            _displayTaskImportanceField(
                                                tasksDetails),
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
                                                    validator: (val) => val ==
                                                            null
                                                        ? 'Please enter a due date'
                                                        : null,
                                                    format: DateFormat(
                                                        "E,  MMM d, y  -  HH:mm"),
                                                    onShowPicker: (context,
                                                        currentValue) async {
                                                      final date =
                                                          await showDatePicker(
                                                              context: context,
                                                              initialDate:
                                                                  tasksDetails
                                                                      .taskDueDateTime
                                                                      .toDate(),
                                                              firstDate:
                                                                  DateTime
                                                                      .now(),
                                                              lastDate:
                                                                  DateTime(
                                                                      2100));
                                                      if (date != null) {
                                                        final time =
                                                            await showTimePicker(
                                                                context:
                                                                    context,
                                                                initialTime: TimeOfDay.fromDateTime(
                                                                    tasksDetails
                                                                        .taskDueDateTime
                                                                        .toDate()),
                                                                builder: (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child) {
                                                                  return MediaQuery(
                                                                    data: MediaQuery.of(
                                                                            context)
                                                                        .copyWith(
                                                                            alwaysUse24HourFormat:
                                                                                true),
                                                                    child:
                                                                        child,
                                                                  );
                                                                });
                                                        _currentTaskDueDateTime =
                                                            DateTimeField
                                                                .combine(
                                                                    date, time);
                                                        return DateTimeField
                                                            .combine(
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
                                            _displayTaskPropertyField(
                                                user, tasksDetails),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            _displayTaskTenant(
                                                user, tasksDetails),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            _displayTaskTrade(
                                                user, tasksDetails),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            _displayTaskAgent(
                                                user, tasksDetails),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        RaisedButton(
                                          child: Text('Update'),
                                          onPressed: () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              await DatabaseServices()
                                                  .updateUserTask(
                                                widget.tasksDetails.taskID,
                                                user.userUid,
                                                _currentTaskTitle ??
                                                    tasksDetails.taskTitle,
                                                _currentTaskDetail ??
                                                    tasksDetails.taskDetail,
                                                _currentTaskArchived ??
                                                    tasksDetails.taskArchived,
                                                _currentTaskImportance ??
                                                    tasksDetails.taskImportance,
                                                _currentTaskDueDateTime ??
                                                    tasksDetails.taskDueDateTime
                                                        .toDate(),
                                                _currentPropertySelected ??
                                                    tasksDetails.taskUnitUid,
                                                _currentTenantSelected ??
                                                    tasksDetails.taskTenantUid,
                                                _currentTradeSelected ??
                                                    tasksDetails.taskTradeUid,
                                                _currentAgentSelected ??
                                                    tasksDetails.taskAgentUid,
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
                  });
            });
      },
    );
  }

  _displayTaskAgent(User user, TaskDetails tasksDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          child: StreamBuilder<List<PersonDetails>>(
            stream: DatabaseServices(uid: user.userUid).allPersonsForUser,
            builder: (context, allUserPersons) {
              if (!allUserPersons.hasData)
                return Loading();
              else {
                _agentCompanyPersonNames['none'] = ' none';
                for (int i = 0; i < allUserPersons.data.length; i++) {
                  if ((_mapAgentCompanies[
                          '${allUserPersons.data[i].companyUid}']) !=
                      null) {
                    _agentCompanyPersonNames[allUserPersons.data[i].personUid] =
                        '${_mapAgentCompanies['${allUserPersons.data[i].companyUid}']} - ${allUserPersons.data[i].personName}';
                  }

                  // TODO is this a good way to fudge a SQL like join?
                  //  getting property name and unit names into one map from Firestore
                  // ie ('unitUid', 'George St - RHS front warehouse')
                }
              }
              Map _sortedAgentCompanyPersonNames = Map.fromEntries(
                  _agentCompanyPersonNames.entries.toList()
                    ..sort((e1, e2) => e1.value.compareTo(e2.value)));
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentAgentSelected ?? tasksDetails.taskAgentUid,
                items: _sortedAgentCompanyPersonNames
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
                onChanged: (String newAgentSelected) {
                  setState(() {
                    _currentAgentSelected = newAgentSelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }

  _displayTaskTrade(User user, TaskDetails tasksDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          child: StreamBuilder<List<PersonDetails>>(
            stream: DatabaseServices(uid: user.userUid).allPersonsForUser,
            builder: (context, allUserPersons) {
              if (!allUserPersons.hasData)
                return Loading();
              else {
                _tradeCompanyPersonNames['none'] = ' none';
                for (int i = 0; i < allUserPersons.data.length; i++) {
                  if ((_mapTradeCompanies[
                          '${allUserPersons.data[i].companyUid}']) !=
                      null) {
                    _tradeCompanyPersonNames[allUserPersons.data[i].personUid] =
                        '${_mapTradeCompanies['${allUserPersons.data[i].companyUid}']} - ${allUserPersons.data[i].personName}';
                  }
                  // TODO is this a good way to fudge a SQL like join?
                  //  getting property name and unit names into one map from Firestore
                  // ie ('unitUid', 'George St - RHS front warehouse')
                }
              }
              Map _sortedTradeCompanyPersonNames = Map.fromEntries(
                  _tradeCompanyPersonNames.entries.toList()
                    ..sort((e1, e2) => e1.value.compareTo(e2.value)));
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentTradeSelected ?? tasksDetails.taskTradeUid,
                items: _sortedTradeCompanyPersonNames
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
                onChanged: (String newTradeSelected) {
                  setState(() {
                    _currentTradeSelected = newTradeSelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }

  _displayTaskTenant(User user, TaskDetails tasksDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            stream: DatabaseServices(uid: user.userUid).allPersonsForUser,
            builder: (context, allUserPersons) {
              if (!allUserPersons.hasData)
                return Loading();
              else {
                _tenantCompanyPersonNames['none'] = ' none';
                for (int i = 0; i < allUserPersons.data.length; i++) {
                  if ((_mapTenantCompanies[
                          '${allUserPersons.data[i].companyUid}']) !=
                      null) {
                    _tenantCompanyPersonNames[
                            allUserPersons.data[i].personUid] =
                        '${_mapTenantCompanies['${allUserPersons.data[i].companyUid}']} - ${allUserPersons.data[i].personName}';
                  }

                  // TODO is this a good way to fudge a SQL like join?
                  //  getting property name and unit names into one map from Firestore
                  // ie ('unitUid', 'George St - RHS front warehouse')
                }
              }
              Map _sortedTenantCompanyPersonNames = Map.fromEntries(
                  _tenantCompanyPersonNames.entries.toList()
                    ..sort((e1, e2) => e1.value.compareTo(e2.value)));
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentTenantSelected ?? tasksDetails.taskTenantUid,
                items: _sortedTenantCompanyPersonNames
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
                onChanged: (String newTenantSelected) {
                  setState(() {
                    _currentTenantSelected = newTenantSelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }

  _buildAppBar() {
    return AppBar(
      title: Text(
        'Edit task',
      ),
    );
  }

  _displayTaskTitle(TaskDetails tasksDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      initialValue: tasksDetails.taskTitle,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Title',
          labelStyle: kFieldHeading,
          hintText: 'short title'),
      validator: (val) =>
          val.isEmpty ? 'Please enter a very brief description' : null,
      onChanged: (val) => setState(() => _currentTaskTitle = val),
    );
  }

  _displayTaskDetails(TaskDetails tasksDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      initialValue: tasksDetails.taskDetail,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Details',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
      validator: (val) => val.isEmpty ? 'Please enter more details' : null,
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
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Archive task?',
        style: kFieldHeading,
      ),
      value: _archiveTask,
      onChanged: (value) {
        setState(() {
          _archiveTask = value;
          _currentTaskArchived = _archiveTask;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected the task will be removed from your displayed tasks. These will normally be tasks which are completed. These tasks can be accessed through 'Tasks Archived"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }
}
