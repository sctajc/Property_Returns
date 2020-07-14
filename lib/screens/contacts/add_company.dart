import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:string_validator/string_validator.dart';

class AddCompany extends StatefulWidget {
  static String id = 'add_company_screen';

  @override
  _AddCompanyState createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _companyNameFocusNode = FocusNode();
  final FocusNode _companyCommentsFocusNode = FocusNode();
  final FocusNode _companyPhoneFocusNode = FocusNode();
  final FocusNode _companyEmailFocusNode = FocusNode();
  final FocusNode _companyWebsiteFocusNode = FocusNode();
  final FocusNode _companyPostalAddressFocusNode = FocusNode();

  bool _isCompanyTenant = false;
  bool _isCompanyTrade = false;
  bool _isCompanyAgent = false;

  // form values
  String _currentCompanyName;
  String _currentCompanyComments = '';
  String _currentCompanyPhone = '';
  String _currentCompanyEmail = '';
  String _currentCompanyWebsite = '';
  String _currentCompanyPostalAddress = '';
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
                _displayCompanyName(),
                SizedBox(
                  height: 10,
                ),
                _displayCompanyComment(),
                SizedBox(
                  height: 10,
                ),
                _displayCompanyPhone(),
                SizedBox(
                  height: 10,
                ),
                _displayCompanyEmail(),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                _displayCompanyWebsite(),
                SizedBox(
                  height: 10,
                ),
                _displayCompanyPostalAddress(),
                SizedBox(
                  height: 20,
                ),
                _displayCompanyTenant(context),
                _displayCompanyTrade(context),
                _displayCompanyAgent(context),
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
                      // phone
                      '',
                      // Email
                      '',
                      // role
                      '',
                      // comment
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

  _displayCompanyName() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _companyNameFocusNode,
      textCapitalization: TextCapitalization.words,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Company Name',
          labelStyle: kFieldHeading,
          hintText: 'company name'),
      validator: (val) => val.isEmpty
          ? 'Please enter what company/organisation is know as'
          : null,
      onChanged: (val) => setState(() => _currentCompanyName = val),
      onEditingComplete: _companyNameEditingComplete,
    );
  }

  void _companyNameEditingComplete() {
    FocusScope.of(context).requestFocus(_companyCommentsFocusNode);
  }

  _displayCompanyComment() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _companyCommentsFocusNode,
      textCapitalization: TextCapitalization.sentences,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Comments',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentCompanyComments = val),
      onEditingComplete: _companyCommentEditingComplete,
    );
  }

  void _companyCommentEditingComplete() {
    FocusScope.of(context).requestFocus(_companyPhoneFocusNode);
  }

  _displayCompanyPhone() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      focusNode: _companyPhoneFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Phone', labelStyle: kFieldHeading, hintText: 'phone'),
//                      validator: (val) =>
//                          val.isEmpty ? 'Please enter a phone number' : null,
      onChanged: (val) => setState(() => _currentCompanyPhone = val),
      onEditingComplete: _companyPhoneEditingComplete,
    );
  }

  void _companyPhoneEditingComplete() {
    FocusScope.of(context).requestFocus(_companyEmailFocusNode);
  }

  _displayCompanyEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _companyEmailFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Email',
          labelStyle: kFieldHeading,
          hintText: 'company email eg info@'),
      validator: (val) => val.isNotEmpty && !EmailValidator.validate(val)
          ? 'Please enter a valid email'
          : null,
      onChanged: (val) => setState(() => _currentCompanyEmail = val),
      onEditingComplete: _companyEmailEditingComplete,
    );
  }

  void _companyEmailEditingComplete() {
    FocusScope.of(context).requestFocus(_companyWebsiteFocusNode);
  }

  _displayCompanyWebsite() {
    return TextFormField(
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      focusNode: _companyWebsiteFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Website', labelStyle: kFieldHeading, hintText: 'website'),
      validator: (val) =>
          val.isNotEmpty && !isURL(val) ? 'Please enter valid website' : null,
      onChanged: (val) => setState(() => _currentCompanyWebsite = val),
      onEditingComplete: _companyWebsiteEditingComplete,
    );
  }

  void _companyWebsiteEditingComplete() {
    FocusScope.of(context).requestFocus(_companyPostalAddressFocusNode);
  }

  _displayCompanyPostalAddress() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      focusNode: _companyPostalAddressFocusNode,
      textCapitalization: TextCapitalization.words,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Postal Address',
          labelStyle: kFieldHeading,
          hintText: 'postal address'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
      onChanged: (val) => setState(() => _currentCompanyPostalAddress = val),
    );
  }

  _displayCompanyTenant(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Tenant',
        style: kFieldHeading,
      ),
      value: _isCompanyTenant,
      onChanged: (value) {
        setState(() {
          _isCompanyTenant = value;
          _currentCompanySetTenant = _isCompanyTenant;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(
            context, "If selected this company can be assigned to leases'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }

  _displayCompanyTrade(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Trade',
        style: kFieldHeading,
      ),
      value: _isCompanyTrade,
      onChanged: (value) {
        setState(() {
          _isCompanyTrade = value;
          _currentCompanySetTrade = _isCompanyTrade;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected this company will be listed under trades, i.e a supplier'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }

  _displayCompanyAgent(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Other  ',
        style: kFieldHeading,
      ),
      value: _isCompanyAgent,
      onChanged: (value) {
        setState(() {
          _isCompanyAgent = value;
          _currentCompanySetAgent = _isCompanyAgent;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(
            context, "If selected this company will be listed under Others'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }
}
