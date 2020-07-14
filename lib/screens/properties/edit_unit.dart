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

class EditUnit extends StatefulWidget {
  final String propertyName;
  final String unitName;
  final String unitUid;
  EditUnit({this.propertyName, this.unitUid, this.unitName});

  @override
  _EditUnitState createState() => _EditUnitState();
}

class _EditUnitState extends State<EditUnit> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _unitNameFocusNode = FocusNode();
  final FocusNode _unitDetailsFocusNode = FocusNode();
  final FocusNode _unitAddressFocusNode = FocusNode();
  final FocusNode _unitFloorAreaFocusNode = FocusNode();
  final FocusNode _unitPercentageOfPropertyFocusNode = FocusNode();
  final FocusNode _unitRentalValuationAmountFocusNode = FocusNode();
  final FocusNode _unitRentalValuationSourceFocusNode = FocusNode();

  bool residentialUnit = false;
  bool _currentUnitRentalValuationDateCancelled = false;
  bool archiveUnit = false;

  String areaMeasurementSymbol;
  String _currencySymbol = '\$';

// form values
  String _currentUnitName;
  String _currentUnitNotes;
  String _currentUnitLeaseDescription;
  num _currentUnitArea;
  num _currentUnitPercentageSplit;
  bool _currentUnitResidential;
  num _currentUnitRentalValuationAmount;
  DateTime _currentUnitRentalValuationDate;
  String _currentUnitRentalValuationSource;
  bool _currentUnitArchived = false;

  DateTime _initialUnitRentalValuationDate;

  // TODO should this be a Streambuilder under build?
  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection("units")
        .document(widget.unitUid)
        .snapshots()
        .listen((snapshot) {
      residentialUnit = snapshot.data['unitResidential'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UnitDetails>(
      stream: DatabaseServices(uid: user.userUid, unitUid: widget.unitUid)
          .unitByDocumentID,
      builder: (context, unitDetails) {
        if (!unitDetails.hasData) return Loading();

        (unitDetails.data.unitRentalValuationDate == null)
            ? _initialUnitRentalValuationDate = null
            : _initialUnitRentalValuationDate =
                unitDetails.data.unitRentalValuationDate.toDate();

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
                    '${widget.unitName} in ${widget.propertyName}',
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
                            _displayUnitName(unitDetails),
                            SizedBox(
                              height: 10,
                            ),
                            _displayUnitDetails(unitDetails),
                            SizedBox(
                              height: 10,
                            ),
                            _displayUnitLeaseDescription(unitDetails),
                            SizedBox(
                              height: 10,
                            ),
                            _displayUnitFloorArea(unitDetails),
                            SizedBox(
                              height: 10,
                            ),
                            _displayUnitPercentageOfProperty(unitDetails),
                            SizedBox(
                              height: 20,
                            ),
                            _displayUnitResidential(context),
                            SizedBox(
                              height: 20,
                            ),
                            _displayUnitRentalValuationAmount(unitDetails),
                            // display rental valuation date
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
                                          onChanged: (val) => val == null
                                              ? _currentUnitRentalValuationDateCancelled =
                                                  true
                                              : null,
//                                          validator: (val) => val == null
//                                              ? 'Please enter insurance expiry date'
//                                              : null,
                                          initialValue:
                                              _initialUnitRentalValuationDate,
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
                            _displayUnitRentalValuationSource(unitDetails),
                            SizedBox(
                              height: 20,
                            ),
                            _displayUnitArchive(context),
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
                            // to handle a date from database which is not
                            // and has not been edited. Has error trying to do
                            // .toDate() on null
                            DateTime _tempUnitRentalValuationDate;
                            if (unitDetails.data.unitRentalValuationDate !=
                                null) {
                              _tempUnitRentalValuationDate = unitDetails
                                  .data.unitRentalValuationDate
                                  .toDate();
                            }
                            // if a date had been entered then user deleted date
                            if (_currentUnitRentalValuationDateCancelled ==
                                true) {
                              print('cancelled');
                              _currentUnitRentalValuationDate = null;
                              _tempUnitRentalValuationDate = null;
                            }

                            await DatabaseServices(unitUid: widget.unitUid)
                                .updatePropertyUnit(
                              user.userUid,
                              unitDetails.data.propertyUid,
                              _currentUnitName ?? unitDetails.data.unitName,
                              _currentUnitNotes ?? unitDetails.data.unitNotes,
                              _currentUnitLeaseDescription ??
                                  unitDetails.data.unitLeaseDescription,
                              _currentUnitArea ?? unitDetails.data.unitArea,
                              _currentUnitPercentageSplit ??
                                  unitDetails.data.unitPercentageSplit,
                              _currentUnitResidential ??
                                  unitDetails.data.unitResidential,
                              _currentUnitRentalValuationAmount ??
                                  unitDetails.data.unitRentalValuationAmount,
                              _currentUnitRentalValuationDate ??
                                  _tempUnitRentalValuationDate,
                              _currentUnitRentalValuationSource ??
                                  unitDetails.data.unitRentalValuationSource,
                              _currentUnitArchived ??
                                  unitDetails.data.unitArchived,
                              unitDetails.data.unitRecordCreatedDateTime,
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
            });
      },
    );
  }

  _displayUnitName(AsyncSnapshot<UnitDetails> unitDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _unitNameFocusNode,
      textCapitalization: TextCapitalization.words,
      initialValue: unitDetails.data.unitName,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Unit Name',
          labelStyle: kFieldHeading,
          hintText: 'unit name'),
      validator: (val) =>
          val.isEmpty ? 'Please enter what this unit is know by' : null,
      onChanged: (val) => setState(() => _currentUnitName = val),
      onEditingComplete: _unitNameEditingComplete,
    );
  }

  void _unitNameEditingComplete() {
    FocusScope.of(context).requestFocus(_unitDetailsFocusNode);
  }

  _displayUnitDetails(AsyncSnapshot<UnitDetails> unitDetails) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _unitDetailsFocusNode,
      textCapitalization: TextCapitalization.sentences,
      initialValue: unitDetails.data.unitNotes,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Details',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentUnitNotes = val),
      onEditingComplete: _unitDetailsEditingComplete,
    );
  }

  void _unitDetailsEditingComplete() {
    FocusScope.of(context).requestFocus(_unitAddressFocusNode);
  }

  _displayUnitLeaseDescription(AsyncSnapshot<UnitDetails> unitDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _unitAddressFocusNode,
      textCapitalization: TextCapitalization.words,
      initialValue: unitDetails.data.unitLeaseDescription,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'General Address of Premises',
          labelStyle: kFieldHeading,
          hintText: 'general address of premises as used on lease'),
      validator: (val) =>
          val.isEmpty ? 'Please enter a lease description' : null,
      onChanged: (val) => setState(() => _currentUnitLeaseDescription = val),
      onEditingComplete: _unitAddressEditingComplete,
    );
  }

  void _unitAddressEditingComplete() {
    FocusScope.of(context).requestFocus(_unitFloorAreaFocusNode);
  }

  _displayUnitFloorArea(AsyncSnapshot<UnitDetails> unitDetails) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              areaMeasurementSymbol,
              style: kFieldHeading,
            ),
          ],
        ),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: TextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _unitFloorAreaFocusNode,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp(r"^\d+\.?\d{0,2}")),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            initialValue: unitDetails.data.unitArea.toString(),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'Unit Area',
                labelStyle: kFieldHeading,
                hintText: 'unit area'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
            onChanged: (val) => setState(
              () => _currentUnitArea = double.parse(val),
            ),
            onEditingComplete: _unitFloorAreaEditingComplete,
          ),
        ),
      ],
    );
  }

  void _unitFloorAreaEditingComplete() {
    FocusScope.of(context).requestFocus(_unitPercentageOfPropertyFocusNode);
  }

  _displayUnitPercentageOfProperty(AsyncSnapshot<UnitDetails> unitDetails) {
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
          width: 20,
        ),
        Expanded(
          child: TextFormField(
            textInputAction: TextInputAction.next,
            focusNode: _unitPercentageOfPropertyFocusNode,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp(r"^\d+\.?\d{0,2}")),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            initialValue: unitDetails.data.unitPercentageSplit.toString(),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'of Property Area',
                labelStyle: kFieldHeading,
                hintText: 'of property area'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter land area' : null,
//                  validator: (val) => val.isNotEmpty? ,
            onChanged: (val) => setState(
              () => _currentUnitPercentageSplit = double.parse(val),
            ),
            onEditingComplete: _unitPercentageOfPropertyEditingComplete,
          ),
        ),
      ],
    );
  }

  void _unitPercentageOfPropertyEditingComplete() {
    FocusScope.of(context).requestFocus(_unitRentalValuationAmountFocusNode);
  }

  _displayUnitResidential(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Residential?',
        style: kFieldHeading,
      ),
      value: residentialUnit,
      onChanged: (value) {
        setState(() {
          residentialUnit = value;
          _currentUnitResidential = residentialUnit;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(
            context, "If selected the unit is residential only'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }

  _displayUnitRentalValuationAmount(AsyncSnapshot<UnitDetails> unitDetails) {
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
            textInputAction: TextInputAction.next,
            focusNode: _unitRentalValuationAmountFocusNode,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp(r"^\d+\.?\d{0,2}")),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            initialValue:
                unitDetails.data.unitRentalValuationAmount.toStringAsFixed(2),
            decoration: kTextInputDecoration.copyWith(
                labelText: 'Rental Valuation',
                labelStyle: kFieldHeading,
                hintText: 'rental valuation'),
//                    validator: (val) =>
//                        val.isEmpty ? 'Please enter valuation amount' : null,
            onChanged: (val) => setState(
              () => _currentUnitRentalValuationAmount = double.parse(val),
            ),
            onEditingComplete: _unitRentalValuationAmountEditingComplete,
          ),
        ),
      ],
    );
  }

  void _unitRentalValuationAmountEditingComplete() {
    FocusScope.of(context).requestFocus(_unitRentalValuationSourceFocusNode);
  }

  _displayUnitRentalValuationSource(AsyncSnapshot<UnitDetails> unitDetails) {
    return TextFormField(
      textInputAction: TextInputAction.done,
      focusNode: _unitRentalValuationSourceFocusNode,
      initialValue: unitDetails.data.unitRentalValuationSource,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Rental Valuation Source',
          labelStyle: kFieldHeading,
          hintText: 'rental valuation source'),
//                              validator: (val) => val.isEmpty
//                                  ? 'Please enter who supplied the rental valuation'
//                                  : null,
      onChanged: (val) =>
          setState(() => _currentUnitRentalValuationSource = val),
    );
  }

  _displayUnitArchive(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Archive unit?',
        style: kFieldHeading,
      ),
      value: archiveUnit,
      onChanged: (value) {
        setState(() {
          archiveUnit = value;
          _currentUnitArchived = archiveUnit;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(context,
            "If selected this unit will be removed from your displayed units for this property. These will normally be units that for some reason don't exist any more. These units can be accessed through 'Units Archived'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }
}
