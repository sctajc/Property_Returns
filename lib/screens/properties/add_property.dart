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

class AddProperty extends StatefulWidget {
  static String id = 'add_property_screen';

  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _propertyNameFocusNode = FocusNode();
  final FocusNode _propertyDetailsFocusNode = FocusNode();
  final FocusNode _propertyAddressFocusNode = FocusNode();
  final FocusNode _propertyZoningFocusNode = FocusNode();
  final FocusNode _propertyLandAreaFocusNode = FocusNode();
  final FocusNode _propertyRatesBillingCodeFocusNode = FocusNode();
  final FocusNode _propertyInsurancePolicyFocusNode = FocusNode();
  final FocusNode _propertyInsuranceCompanyFocusNode = FocusNode();
  final FocusNode _propertyLegalDescriptionFocusNode = FocusNode();
  final FocusNode _propertyMarketValuationFocusNode = FocusNode();
  final FocusNode _propertyMarketValuationAgentFocusNode = FocusNode();

  String areaMeasurementSymbol;
  String _currencySymbol = '\$';

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
  double _currentPropertyMarketValuationAmount;
  DateTime _currentPropertyMarketValuationDate;
  String _currentPropertyMarketValuationSource;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
      stream: DatabaseServices(uid: user.userUid).userData,
      builder: (context, userData) {
        if (!userData.hasData) return Loading();
        userData.data.areaMeasurementM2 == true
            ? areaMeasurementSymbol = 'M\u00B2'
            : areaMeasurementSymbol = 'Ft\u00B2';
        _currencySymbol = userData.data.currencySymbol;
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
                    _displayPropertyName(),
                    SizedBox(
                      height: 10,
                    ),
                    _displayPropertyDetails(),
                    SizedBox(
                      height: 10,
                    ),
                    _displayPropertyAddress(),
                    SizedBox(
                      height: 10,
                    ),
                    _displayPropertyZone(),
                    SizedBox(
                      height: 10,
                    ),
                    _displayPropertyLandArea(),
                    // date property purchased
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Date',
                              style: kFieldHeading,
                            ),
                            Text(
                              'purchased',
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
                                  onShowPicker: (context, currentValue) async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now(),
                                    );
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
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _displayPropertyRatesBillingCode(),
                    SizedBox(
                      height: 10,
                    ),
                    _displayPropertyInsurancePolicy(),
                    SizedBox(
                      height: 20,
                    ),
                    _displayPropertyInsuranceSource(),
                    // insurance expiry date
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
                              'date',
                              style: kFieldHeading,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
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
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      _currentPropertyInsuranceExpiryDate =
                                          date;
                                      return _currentPropertyInsuranceExpiryDate;
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
                      height: 20,
                    ),
                    _displayPropertyLegalDescription(),
                    SizedBox(
                      height: 20,
                    ),
                    _displayPropertyMarketValuation(),
                    // market valuation date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Market',
                              style: kFieldHeading,
                            ),
                            Text(
                              'valuation',
                              style: kFieldHeading,
                            ),
                            Text(
                              'date',
                              style: kFieldHeading,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
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
                                  validator: (val) => val == null
                                      ? 'Please enter market Valuation date'
                                      : null,
                                  initialValue: DateTime.now(),
                                  format: DateFormat("E,  MMM d, y"),
                                  onShowPicker: (context, currentValue) async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2010),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      _currentPropertyMarketValuationDate =
                                          date;
                                      return _currentPropertyMarketValuationDate;
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
                      height: 20,
                    ),
                    _displayPropertyMarketValuationSource(),
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
                          _currentPropertyMarketValuationAmount,
                          _currentPropertyMarketValuationDate,
                          _currentPropertyMarketValuationSource,
                          false,
                          Timestamp.now(),
                          Timestamp.now(),
                        );
                        //print('docRef: ${docRef.documentID}');
                        await DatabaseServices().addPropertyUnit(
                          user.userUid,
                          docRef.documentID,
                          'Details (as one unit)',
                          '',
                          '',
                          0,
                          100,
                          false,
                          0,
                          null,
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
      },
    );
  }

  _displayPropertyName() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _propertyNameFocusNode,
      textCapitalization: TextCapitalization.words,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Property Name',
          labelStyle: kFieldHeading,
          hintText: 'property name'),
      validator: (val) =>
          val.isEmpty ? 'Please enter what property is know as' : null,
      onChanged: (val) => setState(() => _currentPropertyName = val),
      onEditingComplete: _propertyNameEditingComplete,
    );
  }

  void _propertyNameEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyDetailsFocusNode);
  }

  _displayPropertyDetails() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _propertyDetailsFocusNode,
      textCapitalization: TextCapitalization.sentences,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Details',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentPropertyNotes = val),
      onEditingComplete: _propertyDetailsEditingComplete,
    );
  }

  void _propertyDetailsEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyAddressFocusNode);
  }

  _displayPropertyAddress() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      focusNode: _propertyAddressFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Address', labelStyle: kFieldHeading, hintText: 'address'),
      validator: (val) => val.isEmpty ? 'Please enter property address' : null,
      onChanged: (val) => setState(() => _currentPropertyAddress = val),
      onEditingComplete: _propertyAddressEditingComplete,
    );
  }

  void _propertyAddressEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyZoningFocusNode);
  }

  _displayPropertyZone() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _propertyZoningFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Zoning',
          labelStyle: kFieldHeading,
          hintText: 'property zoning'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter any property zone' : null,
      onChanged: (val) => setState(() => _currentPropertyZone = val),
      onEditingComplete: _propertyZoneEditingComplete,
    );
  }

  void _propertyZoneEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyLandAreaFocusNode);
  }

  _displayPropertyLandArea() {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              'Land area',
              style: kFieldHeading,
            ),
            Text(
              areaMeasurementSymbol,
              style: kFieldHeading,
            ),
          ],
        ),
        Expanded(
          child: TextFormField(
            // allow 2 decimal places
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp(r"^\d+\.?\d{0,2}")),
            ],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            focusNode: _propertyLandAreaFocusNode,
            decoration: kTextInputDecoration.copyWith(
                labelStyle: kFieldHeading, hintText: 'land area'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
            onChanged: (val) => setState(
              () => _currentPropertyLandArea = double.parse(val),
            ),
            onEditingComplete: _propertyLandAreaEditingComplete,
          ),
        ),
      ],
    );
  }

  void _propertyLandAreaEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyRatesBillingCodeFocusNode);
  }

  _displayPropertyRatesBillingCode() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _propertyRatesBillingCodeFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Rates Billing Code',
          labelStyle: kFieldHeading,
          hintText: 'rates Id'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter any billing code' : null,
      onChanged: (val) =>
          setState(() => _currentPropertyRatesBillingCode = val),
      onEditingComplete: _propertyRatesCodeEditingComplete,
    );
  }

  void _propertyRatesCodeEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyInsurancePolicyFocusNode);
  }

  _displayPropertyInsurancePolicy() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _propertyInsurancePolicyFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Insurance Policy',
          labelStyle: kFieldHeading,
          hintText: 'insurance policy number'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
      onChanged: (val) => setState(() => _currentPropertyInsurancePolicy = val),
      onEditingComplete: _propertyInsurancePolicyEditingComplete,
    );
  }

  void _propertyInsurancePolicyEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyInsuranceCompanyFocusNode);
  }

  _displayPropertyInsuranceSource() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _propertyInsuranceCompanyFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Insurance Company',
          labelStyle: kFieldHeading,
          hintText: 'insurance source/broker/company'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance supplier'
