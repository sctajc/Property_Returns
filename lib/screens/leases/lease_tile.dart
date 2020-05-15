import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/lease_details.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/screens/contacts/edit_company.dart';
import 'package:property_returns/screens/properties/edit_unit.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_lease.dart';

class LeaseTile extends StatefulWidget {
  final LeaseDetails leaseDetails;

  LeaseTile({this.leaseDetails});

  @override
  _LeaseTileState createState() => _LeaseTileState();
}

class _LeaseTileState extends State<LeaseTile> {
  String _leaseTenantName = '';
  String _leaseUnitPropertyUid = '';
  String _leaseUnitName = '';
  String _leasePropertyName = '';
  String _leasePropertyUnitName = '';

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection("companies")
        .document(widget.leaseDetails.tenantUid)
        .snapshots()
        .listen((snapshot) {
      _leaseTenantName = snapshot.data['companyName'];
    });

    Firestore.instance
        .collection("units")
        .document(widget.leaseDetails.unitUid)
        .snapshots()
        .listen((snapshot) {
      _leaseUnitName = snapshot.data['unitName'];
      _leaseUnitPropertyUid = snapshot.data['propertyUid'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<PropertyDetails>(
        stream: DatabaseServices(propertyUid: _leaseUnitPropertyUid)
            .propertyByDocumentID,
        builder: (context, userCompany) {
          if (!userCompany.hasData) return Loading();
          _leasePropertyName = userCompany.data.propertyName;
          _leasePropertyUnitName = '$_leasePropertyName - $_leaseUnitName';
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(2),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            showTenantButton(context),
                            SizedBox(
                              height: 10,
                            ),
                            showPropertyButton(context),
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        showEditLeaseButton(context),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        showLeaseEventList(user),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 260,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                            child: Text(
                              widget.leaseDetails.leaseComment,
                              maxLines: 4,
                            ),
                          ),
                        ),
                        showAddLeaseEventButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  showLeaseEventList(User user) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.blue),
        ),
        child: Column(
          children: <Widget>[
            StreamBuilder<List<LeaseEventDetails>>(
              stream: DatabaseServices(
                      uid: user.userUid, leaseUid: widget.leaseDetails.leaseUid)
                  .userLeaseEventsForLease,
              builder: (context, allLeaseEvents) {
                if (!allLeaseEvents.hasData) return const Text('Loading');
                if (allLeaseEvents.data.length > 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      child: Container(
                        height: allLeaseEvents.data.length.ceilToDouble() > 4
                            ? 100
                            : 70,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemExtent: 20,
                          itemCount: allLeaseEvents.data.length,
                          itemBuilder: (context, index) {
                            Color _color =
                                allLeaseEvents.data[index].leaseEventHappened
                                    ? Colors.grey[50]
                                    : Colors.green[50];
                            Text _leaseEventDate = Text(
                              DateFormat('E, LLL d, y').format(allLeaseEvents
                                  .data[index].leaseEventDate
                                  .toDate()),
                              style: TextStyle(
                                fontSize: 15,
                                color: allLeaseEvents
                                        .data[index].leaseEventHappened
                                    ? Colors.grey[600]
                                    : Colors.green[900],
                              ),
                            );

                            return StreamBuilder<LeaseEventTypeDetails>(
                                stream: DatabaseServices(
                                        leaseEventTypeUid: allLeaseEvents
                                            .data[index].leaseEventType)
                                    .leaseEventTypeByDocumentID,
                                builder:
                                    (context, leaseEventTypeForLeaseEvent) {
                                  if (!leaseEventTypeForLeaseEvent.hasData)
                                    return const Text('Loading');
                                  String _leaseEventTypeName =
                                      leaseEventTypeForLeaseEvent
                                          .data.leaseEventTypeName;
                                  return GestureDetector(
                                    child: Container(
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
                                            child: Center(
                                              child: _leaseEventDate,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              _leaseEventTypeName,
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Text(
                                            allLeaseEvents
                                                .data[index].leaseEventComment,
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
//                                          builder: (context) => EditLeaseEvent(
//                                            companyName:
//                                                widget.leaseDetails.tenantUid,
//                                            personUid: allCompanyPersons
//                                                .data[index].personUid,
//                                            personName: allCompanyPersons
//                                                .data[index].personName,
//                                          ),
                                            ),
                                      );
                                    },
                                  );
                                });
                          },
                        ),
                      ),
                    ),
                  );
                } else {
                  return InkWell(
                    child: Text(
                      'Add a lease Event',
                      maxLines: 1,
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
//                          builder: (context) => AddLeaseEvent(
//                            companyUid: widget.leaseDetails.tenantUid,
//                            companyName: widget.leaseDetails.companyName,
//                            defaultPersonName: 'Reception',
//                          ),
                            ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  showAddLeaseEventButton(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 0, 8),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Add event'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
//                builder: (context) => AddLeaseEvent(
//                  companyUid: widget.leaseDetails.tenantUid,
//                  companyName: widget.leaseDetails.companyName,
//                ),
                  ),
            );
          },
        ),
      ),
    );
  }

  showEditLeaseButton(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 0, 8),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Edit lease'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditLease(
                  leaseUid: widget.leaseDetails.leaseUid,
                  tenantName: _leaseTenantName,
                  propertyName: _leasePropertyUnitName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  showTenantButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey[50],
                offset: Offset(10, 10),
                blurRadius: 20,
                spreadRadius: 10)
          ],
          color: Colors.blue,
          border: Border.all(width: 0),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        width: 240,
        height: 25,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 1, 1, 1),
          child: Center(
              child: Text(
            _leaseTenantName, //widget.leaseDetails.tenantUid, //Name,
            maxLines: 1,
          )),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCompany(
              companyUid: widget.leaseDetails.tenantUid,
              companyName: _leaseTenantName,
            ),
          ),
        );
      },
    );
  }

  showPropertyButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey[50],
                offset: Offset(10, 10),
                blurRadius: 20,
                spreadRadius: 10)
          ],
          color: Colors.blue,
          border: Border.all(width: 0),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        width: 240,
        height: 25,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 1, 1, 1),
          child: Center(
              child: Text(
            _leasePropertyUnitName,
            maxLines: 1,
          )),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditUnit(
              unitUid: widget.leaseDetails.unitUid,
              propertyName: _leasePropertyName,
              unitName: _leaseUnitName,
            ),
          ),
        );
      },
    );
  }
}
