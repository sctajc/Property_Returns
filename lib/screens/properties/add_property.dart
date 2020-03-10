import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class AddProperty extends StatefulWidget {
  static String id = 'add_property_screen';

  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentPropertyName;
  String _currentPropertyNotes;
  String _currentPropertyZone;
  String _currentPropertyAddress;
  double _currentPropertyLandArea;
  DateTime _currentPropertyDatePurchased;
  String _currentPropertyRatesBillingCode;
  String _currentPropertyInsurancePolicy;
  String _currentPropertyInsuranceSource;
  DateTime _currentPropertyInsuranceExpiryDate;
  String _currentPropertyLegalDescription;
  double _currentPropertyValuation;
  String _currentPropertyValuationSource;
  bool _currentPropertyArchived = false;
  DateTime _propertyRecordCreatedDateTime = DateTime.now();
  DateTime _propertyRecordLastEdited = DateTime.now();
  String error = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Add a new property',
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
//                initialValue: 'initial value',
                    decoration: kTextInputDecoration.copyWith(
                        hintText: 'property name'),
                    validator: (val) => val.isEmpty
                        ? 'Please enter what property is know as'
                        : null,
                    onChanged: (val) =>
                        setState(() => _currentPropertyName = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                    decoration:
                        kTextInputDecoration.copyWith(hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
                    onChanged: (val) =>
                        setState(() => _currentPropertyNotes = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                    decoration:
                        kTextInputDecoration.copyWith(hintText: 'address'),
                    validator: (val) =>
                        val.isEmpty ? 'Please enter property address' : null,
                    onChanged: (val) =>
                        setState(() => _currentPropertyAddress = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                    decoration: kTextInputDecoration.copyWith(
                        hintText: 'property zoning'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter any property zone' : null,
                    onChanged: (val) =>
                        setState(() => _currentPropertyZone = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Land area (M2)',
                    style: kFieldHeading,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
//                initialValue: 'initial description',
                    decoration:
                        kTextInputDecoration.copyWith(hintText: 'land area'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
                    onChanged: (val) => setState(
                        () => _currentPropertyLandArea = double.parse(val)),
                  ),
                  Text(
                    'Date purchased',
                    style: kFieldHeading,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: 200,
                        child: DateTimeField(
                          validator: (val) => val == null
                              ? 'Please enter a purchased date'
                              : null,
                          initialValue: DateTime.now(),
                          format: DateFormat("E,  MMM d, y"),
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now());
                            if (date != null) {
                              _currentPropertyDatePurchased = date;
                              return _currentPropertyDatePurchased;
                            } else {
                              return currentValue;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                    decoration: kTextInputDecoration.copyWith(
                        hintText: 'Rates billing code'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter any billing code' : null,
                    onChanged: (val) =>
                        setState(() => _currentPropertyRatesBillingCode = val),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                      decoration: kTextInputDecoration.copyWith(
                          hintText: 'Insurance policy'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
                      onChanged: (val) => setState(
                          () => _currentPropertyInsurancePolicy = val)),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                      decoration: kTextInputDecoration.copyWith(
                          hintText: 'Insurance source/broker'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance supplier'
//                          : null,
                      onChanged: (val) => setState(
                          () => _currentPropertyInsuranceSource = val)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Insurance',
                            style: kFieldHeading,
                          ),
                          Text(
                            'expiry',
                            style: kFieldHeading,
                          ),
                          Text(
                            'Date',
                            style: kFieldHeading,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 200,
                            child: DateTimeField(
                              validator: (val) => val == null
                                  ? 'Please enter insurance expiry date'
                                  : null,
                              initialValue: DateTime.now(),
                              format: DateFormat("E,  MMM d, y"),
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2010),
                                    lastDate: DateTime(2100));
                                if (date != null) {
                                  _currentPropertyInsuranceExpiryDate = date;
                                  return _currentPropertyInsuranceExpiryDate;
                                } else {
                                  return currentValue;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                    decoration: kTextInputDecoration.copyWith(
                        hintText: 'legal description'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter property legal description'
//                        : null,
                    onChanged: (val) =>
                        setState(() => _currentPropertyLegalDescription = val),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
//                initialValue: 'initial description',
                    decoration:
                        kTextInputDecoration.copyWith(hintText: 'valuation'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter valuation amount' : null,
                    onChanged: (val) => setState(
                        () => _currentPropertyValuation = double.parse(val)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
//                initialValue: 'initial description',
                      decoration: kTextInputDecoration.copyWith(
                          hintText: 'valuation source'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any valuation source'
//                          : null,
                      onChanged: (val) => setState(
                          () => _currentPropertyValuationSource = val)),
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
                    DateTime _currentEditedDateTime = DateTime.now();
                    await DatabaseServices().addUserProperty(
                        user.userUid,
                        _currentPropertyName,
                        _currentPropertyNotes,
                        _currentPropertyZone,
                        _currentPropertyAddress,
                        _currentPropertyLandArea,
                        _currentPropertyDatePurchased,
                        _currentPropertyRatesBillingCode,
                        _currentPropertyInsurancePolicy,
                        _currentPropertyInsuranceSource,
                        _currentPropertyInsuranceExpiryDate,
                        _currentPropertyLegalDescription,
                        _currentPropertyValuation,
                        _currentPropertyValuationSource,
                        _currentPropertyArchived,
                        _propertyRecordCreatedDateTime,
                        _propertyRecordLastEdited);
                    Navigator.pop(context);
                  }
                })
          ],
        ),
      ),
    );
  }
}