//                          : null,
      onChanged: (val) => setState(() => _currentPropertyInsuranceSource = val),
      onEditingComplete: _propertyInsuranceSourceEditingComplete,
    );
  }

  void _propertyInsuranceSourceEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyLegalDescriptionFocusNode);
  }

  _displayPropertyLegalDescription() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _propertyLegalDescriptionFocusNode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Legal Description of Premises',
          labelStyle: kFieldHeading,
          hintText: 'legal description of premises'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter property legal description'
//                        : null,
      onChanged: (val) =>
          setState(() => _currentPropertyLegalDescription = val),
      onEditingComplete: _propertyLegalDescriptionEditingComplete,
    );
  }

  void _propertyLegalDescriptionEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyMarketValuationFocusNode);
  }

  _displayPropertyMarketValuation() {
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
            inputFormatters: [
              // limit to 2 decimal places
              WhitelistingTextInputFormatter(RegExp(r"^\d+\.?\d{0,2}")),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            focusNode: _propertyMarketValuationFocusNode,
//                initialValue: 'initial description',
            decoration: kTextInputDecoration.copyWith(
                labelText: 'Market Valuation',
                labelStyle: kFieldHeading,
                hintText: 'market valuation'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter valuation amount' : null,
            onChanged: (val) => setState(
              () => _currentPropertyMarketValuationAmount = double.parse(val),
            ),
            onEditingComplete: _propertyMarketValuationEditingComplete,
          ),
        ),
      ],
    );
  }

  void _propertyMarketValuationEditingComplete() {
    FocusScope.of(context).requestFocus(_propertyMarketValuationAgentFocusNode);
  }

  _displayPropertyMarketValuationSource() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      focusNode: _propertyMarketValuationAgentFocusNode,
//                initialValue: 'initial description',
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Market Valuation Agent',
          labelStyle: kFieldHeading,
          hintText: 'market valuation source'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any valuation source'
//                          : null,
      onChanged: (val) =>
          setState(() => _currentPropertyMarketValuationSource = val),
    );
  }
}
