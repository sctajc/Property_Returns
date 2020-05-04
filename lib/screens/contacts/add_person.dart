import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

class AddPerson extends StatefulWidget {
  static String id = 'add_person_screen';
  final String companyUid;
  final String companyName;
  final String defaultPersonName;
  AddPerson({this.companyUid, this.companyName, this.defaultPersonName});

  @override
  _AddPersonState createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentPersonName;
  String _currentPersonPhone;
  String _currentPersonEmail;
  String _currentPersonRole;
  String _currentPersonComment;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Add a person to ${widget.companyName}',
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
                  textFormFieldPersonName(),
                  SizedBox(
                    height: 10,
                  ),
                  textFormFieldPersonPhone(),
                  SizedBox(
                    height: 10,
                  ),
                  textFormFieldPersonEmail(),
                  SizedBox(
                    height: 10,
                  ),
                  textFormFieldPersonRole(),
                  SizedBox(
                    height: 10,
                  ),
                  textFormFieldPersonComment(),
                  SizedBox(
                    height: 10,
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
                child: Text('Add'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await DatabaseServices().addCompanyPerson(
                      user.userUid,
                      widget.companyUid,
                      _currentPersonName,
                      _currentPersonPhone,
                      _currentPersonEmail,
                      _currentPersonRole,
                      _currentPersonComment,
                      false,
                      Timestamp.now(),
                      Timestamp.now(),
                    );
                    Navigator.pop(context);
                  }
                })
          ],
        ),
      ),
    );
  }

  textFormFieldPersonComment() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Comment', labelStyle: kFieldHeading, hintText: 'comment'),
//                          validator: (val) => val.isEmpty
//                              ? 'Please enter who supplied the rental valuation'
//                              : null,
      onChanged: (val) => setState(() => _currentPersonComment = val),
    );
  }

  textFormFieldPersonRole() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Role', labelStyle: kFieldHeading, hintText: 'role'),
//                          validator: (val) => val.isEmpty
//                              ? 'Please enter who supplied the rental valuation'
//                              : null,
      onChanged: (val) => setState(() => _currentPersonRole = val),
    );
  }

  textFormFieldPersonEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Email', labelStyle: kFieldHeading, hintText: 'email'),
      validator: (val) => val.isNotEmpty && !EmailValidator.validate(val)
          ? 'Please enter a valid email'
          : null,
      onChanged: (val) => setState(() => _currentPersonEmail = val),
    );
  }

  textFormFieldPersonPhone() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Phone', labelStyle: kFieldHeading, hintText: 'phone'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentPersonPhone = val),
    );
  }

  textFormFieldPersonName() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      initialValue: widget.defaultPersonName,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Name',
          labelStyle: kFieldHeading,
          hintText: 'person name'),
      validator: (val) =>
          val.isEmpty ? 'Please enter what this person is know by' : null,
      onChanged: (val) => setState(() => _currentPersonName = val),
    );
  }
}
