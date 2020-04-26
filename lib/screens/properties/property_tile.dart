import 'dart:ui';
import 'package:property_returns/models/property_details.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/screens/properties/add_unit.dart';
import 'package:property_returns/screens/properties/edit_property.dart';
import 'package:property_returns/screens/properties/edit_unit.dart';
import 'package:property_returns/services/database.dart';
import 'package:provider/provider.dart';

class PropertyTile extends StatefulWidget {
  final PropertyDetails propertyDetails;

  PropertyTile({this.propertyDetails});

  @override
  _PropertyTileState createState() => _PropertyTileState();
}

class _PropertyTileState extends State<PropertyTile> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(2),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
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
                      width: 130,
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 1, 1, 1),
                        child: Center(
                            child: Text(
                          widget.propertyDetails.propertyName,
                          maxLines: 1,
                        )),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProperty(
                            propertyUid: widget.propertyDetails.propertyUid,
                            propertyName: widget.propertyDetails.propertyName,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 8),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Add a unit'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddUnit(
                              propertyUid: widget.propertyDetails.propertyUid,
                              propertyName: widget.propertyDetails.propertyName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: <Widget>[
                      StreamBuilder<List<UnitDetails>>(
                        stream: DatabaseServices(
                                uid: user.userUid,
                                propertyUid: widget.propertyDetails.propertyUid)
                            .userUnitsForProperty,
                        builder: (context, allPropertyUnits) {
                          if (!allPropertyUnits.hasData)
                            return const Text('Loading');
                          if (allPropertyUnits.data.length > 0) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Scrollbar(
                                //TODO impliment allways show scroolbar when available
                                //TODO display a wheel or something anaminated??
                                //https://github.com/flutter/flutter/issues/28836
                                child: Container(
                                  height: allPropertyUnits.data.length
                                              .ceilToDouble() >
                                          4
                                      ? 90
                                      : 50,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemExtent: 20,
                                    itemCount: allPropertyUnits.data.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                          child: Text(
                                            allPropertyUnits
                                                .data[index].unitName,
                                            maxLines: 1,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditUnit(
                                                  propertyName: widget
                                                      .propertyDetails
                                                      .propertyName,
                                                  unitUid: allPropertyUnits
                                                      .data[index].unitUid,
                                                  unitName: allPropertyUnits
                                                      .data[index].unitName,
                                                ),
                                              ),
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
                                'Details (as one unit)',
                                maxLines: 1,
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddUnit(
                                      propertyUid:
                                          widget.propertyDetails.propertyUid,
                                      propertyName:
                                          widget.propertyDetails.propertyName,
                                      defaultUnitName: 'Details (as one unit)',
                                    ),
//                                        EditUnit(
//                                      propertyName:
//                                          widget.propertyDetails.propertyName,
//                                      unitUid:
//                                          widget.propertyDetails.propertyUid,
//                                      unitName:
//                                          widget.propertyDetails.propertyName,
//                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
