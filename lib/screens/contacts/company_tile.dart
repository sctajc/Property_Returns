import 'dart:ui';
import 'package:property_returns/models/company_details.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_person.dart';
import 'edit_company.dart';
import 'edit_person.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class CompanyTile extends StatefulWidget {
  final CompanyDetails companyDetails;
  CompanyTile({this.companyDetails});

  @override
  _CompanyTileState createState() => _CompanyTileState();
}

class _CompanyTileState extends State<CompanyTile> {
  TextEditingController _numberCompanyPhone = TextEditingController();
  TextEditingController _emailCompanyEmail = TextEditingController();
  String _tooltipCompanyPhone;
  String _tooltipCompanyEmail;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    String _tempCompanyComment = widget.companyDetails.companyComment;
    _tempCompanyComment ??= "";

    widget.companyDetails.companyPhone.length > 1
        ? _numberCompanyPhone.text =
            widget.companyDetails.companyPhone.replaceAll(RegExp(r'\D'), '')
        : _numberCompanyPhone.text = '';
    _numberCompanyPhone.text.length > 1
        ? _tooltipCompanyPhone = _numberCompanyPhone.text
        : _tooltipCompanyPhone = 'No number';

    widget.companyDetails.companyEmail.length > 1
        ? _emailCompanyEmail.text = widget.companyDetails.companyEmail
        : _emailCompanyEmail.text = '';
    _emailCompanyEmail.text.length > 0
        ? _tooltipCompanyEmail = _emailCompanyEmail.text
        : _tooltipCompanyEmail = 'No email';

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
                  showCompanyPhoneIcon(),
                  showCompanyEmailIcon(),
                  showAddPersonButton(context),
                ],
              ),
              Row(
                children: <Widget>[
                  showPersonsList(user),
                ],
              ),
              Text(_tempCompanyComment),
            ],
          ),
        ),
      ),
    );
  }

  showCompanyEmailIcon() {
    return IconButton(
        tooltip: _tooltipCompanyEmail,
        icon: Icon(Icons.email),
        color: Colors.lightBlue,
        onPressed: _emailCompanyEmail.text.length > 0
            ? () async {
                if (await canLaunch('mailto:$_emailCompanyEmail')) {
                  await launch('mailto:$_tooltipCompanyEmail');
                } else {
                  throw 'Could not launch emailer app for mailto:$_tooltipCompanyEmail';
                }
              }
            : null);
  }

  showCompanyPhoneIcon() {
    return IconButton(
        tooltip: _tooltipCompanyPhone,
        icon: Icon(Icons.phone),
        color: Colors.lightBlue,
        onPressed: _numberCompanyPhone.text.length > 0
            ? () async {
                FlutterPhoneDirectCaller.callNumber(_tooltipCompanyPhone);
              }
            : null);
  }

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
                                    null &&
                                allCompanyPersons
                                        .data[index].personRole.length >
                                    0)
                              _displayName = _displayName +
                                  ' - ' +
                                  allCompanyPersons.data[index].personRole;
                            //TODO should be able to use TextOverflow.ellipse ??
                            if (_displayName.length > 30)
                              _displayName =
                                  _displayName.substring(0, 27) + '...';
                            TextEditingController _numberPersonPhone =
                                TextEditingController();
                            TextEditingController _emailPersonEmail =
                                TextEditingController();
                            String _tooltipPersonPhone;
                            String _tooltipPersonEmail;

                            allCompanyPersons.data[index].personPhone.length > 0
                                ? _numberPersonPhone.text = allCompanyPersons
                                    .data[index].personPhone
                                    .replaceAll(RegExp(r'\D'), '')
                                : _numberPersonPhone.text = '';
                            _numberPersonPhone.text.length > 0
                                ? _tooltipPersonPhone = _numberPersonPhone.text
                                : _tooltipPersonPhone = 'No number';

                            allCompanyPersons.data[index].personEmail.length > 0
                                ? _emailPersonEmail.text =
                                    allCompanyPersons.data[index].personEmail
                                : _emailPersonEmail.text = '';
                            _emailPersonEmail.text.length > 0
                                ? _tooltipPersonEmail = _emailPersonEmail.text
                                : _tooltipPersonEmail = 'No email';
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.phone),
                                  tooltip: _tooltipPersonPhone,
                                  color: Colors.lightBlue,
                                  onPressed: _numberPersonPhone.text.length > 0
                                      ? () async {
                                          FlutterPhoneDirectCaller.callNumber(
                                              _tooltipPersonPhone);
                                        }
                                      : null,
                                  padding: EdgeInsets.all(0),
                                ),
                                IconButton(
                                  icon: Icon(Icons.email),
                                  tooltip: _tooltipPersonEmail,
                                  color: Colors.lightBlue,
                                  onPressed: _emailPersonEmail.text.length > 0
                                      ? () async {
                                          if (await canLaunch(
                                              'mailto:$_tooltipPersonEmail')) {
                                            print(
                                                '$_displayName email: $_tooltipPersonEmail');
                                            await launch(
                                                'mailto:$_tooltipPersonEmail');
                                          } else {
                                            throw 'Could not launch emailer app for mailto:$_tooltipPersonEmail';
                                          }
                                        }
                                      : null,
                                  padding: EdgeInsets.all(0),
                                ),
                                InkWell(
                                    child: Text(
                                      _displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPerson(
                                            companyName: widget
                                                .companyDetails.companyName,
                                            personUid: allCompanyPersons
                                                .data[index].personUid,
                                            personName: allCompanyPersons
                                                .data[index].personName,
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            );
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
    return Flexible(
      child: Padding(
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
