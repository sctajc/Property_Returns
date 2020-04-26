import 'dart:ui';
import 'package:property_returns/models/company_details.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:provider/provider.dart';
import 'add_person.dart';
import 'edit_company.dart';
import 'edit_person.dart';

class CompanyTile extends StatefulWidget {
  final CompanyDetails companyDetails;

  CompanyTile({this.companyDetails});

  @override
  _CompanyTileState createState() => _CompanyTileState();
}

class _CompanyTileState extends State<CompanyTile> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(2),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  showCompanyButton(context),
                  IconButton(icon: Icon(Icons.phone), onPressed: null),
                  IconButton(icon: Icon(Icons.email), onPressed: null),
                  showAddPersonButton(context),
                ],
              ),
              Row(
                children: <Widget>[
                  showPersonsList(user),
                ],
              ),
              showCompanyComments(),
            ],
          ),
        ),
      ),
    );
  }

  showCompanyComments() => Text(widget.companyDetails.companyComment);

  showPersonsList(User user) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.blue),
        ),
        child: Column(
          children: <Widget>[
            StreamBuilder<List<PersonDetails>>(
              stream: DatabaseServices(
                      uid: user.userUid,
                      companyUid: widget.companyDetails.companyUid)
                  .userPersonsForCompany,
              builder: (context, allCompanyPersons) {
                if (!allCompanyPersons.hasData) return const Text('Loading');
                if (allCompanyPersons.data.length > 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      //TODO impliment allways show scroolbar when available
                      //TODO display a wheel or something anaminated??
                      //https://github.com/flutter/flutter/issues/28836
                      child: Container(
                        height: allCompanyPersons.data.length.ceilToDouble() > 3
                            ? 100
                            : 60,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemExtent: 20,
                          itemCount: allCompanyPersons.data.length,
                          itemBuilder: (context, index) {
                            String _displayName =
                                allCompanyPersons.data[index].personName;
                            if (allCompanyPersons.data[index].personRole !=
                                null)
                              _displayName = _displayName +
                                  ' - ' +
                                  allCompanyPersons.data[index].personRole;
                            //TODO should be able to use TextOverflow.ellipse ??
                            if (_displayName.length > 30)
                              _displayName =
                                  _displayName.substring(0, 27) + '...';
                            return InkWell(
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.phone),
                                      onPressed: null,
                                      alignment: Alignment.topLeft,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.email),
                                      onPressed: null,
                                      alignment: Alignment.topLeft,
                                    ),
                                    Container(
                                      child: Text(
                                        _displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      height: 1,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPerson(
                                        companyName:
                                            widget.companyDetails.companyName,
                                        personUid: allCompanyPersons
                                            .data[index].personUid,
                                        personName: allCompanyPersons
                                            .data[index].personName,
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
                      'Reception',
                      maxLines: 1,
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPerson(
                            companyUid: widget.companyDetails.companyUid,
                            companyName: widget.companyDetails.companyName,
                            defaultPersonName: 'Reception',
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

  showAddPersonButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 0, 8),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('Add person'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPerson(
                companyUid: widget.companyDetails.companyUid,
                companyName: widget.companyDetails.companyName,
              ),
            ),
          );
        },
      ),
    );
  }

  showCompanyButton(BuildContext context) {
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
        width: 130,
        height: 25,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 1, 1, 1),
          child: Center(
              child: Text(
            widget.companyDetails.companyName,
            maxLines: 1,
          )),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCompany(
              companyUid: widget.companyDetails.companyUid,
              companyName: widget.companyDetails.companyName,
            ),
          ),
        );
      },
    );
  }
}
