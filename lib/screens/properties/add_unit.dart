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

class AddUnit extends StatefulWidget {
  static String id = 'add_unit_screen';
  final String propertyUid;
  final String propertyName;
  AddUnit({this.propertyUid, this.propertyName});

  @override
  _AddUnitState createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  bool unitResidential = false;
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentUnitName;
  String _currentUnitNotes;
  String _currentUnitLeaseDescription;
  num _currentUnitArea;
  bool _currentUnitResidential = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Add a unit to ${widget.propertyName}',
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
                    decoration:
                        kTextInputDecoration.copyWith(hintText: 'unit name'),
                    validator: (val) => val.isEmpty
                        ? 'Please enter what this area is know by'
                        : null,
                    onChanged: (val) => setState(() => _currentUnitName = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration:
                        kTextInputDecoration.copyWith(hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
                    onChanged: (val) => setState(() => _currentUnitNotes = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: kTextInputDecoration.copyWith(
                        hintText: 'Lease description'),
                    validator: (val) =>
                        val.isEmpty ? 'Please enter lease description' : null,
                    onChanged: (val) =>
                        setState(() => _currentUnitLeaseDescription = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            'Area',
                            style: kFieldHeading,
                          ),
                          Text(
                            '(M2)',
                            style: kFieldHeading,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          inputFormatters: [
                            WhitelistingTextInputFormatter(RegExp("[0-9.]"))
                          ],
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: kTextInputDecoration.copyWith(
                              hintText: 'Floor area'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
                          onChanged: (val) => setState(
                              () => _currentUnitArea = double.parse(val)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Residential?',
                        style: kFieldHeading,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Checkbox(
                        value: unitResidential,
                        onChanged: (value) {
                          setState(() {
                            unitResidential = value;
                            _currentUnitResidential = unitResidential;
                          });
                        },
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () => kShowHelpToast(context,
                            "If selected the unit is residential only"),
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
                child: Text('Add'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await DatabaseServices().addPropertyUnit(
                      user.userUid,
                      widget.propertyUid,
                      _currentUnitName,
                      _currentUnitNotes,
                      _currentUnitLeaseDescription,
                      _currentUnitArea,
                      _currentUnitResidential,
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
}
