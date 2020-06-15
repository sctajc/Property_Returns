import 'package:flutter/material.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:property_returns/screens/leases/lease_tile.dart';
import 'package:property_returns/models/lease_details.dart';
import 'package:property_returns/screens/leases/add_lease.dart';

class LeaseList extends StatefulWidget {
  static String id = 'lease_list_screen';
  final String userUid;
  final String userName;

  LeaseList({this.userUid, this.userName});

  @override
  _LeaseListState createState() => _LeaseListState();
}

class _LeaseListState extends State<LeaseList> {
  bool _userHasTenants = false;
  String _userHasNoTenantsText = '';
  bool _userHasProperties = false;
  String _userHasNoPropertiesText = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    // TODO is this a good approach??
    // Used <List<TasksDetails> StreamBuilder here as own list order
    return StreamBuilder<List<PropertyDetails>>(
        stream: DatabaseServices(uid: user.userUid).userProperties,
        builder: (context, allUserProperties) {
          if (allUserProperties.hasData) _userHasProperties = true;
          _userHasProperties
              ? _userHasNoPropertiesText = ''
              : _userHasNoPropertiesText =
                  "You must enter at least one property before creating a lease";
          return StreamBuilder<List<CompanyDetails>>(
              stream: DatabaseServices(uid: user.userUid).userTenants,
              builder: (context, allUserTenants) {
                if (allUserTenants.hasData) _userHasTenants = true;
                _userHasTenants
                    ? _userHasNoTenantsText = ''
                    : _userHasNoTenantsText =
                        "You must enter at least one tenant before creating a lease";
                return StreamBuilder<List<LeaseDetails>>(
                    stream: DatabaseServices(uid: user.userUid).userLeases,
                    builder: (context, allUserLeases) {
                      if (!allUserLeases.hasData) return Loading();
                      return Scaffold(
                        appBar: AppBar(
                          title: Text('Leases'),
                          actions: <Widget>[
                            FlatButton.icon(
                              onPressed: () => null,
                              icon: Icon(Icons.search),
                              label: Text(''),
                            ),
                            showLeaseAppBarHelp(context),
                          ],
                        ),
                        body: Container(
                          child: allUserLeases.data.length > 0
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: allUserLeases.data.length,
                                  itemBuilder: (context, index) {
                                    return LeaseTile(
                                        leaseDetails:
                                            allUserLeases.data[index]);
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 30),
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Leases are between ",
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              TextSpan(
                                                  text: widget.userName
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                text:
                                                    " and Tenants (as selected in Contacts). "
                                                    "Either you have not entered any leases or they have been archived. "
                                                    "Use the 'plus' button below right to add leases. "
                                                    "If you wish to revisit leases which have been archived go back to main menu and select 'Leases archived'.",
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _userHasNoTenantsText,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        _userHasNoPropertiesText,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      SizedBox(
                                        height: 40,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        floatingActionButton: FloatingActionButton(
                          child: Icon(
                            Icons.add,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, AddLease.id),
                        ),
                      );
                    });
              });
        });
  }

  showLeaseAppBarHelp(BuildContext context) {
    return FlatButton.icon(
      onPressed: () => kShowHelpToast(
          context,
          // TODO should be able to display icons here??
          'A lease between ${widget.userName.toUpperCase()} and a tenant (as established in contacts).  '
          ' A green date means has not yet happened. A grey date means has happened. '
          'a red date means has not happened but date has passed.'),
      icon: Icon(Icons.help),
      label: Text('Help'),
    );
  }
}
