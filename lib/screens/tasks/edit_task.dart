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

class EditTask extends StatefulWidget {
  static String id = 'edit_task_screen';
  final TaskDetails tasksDetails;
  EditTask({this.tasksDetails});

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  bool archiveTask = false;
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentTaskTitle;
  String _currentTaskDetail;
  int _currentTaskImportance;
  DateTime _currentTaskDueDateTime;
  bool _currentTaskArchived = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final taskID = widget.tasksDetails.taskID;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: StreamBuilder<TaskDetails>(
        stream: DatabaseServices(uid: user.userUid, taskID: taskID)
            .taskByDocumentID,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Loading();
          TaskDetails tasksDetails = snapshot.data;
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
                      TextFormField(
                        keyboardType: TextInputType.text,
                        initialValue: tasksDetails.taskTitle,
                        decoration: kTextInputDecoration.copyWith(
                            hintText: 'short title'),
                        validator: (val) => val.isEmpty
                            ? 'Please enter a brief task description'
                            : null,
                        onChanged: (val) =>
                            setState(() => _currentTaskTitle = val),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        initialValue: tasksDetails.taskDetail,
                        decoration: kTextInputDecoration.copyWith(
                            hintText: 'more details'),
                        validator: (val) =>
                            val.isEmpty ? 'Please enter task details' : null,
                        onChanged: (val) =>
                            setState(() => _currentTaskDetail = val),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Importance',
                            style: kFieldHeading,
                          ),
                          Slider(
                            divisions: 9,
                            min: 1,
                            max: 10,
                            value: (_currentTaskImportance ??
                                    tasksDetails.taskImportance)
                                .toDouble(),
                            onChanged: (val) => setState(
                                () => _currentTaskImportance = val.round()),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Due:',
                            style: kFieldHeading,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: DateTimeField(
                              validator: (val) => val == null
                                  ? 'Please enter a due date'
                                  : null,
                              format: DateFormat("E,  MMM d, y  -  HH:mm"),
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        tasksDetails.taskDueDateTime.toDate(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100));
                                if (date != null) {
                                  final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          tasksDetails.taskDueDateTime
                                              .toDate()),
                                      builder:
                                          (BuildContext context, Widget child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              alwaysUse24HourFormat: true),
                                          child: child,
                                        );
                                      });
                                  _currentTaskDueDateTime =
                                      DateTimeField.combine(date, time);
                                  return DateTimeField.combine(date, time);
                                } else {
                                  return currentValue;
                                }
                              },
                              initialValue:
                                  tasksDetails.taskDueDateTime.toDate(),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Archive task?',
                            style: kFieldHeading,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Checkbox(
                            value: archiveTask,
                            onChanged: (value) {
                              setState(() {
                                archiveTask = value;
                                _currentTaskArchived = archiveTask;
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
                      ),
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
                    child: Text('Save'),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        print('edit line 149: ${widget.tasksDetails.taskID}');
                        await DatabaseServices().updateUserTask(
                          widget.tasksDetails.taskID,
                          user.userUid,
                          _currentTaskTitle ?? tasksDetails.taskTitle,
                          _currentTaskDetail ?? tasksDetails.taskDetail,
                          _currentTaskArchived ?? tasksDetails.taskArchived,
                          _currentTaskImportance ?? tasksDetails.taskImportance,
                          _currentTaskDueDateTime ??
                              tasksDetails.taskDueDateTime.toDate(),
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
        },
      ),
    );
  }
}
