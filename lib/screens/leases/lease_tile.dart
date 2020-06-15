import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/lease_details.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/screens/contacts/edit_company.dart';
import 'package:property_returns/screens/properties/edit_unit.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'add_lease_event.dart';
import 'edit_lease.dart';
import 'edit_lease_event.dart';
import 'package:property_returns/models/company_details.dart';

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
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<CompanyDetails>(
        stream: DatabaseServices(companyUid: widget.leaseDetails.tenantUid)
            .companyByDocumentID,
        builder: (context, userTenant) {
          if (!userTenant.hasData) return Loading();
          _leaseTenantName = userTenant.data.companyName;
          return StreamBuilder<UnitDetails>(
              stream: DatabaseServices(unitUid: widget.leaseDetails.unitUid)
                  .unitByDocumentID,
              builder: (context, userUnit) {
                if (!userUnit.hasData) return Loading();
                _leaseUnitName = userUnit.data.unitName;
                _leaseUnitPropertyUid = userUnit.data.propertyUid;
                return StreamBuilder<PropertyDetails>(
                    stream: DatabaseServices(propertyUid: _leaseUnitPropertyUid)
                        .propertyByDocumentID,
                    builder: (context, userCompany) {
                      if (!userCompany.hasData) return Loading();
                      _leasePropertyName = userCompany.data.propertyName;
                      _leasePropertyUnitName =
                          '$_leasePropertyName - $_leaseUnitName';
                      {
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.all(2),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 260,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 0, 8),
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
                      }
                    });
              });
        });
  }

  showLeaseEventList(User user) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: kColorCardChildren,
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
                    padding: const EdgeInsets.all(8),
                    child: Scrollbar(
                      child: Container(
                        height: allLeaseEvents.data.length.ceilToDouble() > 4
                            ? 120
                            : 90,
                        child: ListView.builder(
                          itemExtent: 28,
                          itemCount: allLeaseEvents.data.length,
                          itemBuilder: (context, index) {
                            Color _textColor =
                                allLeaseEvents.data[index].leaseEventHappened
                                    ? Colors.grey[600]
                                    : Colors.green[900];
                            if (allLeaseEvents.data[index].leaseEventHappened ==
                                    false &&
                                allLeaseEvents.data[index].leaseEventDate
                                    .toDate()
                                    .isBefore(DateTime.now())) {
                              _textColor = Colors.red[900];
                            }
                            Color _buttonColor =
                                allLeaseEvents.data[index].leaseEventHappened
                                    ? Colors.grey[50]
                                    : Colors.green[50];
                            if (allLeaseEvents.data[index].leaseEventHappened ==
                                    false &&
                                allLeaseEvents.data[index].leaseEventDate
                                    .toDate()
                                    .isBefore(DateTime.now())) {
                              _buttonColor = Colors.red[50];
                            }
                            Text _leaseEventDate = Text(
                              DateFormat('E, LLL d, y').format(allLeaseEvents
                                  .data[index].leaseEventDate
                                  .toDate()),
                              style: TextStyle(
                                fontSize: 15,
                                color: _textColor,
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
                                    return Loading(); //const Text('Loading');
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
                                              color: _buttonColor,
                                              border: Border.all(width: 0),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(3),
                                              ),
                                            ),
                                            width: 140,
                                            height: 20,
                                            child: Center(
                                              child: _leaseEventDate,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _leaseEventTypeName,
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                allLeaseEvents.data[index]
                                                    .leaseEventComment,
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
                                          builder: (context) => EditLeaseEvent(
                                            leaseEventUid: allLeaseEvents
                                                .data[index].leaseEventUid,
                                            tenantName: _leaseTenantName,
                                            propertyName:
                                                _leasePropertyUnitName,
                                          ),
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
                          builder: (context) => AddLeaseEvent(
                            leaseUid: widget.leaseDetails.leaseUid,
                            leaseTenantName: _leaseTenantName,
                            leasePropertyName: _leasePropertyUnitName,
                          ),
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
                builder: (context) => AddLeaseEvent(
                  leaseUid: widget.leaseDetails.leaseUid,
                  leaseTenantName: _leaseTenantName,
                  leasePropertyName: _leasePropertyUnitName,
                ),
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
