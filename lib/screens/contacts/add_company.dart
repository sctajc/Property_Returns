import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/shared/loading.dart';

class AddCompany extends StatefulWidget {
  static String id = 'add_company_screen';

  @override
  _AddCompanyState createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  bool _isCompanyTenant = false;
  bool _isCompanyTrade = false;
  bool _isCompanyAgent = false;
//  String justCreatedCompanyUid;
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentCompanyName;
  String _currentCompanyComments;
  String _currentCompanyPhone;
  String _currentCompanyEmail;
  String _currentCompanyWebsite;
  String _currentCompanyPostalAddress;
  bool _currentCompanySetTenant = false;
  bool _currentCompanySetTrade = false;
  bool _currentCompanySetAgent = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Add a new company',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: kTextInputDecoration.copyWith(
                      labelText: 'Company Name',
                      labelStyle: kFieldHeading,
                      hintText: 'company name'),
                  validator: (val) => val.isEmpty
                      ? 'Please enter what company/organisation is know as'
                      : null,
                  onChanged: (val) => setState(() => _currentCompanyName = val),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: kTextInputDecoration.copyWith(
                      labelText: 'Comments',
                      labelStyle: kFieldHeading,
                      hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
                  onChanged: (val) =>
                      setState(() => _currentCompanyComments = val),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: kTextInputDecoration.copyWith(
                      labelText: 'Phone',
                      labelStyle: kFieldHeading,
                      hintText: 'phone'),
//                      validator: (val) =>
//                          val.isEmpty ? 'Please enter a phone number' : null,
                  onChanged: (val) =>
                      setState(() => _currentCompanyPhone = val),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: kTextInputDecoration.copyWith(
                      labelText: 'Email',
                      labelStyle: kFieldHeading,
                      hintText: 'company email eg info@'),
                  validator: (val) =>
                      val.isNotEmpty && !emailRegex.hasMatch(val)
                          ? 'Please enter a valid email'
                          : null,
                  onChanged: (val) =>
                      setState(() => _currentCompanyEmail = val),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: kTextInputDecoration.copyWith(
                      labelText: 'Website',
                      labelStyle: kFieldHeading,
                      hintText: 'website'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter any billing code' : null,
                  onChanged: (val) =>
                      setState(() => _currentCompanyWebsite = val),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: kTextInputDecoration.copyWith(
                      labelText: 'Postal Address',
                      labelStyle: kFieldHeading,
                      hintText: 'postal address'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
                  onChanged: (val) =>
                      setState(() => _currentCompanyPostalAddress = val),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Tenant',
                      style: kFieldHeading,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Checkbox(
                      value: _isCompanyTenant,
                      onChanged: (value) {
                        setState(() {
                          _isCompanyTenant = value;
                          _currentCompanySetTenant = _isCompanyTenant;
                        });
                      },
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    GestureDetector(
                      onTap: () => kShowHelpToast(context,
                          "If selected this company can be assigned to leases'"),
                      child: Icon(
                        Icons.help_outline,
                        color: kColorOrange,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Text(
                      'Trade',
                      style: kFieldHeading,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Checkbox(
                      value: _isCompanyTrade,
                      onChanged: (value) {
                        setState(() {
                          _isCompanyTrade = value;
                          _currentCompanySetTrade = _isCompanyTrade;
                        });
                      },
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    GestureDetector(
                      onTap: () => kShowHelpToast(context,
                          "If selected this company will be listed under trades, i.e a supplier'"),
                      child: Icon(
                        Icons.help_outline,
                        color: kColorOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 1,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Agent  ',
                      style: kFieldHeading,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Checkbox(
                      value: _isCompanyAgent,
                      onChanged: (value) {
                        setState(() {
                          _isCompanyAgent = value;
                          _currentCompanySetAgent = _isCompanyAgent;
                        });
                      },
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    GestureDetector(
                      onTap: () => kShowHelpToast(context,
                          "If selected this company will be listed under agents'"),
                      child: Icon(
                        Icons.help_outline,
                        color: kColorOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  // so keyboard does not hide bottom textfield
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                child: Text('Add'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    DocumentReference docRef =
                        await DatabaseServices().addUserCompany(
                      user.userUid,
                      _currentCompanyName,
                      _currentCompanyComments,
                      _currentCompanyPhone,
                      _currentCompanyEmail,
                      _currentCompanyWebsite,
                      _currentCompanyPostalAddress,
                      _currentCompanySetTenant,
                      _currentCompanySetTrade,
                      _currentCompanySetAgent,
                      false,
                      Timestamp.now(),
                      Timestamp.now(),
                    );
                    //print('docRef: ${docRef.documentID}');
                    await DatabaseServices().addCompanyPerson(
                      user.userUid,
                      docRef.documentID,
                      'Reception',
                      '',
                      '',
                      '',
                      '',
                      false,
                      Timestamp.now(),
                      Timestamp.now(),
                    );
//                        print('docRef: ${docRef.documentID}');
                    Navigator.pop(context);
                  }
                })
          ],
        ),
      ),
    );
  }
}
