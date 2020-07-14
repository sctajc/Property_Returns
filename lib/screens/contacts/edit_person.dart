import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

class EditPerson extends StatefulWidget {
  final String companyName;
  final String personName;
  final String personUid;
  EditPerson({this.companyName, this.personUid, this.personName});

  @override
  _EditPersonState createState() => _EditPersonState();
}

class _EditPersonState extends State<EditPerson> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _personNameFocusNode = FocusNode();
  final FocusNode _personPhoneFocusNode = FocusNode();
  final FocusNode _personEmailFocusNode = FocusNode();
  final FocusNode _personRoleFocusNode = FocusNode();
  final FocusNode _personCommentFocusNode = FocusNode();

  bool archivePerson = false;

// form values
  String _currentPersonName = 'initialiseName';
  String _currentPersonPhone = 'InitialisePhone';
  String _currentPersonEmail = 'initialiseEmail';
  String _currentPersonRole = 'initialiseRole';
  String _currentPersonComment = 'initialiseComment';
  bool _currentPersonArchived = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<PersonDetails>(
      stream: DatabaseServices(uid: user.userUid, personUid: widget.personUid)
          .personByDocumentID,
      builder: (context, personDetails) {
        if (!personDetails.hasData) return Loading();

        if (_currentPersonName == 'initialiseName')
          _currentPersonName = personDetails.data.personName;
        if (_currentPersonPhone == 'InitialisePhone')
          _currentPersonPhone = personDetails.data.personPhone;
        if (_currentPersonEmail == 'initialiseEmail')
          _currentPersonEmail = personDetails.data.personEmail;
        if (_currentPersonRole == 'initialiseRole')
          _currentPersonRole = personDetails.data.personRole;
        if (_currentPersonComment == 'initialiseComment')
          _currentPersonComment = personDetails.data.personComment;
//        print('_currentPersonPhone after build: $_currentPersonPhone');

        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(
              '${widget.personName} with ${widget.companyName}',
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
                      _displayPersonName(personDetails),
                      SizedBox(
                        height: 10,
                      ),
                      _displayPersonPhone(personDetails),
                      SizedBox(
                        height: 10,
                      ),
                      _displayPersonEmail(personDetails),
                      SizedBox(
                        height: 10,
                      ),
                      _displayPersonRole(personDetails),
                      SizedBox(
                        height: 10,
                      ),
                      _displayPersonComment(personDetails),
                      SizedBox(
                        height: 20,
                      ),
                      _displayPersonArchive(context),
                      SizedBox(
                        // so keyboard does not hide bottom textfield
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  )),
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
                      await DatabaseServices(personUid: widget.personUid)
                          .updateCompanyPerson(
                        user.userUid,
                        personDetails.data.companyUid,
                        _currentPersonName,
                        _currentPersonPhone,
                        _currentPersonEmail,
                        _currentPersonRole,
                        _currentPersonComment,
                        _currentPersonArchived ??
                            personDetails.data.personArchived,
                        personDetails.data.personRecordCreatedDateTime,
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

  _displayPersonName(AsyncSnapshot<PersonDetails> personDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _personNameFocusNode,
      textCapitalization: TextCapitalization.words,
      initialValue: personDetails.data.personName,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Name', labelStyle: kFieldHeading, hintText: 'name'),
      validator: (val) => val.isEmpty ? 'Please enter person\'s name' : null,
      onChanged: (val) => setState(() => _currentPersonName = val),
      onEditingComplete: _personNameEditingComplete,
    );
  }

  void _personNameEditingComplete() {
    FocusScope.of(context).requestFocus(_personPhoneFocusNode);
  }

  _displayPersonPhone(AsyncSnapshot<PersonDetails> personDetails) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      focusNode: _personPhoneFocusNode,
      initialValue: personDetails.data.personPhone,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Phone', labelStyle: kFieldHeading, hintText: 'phone'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentPersonPhone = val),
      onEditingComplete: _personPhoneEditingComplete,
    );
  }

  void _personPhoneEditingComplete() {
    FocusScope.of(context).requestFocus(_personEmailFocusNode);
  }

  _displayPersonEmail(AsyncSnapshot<PersonDetails> personDetails) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _personEmailFocusNode,
      initialValue: personDetails.data.personEmail,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Email', labelStyle: kFieldHeading, hintText: 'email'),
      validator: (val) => val.isNotEmpty && !EmailValidator.validate(val)
          ? 'Please enter a valid email'
          : null,
      onChanged: (val) => setState(() => _currentPersonEmail = val),
      onEditingComplete: _personEmailEditingComplete,
    );
  }

  void _personEmailEditingComplete() {
    FocusScope.of(context).requestFocus(_personRoleFocusNode);
  }

  _displayPersonRole(AsyncSnapshot<PersonDetails> personDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _personRoleFocusNode,
      textCapitalization: TextCapitalization.words,
      initialValue: personDetails.data.personRole,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Role', labelStyle: kFieldHeading, hintText: 'role'),
//                              validator: (val) => val.isEmpty
//                                  ? 'Please enter who supplied the rental valuation'
//                                  : null,
      onChanged: (val) => setState(() => _currentPersonRole = val),
      onEditingComplete: _personRoleEditingComplete,
    );
  }

  void _personRoleEditingComplete() {
    FocusScope.of(context).requestFocus(_personCommentFocusNode);
  }

  _displayPersonComment(AsyncSnapshot<PersonDetails> personDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      focusNode: _personCommentFocusNode,
      textCapitalization: TextCapitalization.sentences,
      initialValue: personDetails.data.personComment,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Comment', labelStyle: kFieldHeading, hintText: 'comment'),
//                              validator: (val) => val.isEmpty
//                                  ? 'Please enter who supplied the rental valuation'
//                                  : null,
      onChanged: (val) => setState(() => _currentPersonComment = val),
    );
  }

  _displayPersonArchive(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Archive person?',
        style: kFieldHeading,
      ),
      value: archivePerson,
      onChanged: (value) {
        setState(() {
          archivePerson = value;
          _currentPersonArchived = archivePerson;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected this person will be removed from being displayed for this company. These persons can be accessed through 'person Archived'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }
}
