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

  final TasksDetails tasksDetails;

  EditTask({this.tasksDetails});

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  bool archiveTask = false;
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentTitle;
  String _currentDetail;
  int _currentImportance;
  DateTime _currentDueDateTime;
  bool _currentArchived = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final taskID = widget.tasksDetails.taskID;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: StreamBuilder<TasksDetails>(
        stream: DatabaseServices(uid: user.userUid, taskID: taskID)
            .taskByDocumentID,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            TasksDetails tasksDetails = snapshot.data;

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
                          decoration: textInputDecoration.copyWith(
                              hintText: 'short title'),
                          validator: (val) => val.isEmpty
                              ? 'Please enter a brief task description'
                              : null,
                          onChanged: (val) =>
                              setState(() => _currentTitle = val),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          initialValue: tasksDetails.taskDetail,
                          decoration: textInputDecoration.copyWith(
                              hintText: 'more details'),
                          validator: (val) =>
                              val.isEmpty ? 'Please enter task details' : null,
                          onChanged: (val) =>
                              setState(() => _currentDetail = val),
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
                              value: (_currentImportance ??
                                      tasksDetails.taskImportance)
                                  .toDouble(),
                              onChanged: (val) => setState(
                                  () => _currentImportance = val.round()),
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
                                    _currentDueDateTime =
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
                              style: fieldHeading,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Checkbox(
                              value: archiveTask,
                              onChanged: (value) {
                                setState(() {
                                  archiveTask = value;
                                  _currentArchived = archiveTask;
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () => showHelpToast(context,
                                  "If selected the task will be removed from your displayed tasks. These will normally be tasks which are completed. These tasks can be accessed through 'Tasks Archived"),
                              child: Icon(
                                Icons.help_outline,
                                color: colorOrange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          child: Text('Save'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              print(
                                  'edit line 149: ${widget.tasksDetails.taskID}');
                              DateTime _currentEditedDateTime = DateTime.now();
                              await DatabaseServices().updateUserTask(
                                  widget.tasksDetails.taskID,
                                  user.userUid,
                                  _currentTitle ?? tasksDetails.taskTitle,
                                  _currentDetail ?? tasksDetails.taskDetail,
                                  _currentArchived ?? tasksDetails.taskArchived,
                                  _currentImportance ??
                                      tasksDetails.taskImportance,
                                  _currentDueDateTime ??
                                      tasksDetails.taskDueDateTime.toDate(),
                                  _currentEditedDateTime);
                              Navigator.pop(context);
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
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
