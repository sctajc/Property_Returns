import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/models/lease_details.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/screens/leases/edit_lease_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/loading.dart';

class LeaseEventTile extends StatelessWidget {
  final LeaseEventDetails leaseEventDetails;

  LeaseEventTile({this.leaseEventDetails});

  @override
  Widget build(BuildContext context) {
    String _tenantName;
    String _unitName;
    String _propertyName;

    Color _textColor = leaseEventDetails.leaseEventHappened
        ? Colors.grey[600]
        : Colors.green[900];
    if (leaseEventDetails.leaseEventHappened == false &&
        leaseEventDetails.leaseEventDate.toDate().isBefore(DateTime.now())) {
      _textColor = Colors.red[900];
    }
    Color _buttonColor = leaseEventDetails.leaseEventHappened
        ? Colors.grey[50]
        : Colors.green[50];
    if (leaseEventDetails.leaseEventHappened == false &&
        leaseEventDetails.leaseEventDate.toDate().isBefore(DateTime.now())) {
      _buttonColor = Colors.red[50];
    }
    Text _leaseEventDate = Text(
      DateFormat('E, LLL d, y')
          .format(leaseEventDetails.leaseEventDate.toDate()),
      style: TextStyle(
        fontSize: 15,
        color: _textColor,
      ),
    );

    return GestureDetector(
      //TODO using MaterialPageRoute - is it possible to use 'routes' as defined in main.dart
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditLeaseEvent(
            leaseEventUid: leaseEventDetails.leaseEventUid,
            tenantName: _tenantName,
            propertyName: _propertyName,
          ),
        ),
      ),
      child: StreamBuilder<LeaseEventTypeDetails>(
        stream: DatabaseServices(
                leaseEventTypeUid: leaseEventDetails.leaseEventType)
            .leaseEventTypeByDocumentID,
        builder: (context, leaseEventTypeForLeaseEvent) {
          if (!leaseEventTypeForLeaseEvent.hasData) return Loading();
          String _leaseEventTypeName =
              leaseEventTypeForLeaseEvent.data.leaseEventTypeName;
          return StreamBuilder<LeaseDetails>(
              stream: DatabaseServices(leaseUid: leaseEventDetails.leaseUid)
                  .leaseByDocumentID,
              builder: (context, lease) {
                if (!lease.hasData) return Loading();
                return StreamBuilder<CompanyDetails>(
                    stream: DatabaseServices(companyUid: lease.data.tenantUid)
                        .companyByDocumentID,
                    builder: (context, tenant) {
                      if (!tenant.hasData) return Loading();
                      _tenantName = tenant.data.companyName;
                      return StreamBuilder<UnitDetails>(
                          stream: DatabaseServices(unitUid: lease.data.unitUid)
                              .unitByDocumentID,
                          builder: (context, unit) {
                            if (!unit.hasData) return Loading();
                            _unitName = unit.data.unitName;
                            return StreamBuilder<PropertyDetails>(
                                stream: DatabaseServices(
                                        propertyUid: unit.data.propertyUid)
                                    .propertyByDocumentID,
                                builder: (context, property) {
                                  if (!property.hasData) return Loading();
                                  _propertyName =
                                      '$_unitName - ${property.data.propertyName}';
                                  return Container(
                                    child: Column(
                                      children: <Widget>[
                                        Row(
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
                                              width: 150,
                                              height: 25,
                                              child: Center(
                                                  child: _leaseEventDate),
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
                                          ],
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                '$_tenantName @ $_propertyName',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        leaseEventDetails
                                                    .leaseEventComment.length >
                                                1
                                            ? Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      leaseEventDetails
                                                          .leaseEventComment,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          });
                    });
              });
        },
      ),
    );
  }
}
