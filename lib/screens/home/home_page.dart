import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/lease_details.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/screens/leases/lease_event_tile.dart';
import 'package:property_returns/screens/tasks/add_task.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/screens/tasks/task_tile.dart';
import 'package:property_returns/shared/loading.dart';

class HomePage extends StatelessWidget {
  final int numberOfUserTaskToDisplay = 4;
  final int numberOfUserLeaseEventsToDisplay = 4;

  @override
  Widget build(BuildContext context) {
    final userTasks = Provider.of<List<TaskDetails>>(context);
    final userLeaseEvents = Provider.of<List<LeaseEventDetails>>(context);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    double screenTextScaleFactor = MediaQuery.of(context).textScaleFactor;
    double _heightOfScreen = MediaQuery.of(context).size.height;
    double _heightOfTaskScrollBox;
    double _heightOfLeaseEventsScrollBox;
    // small(.85) = 245 dpi
    // default(1) = 240
    // large (1.15) = 240
    // largest 1.3) = 220
    if (screenTextScaleFactor > 0.84) {
      _heightOfTaskScrollBox = 245;
      _heightOfLeaseEventsScrollBox =
          _heightOfScreen - _heightOfTaskScrollBox - 190;
    }
    if (screenTextScaleFactor > 0.99) {
      _heightOfTaskScrollBox = 240;
      _heightOfLeaseEventsScrollBox =
          _heightOfScreen - _heightOfTaskScrollBox - 200;
    }
    if (screenTextScaleFactor > 1.14) {
      _heightOfTaskScrollBox = 241;
      _heightOfLeaseEventsScrollBox =
          _heightOfScreen - _heightOfTaskScrollBox - 210;
    }
    if (screenTextScaleFactor > 1.29) {
      _heightOfTaskScrollBox = 220;
      _heightOfLeaseEventsScrollBox =
          _heightOfScreen - _heightOfTaskScrollBox - 230;
    }

    if (userTasks == null) return Loading();
    if (userLeaseEvents == null) return Loading();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Upcoming Important Tasks',
            style: kHeading,
          ),
          userTasks.length < 1
              ? Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            child: Text(
                              'You have no outstanding tasks',
                              style: TextStyle(fontSize: 20),
                            ),
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
                          RaisedButton(
                              child: Text(
                                'Add a task',
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, AddTask.id))
                        ],
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kColorCardChildren,
                      border: Border.all(width: 1, color: Colors.blue),
                    ),
                    height: _heightOfTaskScrollBox,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: userTasks.length,
                        itemBuilder: (context, index) {
                          return TaskTile(taskDetails: userTasks[index]);
                        },
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Upcoming Lease Events',
            style: kHeading,
          ),
          userLeaseEvents.length < 1
              ? Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            child: Text(
                              'You have no upcoming lease events. A lease event is a date related thing '
                              'on a lease. Examples are commencement date, rent reviews, lease renewals, '
                              'final expiry date. ',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.help_outline,
                              color: kColorOrange,
                            ),
                            onTap: () => kShowHelpToast(
                                context,
                                "Either you have not entered any leases, any lease events (eg rent review dates)"
                                " or your lease events have all happened"),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                        color: kColorCardChildren,
                        border: Border.all(width: 1, color: Colors.blue)),
                    height: _heightOfLeaseEventsScrollBox,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: userLeaseEvents.length,
                        itemBuilder: (context, index) {
                          return LeaseEventTile(
                              leaseEventDetails: userLeaseEvents[index]);
                        },
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
