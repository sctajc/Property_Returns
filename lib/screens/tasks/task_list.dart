import 'package:flutter/material.dart';
import 'package:property_returns/screens/tasks/add_task.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/screens/tasks/task_tile.dart';
import 'package:property_returns/shared/loading.dart';

enum DisplayOrder {
  dueDateFirst,
  dueDateLast,
  importanceHighest,
  importanceLowest,
}

class TaskList extends StatefulWidget {
  static String id = 'task_list_screen';

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DisplayOrder _displayOrder = DisplayOrder.dueDateFirst;
  var _databaseServicesDisplayOrder;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    switch (_displayOrder) {
      case DisplayOrder.dueDateFirst:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userTasksByDueDateEarliestFirst;
        break;
      case DisplayOrder.dueDateLast:
        _databaseServicesDisplayOrder =
            DatabaseServices(uid: user.userUid).userTasksByDueDateLatestFirst;
        break;
      case DisplayOrder.importanceHighest:
        _databaseServicesDisplayOrder = DatabaseServices(uid: user.userUid)
            .userTasksByImportanceHighestFirst;
        break;
      case DisplayOrder.importanceLowest:
        _databaseServicesDisplayOrder = DatabaseServices(uid: user.userUid)
            .userTasksByImportanceLowestFirst;
        break;
    }

    // Used <List<TasksDetails> StreamBuilder here as own list order
    // TODO is this a good approach??
    // needs to be StreamProvider but how to handle 'allUserTasks'?
    return StreamBuilder<List<TaskDetails>>(
      stream: _databaseServicesDisplayOrder,
      builder: (context, allUserTasks) {
        if (!allUserTasks.hasData) return Loading();
        return Scaffold(
          appBar: AppBar(
            title: Text('Tasks'),
//              title: Text(userProperties[1].propertyName),
            actions: <Widget>[
              FlatButton.icon(
                  onPressed: () => null,
                  icon: Icon(Icons.search),
                  label: Text('')),
              FlatButton.icon(
                  onPressed: () {
                    setState(() {
                      switch (_displayOrder) {
                        case DisplayOrder.dueDateFirst:
                          _displayOrder = DisplayOrder.dueDateLast;
                          break;
                        case DisplayOrder.dueDateLast:
                          _displayOrder = DisplayOrder.importanceHighest;
                          break;
                        case DisplayOrder.importanceHighest:
                          _displayOrder = DisplayOrder.importanceLowest;
                          break;
                        case DisplayOrder.importanceLowest:
                          _displayOrder = DisplayOrder.dueDateFirst;
                          break;
                      }
                    });
                  },
                  icon: (_displayOrder == DisplayOrder.dueDateFirst ||
                          _displayOrder == DisplayOrder.importanceHighest)
                      ? Icon(Icons.arrow_downward)
                      : Icon(Icons.arrow_upward),
                  label: (_displayOrder == DisplayOrder.dueDateFirst ||
                          _displayOrder == DisplayOrder.dueDateLast)
                      ? Text('Date')
                      : Text('Importance')),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: allUserTasks.data.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: allUserTasks.data.length,
                    itemBuilder: (context, index) {
                      return TaskTile(taskDetails: allUserTasks.data[index]);
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "Either you have not entered any tasks or all your tasks have been completed (archived). "
                            "Use the 'plus' button below right to add tasks. "
                            "If you wish to revisit tasks which have been archived go back to main menu and select 'Tasks archived' near the bottom",
                            style: TextStyle(color: kColorOrange, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.add,
            ),
            onPressed: () => Navigator.pushNamed(context, AddTask.id),
          ),
        );
      },
    );
  }
}
