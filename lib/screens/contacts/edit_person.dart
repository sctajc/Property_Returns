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

class EditPerson extends StatefulWidget {
  final String companyName;
  final String personName;
  final String personUid;

  EditPerson({this.companyName, this.personUid, this.personName});

  @override
  _EditPersonState createState() => _EditPersonState();
}

class _EditPersonState extends State<EditPerson> {
  bool archivePerson = false;
  final _formKey = GlobalKey<FormState>();

// form values
  String _currentPersonName;
  String _currentPersonPhone;
  String _currentPersonEmail;
  String _currentPersonRole;
  String _currentPersonComment;
  bool _currentPersonArchived = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<PersonDetails>(
      stream: DatabaseServices(uid: user.userUid, personUid: widget.personUid)
          .personByDocumentID,
      builder: (context, personDetails) {
        if (!personDetails.hasData) return Loading();
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
                      TextFormField(
                        keyboardType: TextInputType.text,
                        initialValue: personDetails.data.personName,
                        decoration: kTextInputDecoration.copyWith(
                            labelText: 'Name',
                            labelStyle: kFieldHeading,
                            hintText: 'name'),
                        validator: (val) =>
                            val.isEmpty ? 'Please enter person\'s name' : null,
                        onChanged: (val) =>
                            setState(() => _currentPersonName = val),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        initialValue: personDetails.data.personPhone,
                        decoration: kTextInputDecoration.copyWith(
                            labelText: 'Phone',
                            labelStyle: kFieldHeading,
                            hintText: 'person'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
                        onChanged: (val) =>
                            setState(() => _currentPersonPhone = val),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        initialValue: personDetails.data.personEmail,
                        decoration: kTextInputDecoration.copyWith(
                            labelText: 'Email',
                            labelStyle: kFieldHeading,
                            hintText: 'email'),
                        validator: (val) =>
                            val.isNotEmpty && !emailRegex.hasMatch(val)
                                ? 'Please enter a valid email'
                                : null,
                        onChanged: (val) =>
                            setState(() => _currentPersonEmail = val),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: personDetails.data.personRole,
                        decoration: kTextInputDecoration.copyWith(
                            labelText: 'Role',
                            labelStyle: kFieldHeading,
                            hintText: 'role'),
//                              validator: (val) => val.isEmpty
//                                  ? 'Please enter who supplied the rental valuation'
//                                  : null,
                        onChanged: (val) =>
                            setState(() => _currentPersonRole = val),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: personDetails.data.personComment,
                        decoration: kTextInputDecoration.copyWith(
                            labelText: 'Comment',
                            labelStyle: kFieldHeading,
                            hintText: 'comment'),
//                              validator: (val) => val.isEmpty
//                                  ? 'Please enter who supplied the rental valuation'
//                                  : null,
                        onChanged: (val) =>
                            setState(() => _currentPersonComment = val),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Archive person?',
                            style: kFieldHeading,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Checkbox(
                            value: archivePerson,
                            onChanged: (value) {
                              setState(() {
                                archivePerson = value;
                                _currentPersonArchived = archivePerson;
                              });
                            },
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          GestureDetector(
                            onTap: () => kShowHelpToast(context,
                                "If selected this person will be removed from being displayed for this company. These persons can be accessed through 'person Archived'"),
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
                        _currentPersonName ?? personDetails.data.personName,
                        _currentPersonPhone ?? personDetails.data.personPhone,
                        _currentPersonEmail ?? personDetails.data.personEmail,
                        _currentPersonRole ?? personDetails.data.personRole,
                        _currentPersonComment ??
                            personDetails.data.personComment,
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
}
