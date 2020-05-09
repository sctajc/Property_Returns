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

class AddUnit extends StatefulWidget {
  static String id = 'add_unit_screen';
  final String propertyUid;
  final String propertyName;
  final String defaultUnitName;
  AddUnit({this.propertyUid, this.propertyName, this.defaultUnitName});

  @override
  _AddUnitState createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  bool unitResidential = false;
  final _formKey = GlobalKey<FormState>();
  String _areaMeasurementSymbol;
  String _currencySymbol = '\$';

  // form values
  String _currentUnitName;
  String _currentUnitNotes;
  String _currentUnitLeaseDescription;
  num _currentUnitArea;
  num _currentUnitPercentageSplit;
  bool _currentUnitResidential = false;
  num _currentUnitRentalValuationAmount;
  DateTime _currentUnitRentalValuationDate;
  String _currentUnitRentalValuationSource;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user.userUid).userData,
        builder: (context, userData) {
          if (!userData.hasData) return Loading();
          userData.data.areaMeasurementM2 == true
              ? _areaMeasurementSymbol = 'M\u00B2'
              : _areaMeasurementSymbol = 'Ft\u00B2';
          _currencySymbol = userData.data.currencySymbol;
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
                        _displayUnitNameField(),
                        SizedBox(
                          height: 10,
                        ),
                        _displayUnitDetailsField(),
                        SizedBox(
                          height: 10,
                        ),
                        _displayUnitLeaseDescription(),
                        SizedBox(
                          height: 10,
                        ),
                        _displayUnitFloorAreaField(),
                        SizedBox(
                          height: 10,
                        ),
                        _displayUnitPercentageSplitField(),
                        SizedBox(
                          height: 20,
                        ),
                        _displayUnitResidentialField(context),
                        SizedBox(
                          height: 20,
                        ),
                        _displayUnitRentalValuationField(),
                        // display rental valuation date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Rental',
                                  style: kFieldHeading,
                                ),
                                Text(
                                  'valuation',
                                  style: kFieldHeading,
                                ),
                                Text(
                                  'date',
                                  style: kFieldHeading,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 200,
                                    child: DateTimeField(
//                                      validator: (val) => val == null
//                                          ? 'Please enter a purchased date'
//                                          : null,
                                      initialValue: null,
                                      format: DateFormat("E,  MMM d, y"),
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1950),
                                          lastDate: DateTime.now(),
                                        );
                                        if (date != null) {
                                          _currentUnitRentalValuationDate =
                                              date;
                                          return _currentUnitRentalValuationDate;
                                        } else {
                                          return currentValue;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _displayUnitRentalValuationSourceField(),
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
                          await DatabaseServices().addPropertyUnit(
                            user.userUid,
                            widget.propertyUid,
                            _currentUnitName,
                            _currentUnitNotes,
                            _currentUnitLeaseDescription,
                            _currentUnitArea,
                            _currentUnitPercentageSplit,
                            _currentUnitResidential,
                            _currentUnitRentalValuationAmount,
                            _currentUnitRentalValuationDate,
                            _currentUnitRentalValuationSource,
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
        });
  }

  _displayUnitRentalValuationSourceField() {
    return TextFormField(
      // used for initial/single/first unit for property
//                          initialValue: widget.defaultUnitName,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Rental Valuation Source',
          labelStyle: kFieldHeading,
          hintText: 'rental valuation source'),
//                          validator: (val) => val.isEmpty
//                              ? 'Please enter who supplied the rental valuation'
//                              : null,
      onChanged: (val) =>
          setState(() => _currentUnitRentalValuationSource = val),
    );
  }

  _displayUnitRentalValuationField() {
    return Row(
      children: <Widget>[
        Text(
          _currencySymbol,
          style: kFieldHeading,
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextFormField(
            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                initialValue: unitDetails
//                                    .data.propertyMarketValuationAmount
//                                    .toStringAsFixed(2),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'Rental Valuation',
                labelStyle: kFieldHeading,
                hintText: 'rental valuation'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter valuation amount' : null,
            onChanged: (val) => setState(
              () => _currentUnitRentalValuationAmount = double.parse(val),
            ),
          ),
        ),
      ],
    );
  }

  _displayUnitResidentialField(BuildContext context) {
    return Row(
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
          onTap: () => kShowHelpToast(
              context, "If selected the unit is residential only"),
          child: Icon(
            Icons.help_outline,
            color: kColorOrange,
          ),
        ),
      ],
    );
  }

  _displayUnitPercentageSplitField() {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              '%  ',
              style: kFieldHeading,
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextFormField(
            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'of Total Property',
                labelStyle: kFieldHeading,
                hintText: 'of total property'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
            onChanged: (val) =>
                setState(() => _currentUnitPercentageSplit = double.parse(val)),
          ),
        ),
      ],
    );
  }

  _displayUnitFloorAreaField() {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              _areaMeasurementSymbol,
              style: kFieldHeading,
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextFormField(
            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'Floor Area',
                labelStyle: kFieldHeading,
                hintText: 'floor area'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
            onChanged: (val) =>
                setState(() => _currentUnitArea = double.parse(val)),
          ),
        ),
      ],
    );
  }

  _displayUnitLeaseDescription() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'General Address of Premises',
          labelStyle: kFieldHeading,
          hintText: 'general address of premises as used on lease'),
      validator: (val) => val.isEmpty ? 'Please enter lease description' : null,
      onChanged: (val) => setState(() => _currentUnitLeaseDescription = val),
    );
  }

  _displayUnitDetailsField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Details',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentUnitNotes = val),
    );
  }

  _displayUnitNameField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      // used for initial/single/first unit for property
      initialValue: widget.defaultUnitName,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Name', labelStyle: kFieldHeading, hintText: 'unit name'),
      validator: (val) =>
          val.isEmpty ? 'Please enter what this area is know by' : null,
      onChanged: (val) => setState(() => _currentUnitName = val),
    );
  }
}
