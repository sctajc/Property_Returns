import 'dart:ui';
import 'package:property_returns/screens/tasks/edit_task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/models/task_details.dart';

class TaskTile extends StatelessWidget {
  final TaskDetails taskDetails;
  TaskTile({this.taskDetails});

  @override
  Widget build(BuildContext context) {
    Color _color = colorTaskImportance(taskDetails.taskImportance);
    Text _textLine = Text(
      DateFormat('E, LLL d, y').format(taskDetails.taskDueDateTime.toDate()),
      style: TextStyle(
          fontSize: 15,
          backgroundColor: _color,
          color: taskDetails.taskImportance > 5 ? Colors.white : Colors.black),
    );

    return GestureDetector(
      //TODO using MaterialPageRoute - is it possible to use 'routes' as defined in main.dart
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTask(
            tasksDetails: taskDetails,
          ),
        ),
      ),
      child: Container(
        height: 30,
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey[50],
                      offset: Offset(10, 10),
                      blurRadius: 20,
                      spreadRadius: 10)
                ],
                color: _color,
                border: Border.all(width: 0),
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              width: 130,
              height: 20,
              child: Center(child: _textLine),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                taskDetails.taskTitle,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color colorTaskImportance(int importance) {
    Color _tempColor;
    switch (importance) {
      case 1:
        _tempColor = Colors.amber[50];
        break;
      case 2:
        _tempColor = Colors.amber[100];
        break;
      case 3:
        _tempColor = Colors.amber[200];
        break;
      case 4:
        _tempColor = Colors.amber[300];
        break;
      case 5:
        _tempColor = Colors.amber[400];
        break;
      case 6:
        _tempColor = Colors.amber[600];
        break;
      case 7:
        _tempColor = Colors.amber[600];
        break;
      case 8:
        _tempColor = Colors.amber[700];
        break;
        break;
      case 9:
        _tempColor = Colors.amber[800];
        break;
        break;
      case 10:
        _tempColor = Colors.amber[900];
        break;
    }
    return _tempColor;
  }
}
