import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/company_details.dart';

class AddTask extends StatefulWidget {
  static String id = 'add_task_screen';

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _taskTitleFocusNode = FocusNode();
  final FocusNode _taskDetailsFocusNode = FocusNode();

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
  int _currentTaskImportance = 5;
  DateTime _currentTaskDueDateTime = DateTime.now().add(Duration(days: 14));
  String _currentTaskPropertySelected = 'none';
  String _currentTaskTenantSelected = 'none';
  String _currentTaskTradeSelected = 'none';
  String _currentTaskAgentSelected = 'none';

  bool _currentTaskArchived = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<List<PropertyDetails>>(
      stream: DatabaseServices(uid: user.userUid).userProperties,
      builder: (context, userProperties) {
        if (!userProperties.hasData) return Loading();
        for (PropertyDetails userProperty in userProperties.data) {
          _mapProperties[userProperty.propertyUid] = userProperty.propertyName;
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
                        stream: DatabaseServices(uid: user.userUid).userAgents,
                        builder: (context, userAgents) {
                          if (!userAgents.hasData) return Loading();
                          for (CompanyDetails userAgent in userAgents.data) {
                            _mapAgentCompanies[userAgent.companyUid] =
                                userAgent.companyName;
                          }
                          return Scaffold(
                            resizeToAvoidBottomPadding: false,
                            appBar: _buildAppBar(),
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
                                      _displayTaskTitle(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      _displayTaskDetails(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      _displayTaskImportance(),
                                      // date task due
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Due',
                                            style: kFieldHeading,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            padding: EdgeInsets.all(10),
                                            child: SizedBox(
                                              width: 250,
                                              child: DateTimeField(
                                                initialValue: DateTime.now()
                                                    .add(Duration(days: 14)),
                                                validator: (val) => val == null
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
                                                              DateTime.now()
                                                                  .add(Duration(
                                                                      days:
                                                                          14)),
                                                          firstDate:
                                                              DateTime(2000),
                                                          lastDate:
                                                              DateTime(2100));
                                                  if (date != null) {
                                                    final time =
                                                        await showTimePicker(
                                                            context: context,
                                                            initialTime: TimeOfDay
                                                                .fromDateTime(
                                                              DateTime.now(),
                                                            ),
                                                            builder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child) {
                                                              return MediaQuery(
                                                                data: MediaQuery.of(
                                                                        context)
                                                                    .copyWith(
                                                                        alwaysUse24HourFormat:
                                                                            true),
                                                                child: child,
                                                              );
                                                            });
                                                    _currentTaskDueDateTime =
                                                        DateTimeField.combine(
                                                            date, time);
                                                    return DateTimeField
                                                        .combine(date, time);
                                                  } else {
                                                    return DateTime.now().add(
                                                        Duration(days: 14));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      _displayTaskProperty(user),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      _displayTaskTenant(user),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      _displayTaskTrade(user),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      _displayTaskAgent(user),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            bottomNavigationBar: BottomAppBar(
                              child: AddButtonAndSave(
                                  formKey: _formKey,
                                  user: user,
                                  currentTaskTitle: _currentTaskTitle,
                                  currentTaskDetail: _currentTaskDetail,
                                  currentTaskArchived: _currentTaskArchived,
                                  currentTaskImportance: _currentTaskImportance,
                                  currentTaskPropertySelected:
                                      _currentTaskPropertySelected,
                                  currentTaskTenantSelected:
                                      _currentTaskTenantSelected,
                                  currentTaskTradeSelected:
                                      _currentTaskTradeSelected,
                                  currentTaskAgentSelected:
                                      _currentTaskAgentSelected,
                                  currentTaskDueDateTime:
                                      _currentTaskDueDateTime),
                            ),
                          );
                        });
                  });
            });
      },
    );
  }

  _buildAppBar() {
    return AppBar(
      title: Text(
        'Add a new task',
      ),
      actions: <Widget>[
        FlatButton.icon(
          onPressed: () => kShowHelpToast(
              context,
              'The default Due Date is two weeks from now. '
              ' Slide Importance to the right if very important. '
              'Both a Title & Details must be entered. '
              ' Will show Property, Tenants etc only if they have been set up.'),
          icon: Icon(Icons.help),
          label: Text('Help'),
        )
      ],
    );
  }

  _displayTaskTitle() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _taskTitleFocusNode,
      textCapitalization: TextCapitalization.sentences,
      decoration: kTextInputDecoration.copyWith(
          hintText: 'short title',
          labelStyle: kFieldHeading,
          labelText: 'Title'),
      validator: (val) =>
          val.isEmpty ? 'Please enter a very brief description' : null,
      onChanged: (val) => setState(() => _currentTaskTitle = val),
      onEditingComplete: _taskTitleEditingComplete,
    );
  }

  void _taskTitleEditingComplete() {
    FocusScope.of(context).requestFocus(_taskDetailsFocusNode);
  }

  _displayTaskDetails() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      focusNode: _taskDetailsFocusNode,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      decoration: kTextInputDecoration.copyWith(
          hintText: 'more details',
          labelStyle: kFieldHeading,
          labelText: 'Details'),
      validator: (val) => val.isEmpty ? 'Please enter more details' : null,
      onChanged: (val) => setState(() => _currentTaskDetail = val),
    );
  }

  _displayTaskImportance() {
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
          value: (_currentTaskImportance ?? 5).toDouble(),
          onChanged: (val) => setState(
            () => _currentTaskImportance = val.round(),
          ),
        ),
      ],
    );
  }

  _displayTaskProperty(User user) {
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
                }
              }
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentTaskPropertySelected,
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
                    _currentTaskPropertySelected = newPropertySelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }

  _displayTaskTenant(User user) {
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
                }
              }
              Map _sortedTenantCompanyPersonNames = Map.fromEntries(
                  _tenantCompanyPersonNames.entries.toList()
                    ..sort((e1, e2) => e1.value.compareTo(e2.value)));
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentTaskTenantSelected,
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
                    _currentTaskTenantSelected = newTenantSelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }

  _displayTaskAgent(User user) {
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
                }
              }
              Map _sortedAgentCompanyPersonNames = Map.fromEntries(
                  _agentCompanyPersonNames.entries.toList()
                    ..sort((e1, e2) => e1.value.compareTo(e2.value)));
              print(
                  '_tradeCompanyPersonNames: $_sortedAgentCompanyPersonNames');
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentTaskAgentSelected,
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
                    _currentTaskAgentSelected = newAgentSelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }

  _displayTaskTrade(User user) {
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
                }
              }
              Map _sortedTradeCompanyPersonNames = Map.fromEntries(
                  _tradeCompanyPersonNames.entries.toList()
                    ..sort((e1, e2) => e1.value.compareTo(e2.value)));
              print(
                  '_tradeCompanyPersonNames: $_sortedTradeCompanyPersonNames');
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentTaskTradeSelected,
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
                    _currentTaskTradeSelected = newTradeSelected;
                  });
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class AddButtonAndSave extends StatelessWidget {
  const AddButtonAndSave({
    Key key,
    @required GlobalKey<FormState> formKey,
    @required this.user,
    @required String currentTaskTitle,
    @required String currentTaskDetail,
    @required bool currentTaskArchived,
    @required int currentTaskImportance,
    @required String currentTaskPropertySelected,
    @required String currentTaskTenantSelected,
    @required String currentTaskTradeSelected,
    @required String currentTaskAgentSelected,
    @required DateTime currentTaskDueDateTime,
  })  : _formKey = formKey,
        _currentTaskTitle = currentTaskTitle,
        _currentTaskDetail = currentTaskDetail,
        _currentTaskArchived = currentTaskArchived,
        _currentTaskImportance = currentTaskImportance,
        _currentTaskPropertySelected = currentTaskPropertySelected,
        _currentTaskTenantSelected = currentTaskTenantSelected,
        _currentTaskTradeSelected = currentTaskTradeSelected,
        _currentTaskAgentSelected = currentTaskAgentSelected,
        _currentTaskDueDateTime = currentTaskDueDateTime,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final User user;
  final String _currentTaskTitle;
  final String _currentTaskDetail;
  final bool _currentTaskArchived;
  final int _currentTaskImportance;
  final String _currentTaskPropertySelected;
  final String _currentTaskTenantSelected;
  final String _currentTaskTradeSelected;
  final String _currentTaskAgentSelected;
  final DateTime _currentTaskDueDateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text('Add'),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              await DatabaseServices().addUserTask(
                user.userUid,
                _currentTaskTitle,
                _currentTaskDetail,
                _currentTaskArchived,
                _currentTaskImportance,
                _currentTaskPropertySelected,
                _currentTaskTenantSelected,
                _currentTaskTradeSelected,
                _currentTaskAgentSelected,
                _currentTaskDueDateTime,
                Timestamp.now(), //_currentEditedDateTime,
              );
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }
}
