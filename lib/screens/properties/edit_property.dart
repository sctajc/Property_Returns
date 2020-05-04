import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class EditProperty extends StatefulWidget {
  static String id = 'edit_property_screen';
  final String propertyUid;
  final String propertyName;
  EditProperty({this.propertyUid, this.propertyName});

  @override
  _EditPropertyState createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  bool _archiveProperty = false;
  final _formKey = GlobalKey<FormState>();
  String _areaMeasurementSymbol;
  String _currencySymbol = '\$';

  // form values
  String _currentPropertyName;
  String _currentPropertyNotes;
  String _currentPropertyZone;
  String _currentPropertyAddress;
  num _currentPropertyLandArea;
  DateTime _currentPropertyDatePurchased;
  String _currentPropertyRatesBillingCode;
  String _currentPropertyInsurancePolicy;
  String _currentPropertyInsuranceSource;
  DateTime _currentPropertyInsuranceExpiryDate;
  String _currentPropertyLegalDescription;
  num _currentPropertyMarketValuationAmount;
  DateTime _currentPropertyMarketValuationDate;
  String _currentPropertyMarketValuationSource;
  bool _currentPropertyArchived = false;
  DateTime _initialPropertyDatePurchased;
  DateTime _initialPropertyInsuranceExpiryDate;
  DateTime _initialPropertyMarketValuationDate;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<PropertyDetails>(
      stream:
          DatabaseServices(uid: user.userUid, propertyUid: widget.propertyUid)
              .propertyByDocumentID,
      builder: (context, propertyDetails) {
        if (!propertyDetails.hasData) return Loading();
        (propertyDetails.data.propertyDatePurchased == null)
            ? _initialPropertyDatePurchased = null
            : _initialPropertyDatePurchased =
                propertyDetails.data.propertyDatePurchased.toDate();
        (propertyDetails.data.propertyInsuranceExpiryDate == null)
            ? _initialPropertyInsuranceExpiryDate = null
            : _initialPropertyInsuranceExpiryDate =
                propertyDetails.data.propertyInsuranceExpiryDate.toDate();
        (propertyDetails.data.propertyMarketValuationDate == null)
            ? _initialPropertyMarketValuationDate = null
            : _initialPropertyMarketValuationDate =
                propertyDetails.data.propertyMarketValuationDate.toDate();
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
                  '${widget.propertyName}',
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
                        _displayPropertyNameField(propertyDetails),
                        SizedBox(
                          height: 10,
                        ),
                        _displayPropertyNotesField(propertyDetails),
                        SizedBox(
                          height: 10,
                        ),
                        _displayPropertyAddressField(propertyDetails),
                        SizedBox(
                          height: 10,
                        ),
                        _displayPropertyZoneField(propertyDetails),
                        SizedBox(
                          height: 10,
                        ),
                        _displayPropertyAreaField(propertyDetails),
                        // display date purchased
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
//                                          validator: (val) => val == null
//                                              ? 'Please enter a purchased date'
//                                              : null,
                                      initialValue:
                                          _initialPropertyDatePurchased,
                                      //DateTime.now(),
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
                        _displayPropertyRatesBillingCodeField(propertyDetails),
                        SizedBox(
                          height: 20,
                        ),
                        _displayPropertyInsurancePolicyField(propertyDetails),
                        SizedBox(
                          height: 20,
                        ),
                        _displayPropertyInsuranceSourceField(propertyDetails),
                        // display insurance expiry date
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
//                                          validator: (val) => val == null
//                                              ? 'Please enter insurance expiry date'
//                                              : null,
                                      initialValue:
                                          _initialPropertyInsuranceExpiryDate,
                                      format: DateFormat("E,  MMM d, y"),
                                      onShowPicker:
                                          (context, currentValue) async {
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
                        _displayPropertyLegalDescriptionField(propertyDetails),
                        SizedBox(
                          height: 20,
                        ),
                        _displayPropertyMarketValuationAmountField(
                            propertyDetails),
                        // display market valuation date
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
//                                          validator: (val) => val == null
//                                              ? 'Please enter insurance expiry date'
//                                              : null,
                                      initialValue:
                                          _initialPropertyMarketValuationDate,
                                      format: DateFormat("E,  MMM d, y"),
                                      onShowPicker:
                                          (context, currentValue) async {
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
                        _displayPropertyMarketValuationSourceField(
                            propertyDetails),
                        SizedBox(
                          height: 20,
                        ),
                        _displayPropertyArchiveField(context),
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
                          await DatabaseServices(
                                  propertyUid: widget.propertyUid)
                              .updateUserProperty(
                            user.userUid,
                            _currentPropertyName ??
                                propertyDetails.data.propertyName,
                            _currentPropertyNotes ??
                                propertyDetails.data.propertyNotes,
                            _currentPropertyZone ??
                                propertyDetails.data.propertyZone,
                            _currentPropertyAddress ??
                                propertyDetails.data.propertyAddress,
                            _currentPropertyLandArea ??
                                propertyDetails.data.propertyLandArea,
                            _currentPropertyDatePurchased ??
                                propertyDetails.data.propertyDatePurchased
                                    .toDate(),
                            _currentPropertyRatesBillingCode ??
                                propertyDetails.data.propertyRatesBillingCode,
                            _currentPropertyInsurancePolicy ??
                                propertyDetails.data.propertyInsurancePolicy,
                            _currentPropertyInsuranceSource ??
                                propertyDetails.data.propertyInsuranceSource,
                            _currentPropertyInsuranceExpiryDate ??
                                propertyDetails.data.propertyInsuranceExpiryDate
                                    .toDate(),
                            _currentPropertyLegalDescription ??
                                propertyDetails.data.propertyLegalDescription,
                            _currentPropertyMarketValuationAmount ??
                                propertyDetails
                                    .data.propertyMarketValuationAmount,
                            _currentPropertyMarketValuationDate ??
                                propertyDetails
                                    .data.propertyMarketValuationDate,
                            _currentPropertyMarketValuationSource ??
                                propertyDetails
                                    .data.propertyMarketValuationSource,
                            _currentPropertyArchived ??
                                propertyDetails.data.propertyArchived,
                            propertyDetails.data.propertyRecordCreatedDateTime,
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
      },
    );
  }

  _displayPropertyArchiveField(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Archive property?',
          style: kFieldHeading,
        ),
        SizedBox(
          width: 20,
        ),
        Checkbox(
          value: _archiveProperty,
          onChanged: (value) {
            setState(() {
              _archiveProperty = value;
              _currentPropertyArchived = _archiveProperty;
            });
          },
        ),
        SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () => kShowHelpToast(context,
              "If selected the property will be removed from your displayed properties. These will normally be properties which are not being managed anymore. These properties can be accessed through 'Properties Archived'"),
          child: Icon(
            Icons.help_outline,
            color: kColorOrange,
          ),
        ),
      ],
    );
  }

  _displayPropertyMarketValuationSourceField(
      AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyMarketValuationSource,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Market Valuation Source',
          labelStyle: kFieldHeading,
          hintText: 'market valuation source'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any valuation source'
//                          : null,
      onChanged: (val) =>
          setState(() => _currentPropertyMarketValuationSource = val),
    );
  }

  _displayPropertyMarketValuationAmountField(
      AsyncSnapshot<PropertyDetails> propertyDetails) {
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
            initialValue: propertyDetails.data.propertyMarketValuationAmount
                .toStringAsFixed(2),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'Market Valuation',
                labelStyle: kFieldHeading,
                hintText: 'market valuation'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter valuation amount' : null,
            onChanged: (val) => setState(
              () => _currentPropertyMarketValuationAmount = double.parse(val),
            ),
          ),
        ),
      ],
    );
  }

  _displayPropertyLegalDescriptionField(
      AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyLegalDescription,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Legal Description',
          labelStyle: kFieldHeading,
          hintText: 'legal description'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter property legal description'
//                        : null,
      onChanged: (val) =>
          setState(() => _currentPropertyLegalDescription = val),
    );
  }

  _displayPropertyInsuranceSourceField(
      AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyInsuranceSource,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Insurance Source/Broker',
          labelStyle: kFieldHeading,
          hintText: 'insurance source/broker'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance supplier'
//                          : null,
      onChanged: (val) => setState(() => _currentPropertyInsuranceSource = val),
    );
  }

  _displayPropertyInsurancePolicyField(
      AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyInsurancePolicy,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Insurance Policy',
          labelStyle: kFieldHeading,
          hintText: 'insurance policy'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
      onChanged: (val) => setState(() => _currentPropertyInsurancePolicy = val),
    );
  }

  _displayPropertyRatesBillingCodeField(
      AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyRatesBillingCode,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Rates Billing Code',
          labelStyle: kFieldHeading,
          hintText: 'rates id'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter any billing code' : null,
      onChanged: (val) =>
          setState(() => _currentPropertyRatesBillingCode = val),
    );
  }

  _displayPropertyAreaField(AsyncSnapshot<PropertyDetails> propertyDetails) {
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
          width: 20,
        ),
        Expanded(
          child: TextFormField(
            inputFormatters: [
              WhitelistingTextInputFormatter(
                RegExp("[0-9.]"),
              )
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            initialValue: propertyDetails.data.propertyLandArea.toString(),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'Land Area',
                labelStyle: kFieldHeading,
                hintText: 'land area'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
            onChanged: (val) => setState(
              () => _currentPropertyLandArea = double.parse(val),
            ),
          ),
        ),
      ],
    );
  }

  _displayPropertyZoneField(AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyZone,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Property Zoning',
          labelStyle: kFieldHeading,
          hintText: 'property zoning'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter any property zone' : null,
      onChanged: (val) => setState(() => _currentPropertyZone = val),
    );
  }

  _displayPropertyAddressField(AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyAddress,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Property Address',
          labelStyle: kFieldHeading,
          hintText: 'address'),
      validator: (val) => val.isEmpty ? 'Please enter property address' : null,
      onChanged: (val) => setState(() => _currentPropertyAddress = val),
    );
  }

  _displayPropertyNotesField(AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      initialValue: propertyDetails.data.propertyNotes,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Notes',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentPropertyNotes = val),
    );
  }

  _displayPropertyNameField(AsyncSnapshot<PropertyDetails> propertyDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      initialValue: propertyDetails.data.propertyName,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Property Name',
          labelStyle: kFieldHeading,
          hintText: 'property name'),
      validator: (val) =>
          val.isEmpty ? 'Please enter what property is know as' : null,
      onChanged: (val) => setState(() => _currentPropertyName = val),
    );
  }
}
