import 'package:flutter/material.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/screens/tasks/task_tile.dart';
import 'package:property_returns/shared/loading.dart';

class HomePage extends StatelessWidget {
  final int numberOfUserTaskToDisplay = 8;
  @override
  Widget build(BuildContext context) {
    final userTasks = Provider.of<List<TaskDetails>>(context);
    if (userTasks == null) return Loading();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Upcoming Important Tasks',
          style: kHeading,
        ),
        SizedBox(
          height: 0,
        ),
        Row(
          children: <Widget>[
            userTasks.length > 0
                ? Text(
                    'Due',
                    textAlign: TextAlign.left,
                    style: kHeading.copyWith(
                      fontSize: 18,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'You have no outstanding tasks',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.help_outline,
                            color: kColorOrange,
                          ),
                          onTap: () => kShowHelpToast(context,
                              "Either you have not entered any tasks or all your tasks have been archived"),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: userTasks.length > numberOfUserTaskToDisplay
              ? numberOfUserTaskToDisplay
              : userTasks.length,
          itemBuilder: (context, index) {
            return TaskTile(taskDetails: userTasks[index]);
          },
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Upcoming Lease Events',
          style: kHeading,
        ),
        SizedBox(
          height: 20,
        ),
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 8),
          children: <Widget>[
            Container(
                height: 20,
                child: Text('12/02/2020 - New roof should be checked')),
            Container(height: 20, child: Text('15/01/2020 - Check rates paid')),
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
