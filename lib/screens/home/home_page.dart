import 'package:flutter/material.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/screens/tasks/task_tile.dart';
import 'package:property_returns/shared/loading.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData>(context);
    final userTasks = Provider.of<List<TasksDetails>>(context);
//    userTasks.forEach(
//      (userTasks) {
////        print(userTasks.taskTitle);
////        print(userTasks.taskDueDateTime);
////        print(userTasks.taskImportance);
//      },
//    );

//    final allTasks = Provider.of<QuerySnapshot>(context);
//    for (var doc in allTasks.documents) {
//      print(doc.data);
//    }
    if (userTasks == null) {
      return Loading();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Upcoming Tasks',
            style: heading,
          ),
          SizedBox(
            height: 0,
          ),
          Row(
            children: <Widget>[
              Text(
                'Due',
                textAlign: TextAlign.left,
                style: heading.copyWith(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: userTasks.length ?? 1,
            itemBuilder: (context, index) {
              return TaskTile(taskDetails: userTasks[index]);
            },
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Upcoming Lease Events',
            style: heading,
          ),
          SizedBox(
            height: 20,
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 8),
            children: <Widget>[
              Container(
                  height: 20, child: Text('15/01/2020 - Check rates paid')),
              Container(
                  height: 20,
                  child: Text('12/02/2020 - New roof should be checked')),
              Container(
                  height: 20, child: Text('14/02/2020 - Do plumbing check')),
              Container(
                  height: 20,
                  child: Text('15/03/2020 - Consider replacing roller doors')),
              Container(
                  height: 20,
                  child: Text('18/03/2020 - Check insurance for inspection')),
              Container(
                height: 20,
                child: Text(
                    '22/03/2020 - see if old air conditing unit will do anothe year or so'),
              ),
            ],
          ),
        ],
      );
    }
  }
}
