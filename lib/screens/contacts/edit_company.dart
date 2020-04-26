import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class EditCompany extends StatefulWidget {
  static String id = 'edit_company_screen';
  final String companyUid;
  final String companyName;

  EditCompany({this.companyUid, this.companyName});

  @override
  _EditCompanyState createState() => _EditCompanyState();
}

class _EditCompanyState extends State<EditCompany> {
  bool _archiveCompany = false;
  bool _setTenant = false;
  bool _setTrade = false;
  bool _setAgent = false;
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentCompanyName;
  String _currentCompanyComment;
  String _currentCompanyPhone;
  String _currentCompanyEmail;
  String _currentCompanyWebsite;
  String _currentCompanyPostalAddress;
  bool _currentCompanySetTenant;
  bool _currentCompanySetTrade;
  bool _currentCompanySetAgent;
  bool _currentCompanyArchived = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firestore.instance
        .collection("companies")
        .document(widget.companyUid)
        .snapshots()
        .listen((snapshot) {
      _setTenant = snapshot.data['companySetTenant'];
      _setTrade = snapshot.data['companySetTrade'];
      _setAgent = snapshot.data['companySetAgent'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<CompanyDetails>(
      stream: DatabaseServices(uid: user.userUid, companyUid: widget.companyUid)
          .companyByDocumentID,
      builder: (context, companyDetails) {
        if (!companyDetails.hasData) return Loading();
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(
              '${widget.companyName}',
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
                      initialValue: companyDetails.data.companyName,
                      decoration: kTextInputDecoration.copyWith(
                          labelText: 'Company Name',
                          labelStyle: kFieldHeading,
                          hintText: 'company name'),
                      validator: (val) => val.isEmpty
                          ? 'Please enter the company is know as'
                          : null,
                      onChanged: (val) =>
                          setState(() => _currentCompanyName = val),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: companyDetails.data.companyComment,
                      decoration: kTextInputDecoration.copyWith(
                          labelText: 'Comments',
                          labelStyle: kFieldHeading,
                          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
                      onChanged: (val) =>
                          setState(() => _currentCompanyComment = val),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: companyDetails.data.companyPhone,
                      decoration: kTextInputDecoration.copyWith(
                          labelText: 'Phone',
                          labelStyle: kFieldHeading,
                          hintText: 'phone'),
//                      validator: (val) =>
//                          val.isEmpty ? 'Please enter phone number' : null,
                      onChanged: (val) =>
                          setState(() => _currentCompanyPhone = val),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: companyDetails.data.companyEmail,
                      decoration: kTextInputDecoration.copyWith(
                          labelText: 'Email',
                          labelStyle: kFieldHeading,
                          hintText: 'email'),
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
                    TextFormField(
                      initialValue: companyDetails.data.companyWebsite,
                      decoration: kTextInputDecoration.copyWith(
                          labelText: 'Website',
                          labelStyle: kFieldHeading,
                          hintText: 'website'),
//                      validator: (val) =>
//                          val.isNotEmpty && !webRegex.hasMatch(val)
//                              ? 'Please enter a valid website'
//                              : null,
                      onChanged: (val) =>
                          setState(() => _currentCompanyWebsite = val),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: companyDetails.data.companyPostalAddress,
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
                          value: _setTenant,
                          onChanged: (value) {
                            setState(() {
                              _setTenant = value;
                              _currentCompanySetTenant = _setTenant;
                            });
                          },
                        ),
                        SizedBox(
                          width: 1,
                        ),
                        GestureDetector(
                          onTap: () => kShowHelpToast(context,
                              "If selected the company will be available to form leases'"),
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
                          value: _setTrade,
                          onChanged: (value) {
                            setState(() {
                              _setTrade = value;
                              _currentCompanySetTrade = _setTrade;
                            });
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () => kShowHelpToast(context,
                              "If selected the company will be available in your displayed trades"),
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
                          value: _setAgent,
                          onChanged: (value) {
                            setState(() {
                              _setAgent = value;
                              _currentCompanySetAgent = _setAgent;
                            });
                          },
                        ),
                        SizedBox(
                          width: 1,
                        ),
                        GestureDetector(
                          onTap: () => kShowHelpToast(context,
                              "If selected the company will be available in your displayed agents"),
                          child: Icon(
                            Icons.help_outline,
                            color: kColorOrange,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'Archive company',
                          style: kFieldHeading,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Checkbox(
                          value: _archiveCompany,
                          onChanged: (value) {
                            setState(() {
                              _archiveCompany = value;
                              _currentCompanyArchived = _archiveCompany;
                            });
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () => kShowHelpToast(context,
                              "If selected the company will be removed from your displayed companies. These will normally be companies which are not required anymore. These companies can be accessed through 'Companies Archived'"),
                          child: Icon(
                            Icons.help_outline,
                            color: kColorOrange,
                          ),
                        ),
                      ],
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
                  child: Text('Update'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      await DatabaseServices(companyUid: widget.companyUid)
                          .updateUserCompany(
                        user.userUid,
                        _currentCompanyName ?? companyDetails.data.companyName,
                        _currentCompanyComment ??
                            companyDetails.data.companyComment,
                        _currentCompanyPhone ??
                            companyDetails.data.companyPhone,
                        _currentCompanyEmail ??
                            companyDetails.data.companyEmail,
                        _currentCompanyWebsite ??
                            companyDetails.data.companyWebsite,
                        _currentCompanyPostalAddress ??
                            companyDetails.data.companyPostalAddress,
                        _setTenant ?? companyDetails.data.companySetTenant,
                        _setTrade ?? companyDetails.data.companySetTrade,
                        _setAgent ?? companyDetails.data.companySetAgent,
                        _currentCompanyArchived ??
                            companyDetails.data.companyArchived,
                        companyDetails.data.companyRecordCreatedDateTime,
                        Timestamp.now(),
                      );
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
