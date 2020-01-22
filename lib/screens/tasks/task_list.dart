import 'package:flutter/material.dart';
import 'package:property_returns/screens/tasks/add_task.dart';
import 'package:property_returns/services/database.dart';
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
//    final userData = Provider.of<UserData>(context);
//    final userTasks = Provider.of<List<TasksDetails>>(context);

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

    void _showAddTaskPanel() {
      showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (context) {
          return AddTask();
        },
      );
    }

    // Used <List<TasksDetails> StreamBuilder here as own list order
    // also not StreamProvider as only used here
    // TODO is this a good approach??
    return StreamBuilder<List<TasksDetails>>(
      stream: _databaseServicesDisplayOrder,
      builder: (context, allUserTasks) {
        if (allUserTasks.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Tasks'),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () => null,
                    icon: Icon(Icons.search),
                    label: Text('Search')),
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

//                        _displayOrder = DisplayOrder.dueDateLast;
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
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allUserTasks.data.length,
                itemBuilder: (context, index) {
                  return TaskTile(taskDetails: allUserTasks.data[index]);
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
              ),
              onPressed: () {
                _showAddTaskPanel();
              },
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
