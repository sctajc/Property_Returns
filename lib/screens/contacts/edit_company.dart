import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:string_validator/string_validator.dart';

class EditCompany extends StatefulWidget {
  static String id = 'edit_company_screen';
  final String companyUid;
  final String companyName;
  EditCompany({this.companyUid, this.companyName});

  @override
  _EditCompanyState createState() => _EditCompanyState();
}

class _EditCompanyState extends State<EditCompany> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _companyNameFocusNode = FocusNode();
  final FocusNode _companyCommentsFocusNode = FocusNode();
  final FocusNode _companyPhoneFocusNode = FocusNode();
  final FocusNode _companyEmailFocusNode = FocusNode();
  final FocusNode _companyWebsiteFocusNode = FocusNode();
  final FocusNode _companyPostalAddressFocusNode = FocusNode();

  bool _archiveCompany = false;
  bool _setTenant = false;
  bool _setTrade = false;
  bool _setAgent = false;

  // form values
  String _currentCompanyName = 'initialised';
  String _currentCompanyComment = 'initialised';
  String _currentCompanyPhone = 'initialised';
  String _currentCompanyEmail = 'initialised';
  String _currentCompanyWebsite = 'initialised';
  String _currentCompanyPostalAddress = 'initialised';
  bool _currentCompanyArchived = false;

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection("companies")
        .document(widget.companyUid)
        .snapshots()
        .listen((snapshot) {
      _currentCompanyName = snapshot.data['companyName'];
      _currentCompanyComment = snapshot.data['companyComment'];
      _currentCompanyPhone = snapshot.data['companyPhone'];
      _currentCompanyEmail = snapshot.data['companyEmail'];
      _currentCompanyWebsite = snapshot.data['companyWebsite'];
      _currentCompanyPostalAddress = snapshot.data['companyPostalAddress'];

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
                    _displayCompanyName(companyDetails),
                    SizedBox(
                      height: 10,
                    ),
                    _displayCompanyComment(companyDetails),
                    SizedBox(
                      height: 10,
                    ),
                    _displayCompanyPhone(companyDetails),
                    SizedBox(
                      height: 10,
                    ),
                    _displayCompanyEmail(companyDetails),
                    SizedBox(
                      height: 10,
                    ),
                    _displayCompanyWebsite(companyDetails),
                    SizedBox(
                      height: 20,
                    ),
                    _displayCompanyPostalAddress(companyDetails),
                    _displayCompanyTenant(context),
                    _displayCompanyTrade(context),
                    _displayCompanyAgent(context),
                    SizedBox(
                      child: Text('----------'),
                    ),
                    _displayCompanyArchive(context),
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
                        _currentCompanyName,
                        _currentCompanyComment,
                        _currentCompanyPhone,
                        _currentCompanyEmail,
                        _currentCompanyWebsite,
                        _currentCompanyPostalAddress,
                        _setTenant,
                        _setTrade,
                        _setAgent,
                        _currentCompanyArchived,
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

  _displayCompanyName(AsyncSnapshot<CompanyDetails> companyDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _companyNameFocusNode,
      textCapitalization: TextCapitalization.words,
      initialValue: companyDetails.data.companyName,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Company Name',
          labelStyle: kFieldHeading,
          hintText: 'company name'),
      validator: (val) =>
          val.isEmpty ? 'Please enter the company is know as' : null,
      onChanged: (val) => setState(() => _currentCompanyName = val),
      onEditingComplete: _companyNameEditingComplete,
    );
  }

  void _companyNameEditingComplete() {
    FocusScope.of(context).requestFocus(_companyCommentsFocusNode);
  }

  _displayCompanyComment(AsyncSnapshot<CompanyDetails> companyDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _companyCommentsFocusNode,
      textCapitalization: TextCapitalization.sentences,
      initialValue: companyDetails.data.companyComment,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Comments',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentCompanyComment = val),
      onEditingComplete: _companyCommentEditingComplete,
    );
  }

  void _companyCommentEditingComplete() {
    FocusScope.of(context).requestFocus(_companyPhoneFocusNode);
  }

  _displayCompanyPhone(AsyncSnapshot<CompanyDetails> companyDetails) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      focusNode: _companyPhoneFocusNode,
      initialValue: companyDetails.data.companyPhone,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Phone', labelStyle: kFieldHeading, hintText: 'phone'),
//                      validator: (val) =>
//                          val.isEmpty ? 'Please enter phone number' : null,
      onChanged: (val) => setState(() => _currentCompanyPhone = val),
      onEditingComplete: _companyPhoneEditingComplete,
    );
  }

  void _companyPhoneEditingComplete() {
    FocusScope.of(context).requestFocus(_companyEmailFocusNode);
  }

  _displayCompanyEmail(AsyncSnapshot<CompanyDetails> companyDetails) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _companyEmailFocusNode,
      initialValue: companyDetails.data.companyEmail,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Email', labelStyle: kFieldHeading, hintText: 'email'),
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

  _displayCompanyWebsite(AsyncSnapshot<CompanyDetails> companyDetails) {
    return TextFormField(
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      focusNode: _companyWebsiteFocusNode,
      initialValue: companyDetails.data.companyWebsite,
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

  _displayCompanyPostalAddress(AsyncSnapshot<CompanyDetails> companyDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      focusNode: _companyPostalAddressFocusNode,
      textCapitalization: TextCapitalization.words,
      initialValue: companyDetails.data.companyPostalAddress,
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
      value: _setTenant,
      onChanged: (value) {
        setState(() {
          _setTenant = value;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected the company will be available to form leases'"),
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
      value: _setTrade,
      onChanged: (value) {
        setState(() {
          _setTrade = value;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected the company will be available in your displayed trades"),
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
      value: _setAgent,
      onChanged: (value) {
        setState(() {
          _setAgent = value;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected the company will be available in your displayed Others"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }

  _displayCompanyArchive(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Archive company',
        style: kFieldHeading,
      ),
      value: _archiveCompany,
      onChanged: (value) {
        setState(() {
          _archiveCompany = value;
          _currentCompanyArchived = _archiveCompany;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected the company will be removed from your displayed companies. These will normally be companies which are not required anymore. These companies can be accessed through 'Companies Archived'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }
}
