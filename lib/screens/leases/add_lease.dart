import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';

class AddLease extends StatefulWidget {
  static String id = 'add_lease_screen';

  @override
  _AddLeaseState createState() => _AddLeaseState();
}

class _AddLeaseState extends State<AddLease> {
  final _formKey = GlobalKey<FormState>();
  Map _propertyUnitNames = Map<String, String>();
  Map<String, String> _mapProperties = {'none': 'choose lease propert'};
  Map<String, String> _mapTenantCompanies = {'none': 'choose lease tenant'};

  // form values
  String _currentLeaseTenantSelected = '';
  String _currentLeasePropertySelected = '';
  String _currentLeaseBusinessUse = '';
  String _currentLeaseDefaultInterestRate = '';
  String _currentLeaseCarParks = '';
  String _currentLeaseRentPaymentDay = '1';
  DateTime _currentLeaseDateOfLease;
  String _currentLeaseGuarantor;
  String _currentLeaseComment = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<List<PropertyDetails>>(
      stream: DatabaseServices(uid: user.userUid).userProperties,
      builder: (context, userProperties) {
        if (!userProperties.hasData) return Loading();
        for (PropertyDetails userProperty in userProperties.data) {
          _mapProperties[userProperty.propertyUid] = userProperty.propertyName;
        }
        return StreamBuilder<List<CompanyDetails>>(
          stream: DatabaseServices(uid: user.userUid).userTenants,
          builder: (context, userTenants) {
            if (!userTenants.hasData) return Loading();
            for (CompanyDetails userTenant in userTenants.data) {
              _mapTenantCompanies[userTenant.companyUid] =
                  userTenant.companyName;
            }
            return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                title: Text(
                  'Add a new lease',
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
                        dropDownListLeaseTenant(),
                        SizedBox(
                          height: 10,
                        ),
                        dropDownListLeaseProperty(user),
                        SizedBox(
                          height: 10,
                        ),
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
                                  'lease',
                                  style: kFieldHeading,
                                ),
                                Text(
                                  'signed',
                                  style: kFieldHeading,
                                ),
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
                                      validator: (val) => val == null
                                          ? 'Please enter date lease signed'
                                          : null,
                                      initialValue: DateTime.now(),
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
                                          _currentLeaseDateOfLease = date;
                                          return _currentLeaseDateOfLease;
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
                        textFormFieldLeaseComment(),
                        SizedBox(
                          height: 10,
                        ),
                        textFormFieldLeaseCarParks(),
                        SizedBox(
                          height: 10,
                        ),
                        textFormFieldLeaseBusinessUse(),
                        SizedBox(
                          height: 10,
                        ),
                        textFormFieldLeaseDefaultInterestRate(),
                        SizedBox(
                          height: 10,
                        ),
                        textFormFieldLeaseGuarantor(),
                        SizedBox(
                          height: 10,
                        ),
                        textFormFieldLeaseRentPaymentDay(),
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
                              await DatabaseServices().addUserLease(
                            user.userUid,
                            _currentLeaseTenantSelected,
                            _currentLeasePropertySelected,
                            _currentLeaseBusinessUse,
                            _currentLeaseDefaultInterestRate,
                            _currentLeaseCarParks,
                            _currentLeaseRentPaymentDay,
                            _currentLeaseDateOfLease,
                            _currentLeaseGuarantor,
                            _currentLeaseComment,
                            false,
                            Timestamp.now(),
                            Timestamp.now(),
                          );
                          //print('docRef: ${docRef.documentID}');
                          await DatabaseServices().addUserLeaseEvent(
                            docRef.documentID,
                            user.userUid,
                            'wsAYKJiTwuS8UhRuxK5u', // leave event type
                            null, // lease commencement date
                            false, // happened
                            '', // comment
                            Timestamp.now(),
                            Timestamp.now(),
                          );

                          await DatabaseServices().addUserLeaseEvent(
                            docRef.documentID,
                            user.userUid,
                            'uc9aT7Y8VPvgMrOe06o2', // lease final Expiry date
                            null, // lease commencement date
                            false, // happened
                            '', // comment
                            Timestamp.now(),
                            Timestamp.now(),
                          );

//                        print('docRef: ${docRef.documentID}');
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

  dropDownListLeaseTenant() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Text(
            'Tenant',
            style: kFieldHeading,
          ),
        ),
        SizedBox(
          width: 30,
        ),
        Flexible(
            flex: 3,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: _currentLeaseTenantSelected,
              items: _mapTenantCompanies
                  .map(
                    (key, value) {
                      return MapEntry(
                        key,
                        DropdownMenuItem<String>(
                          child: Text(value),
                          value: key,
                        ),
                      );
                    },
                  )
                  .values
                  .toList(),
              onChanged: (String newTenantSelected) {
                setState(() {
                  _currentLeaseTenantSelected = newTenantSelected;
                });
              },
              validator: (val) =>
                  val.contains('none') ? 'Please select lease Tenant' : null,
            ))
      ],
    );
  }

  textFormFieldLeaseRentPaymentDay() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              decoration: kTextInputDecoration.copyWith(
                  labelText: 'Rent Payment Day',
                  labelStyle: kFieldHeading,
                  hintText: 'day of month'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
              onChanged: (val) =>
                  setState(() => _currentLeaseRentPaymentDay = val),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTap: () => kShowHelpToast(
                context, "The day(s) of the month the rent is due"),
            child: Icon(
              Icons.help_outline,
              color: kColorOrange,
            ),
          ),
        ],
      ),
    );
  }

  textFormFieldLeaseCarParks() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Car Parks',
          labelStyle: kFieldHeading,
          hintText: 'car parks'),
      onChanged: (val) => setState(() => _currentLeaseCarParks = val),
    );
  }

  textFormFieldLeaseDefaultInterestRate() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Dafault Interest Rate',
          labelStyle: kFieldHeading,
          hintText: 'default interest rate'),
//      validator: (val) => val.isNotEmpty && !EmailValidator.validate(val)
//          ? 'Please enter a valid email'
//          : null,
      onChanged: (val) =>
          setState(() => _currentLeaseDefaultInterestRate = val),
    );
  }

  textFormFieldLeaseBusinessUse() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Business Use',
          labelStyle: kFieldHeading,
          hintText: 'business use'),
//                      validator: (val) =>
//                          val.isEmpty ? 'Please enter a phone number' : null,
      onChanged: (val) => setState(() => _currentLeaseBusinessUse = val),
    );
  }

  textFormFieldLeaseComment() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Comments',
          labelStyle: kFieldHeading,
          hintText: 'more details'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentLeaseComment = val),
    );
  }

  textFormFieldLeaseGuarantor() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Guarantor',
          labelStyle: kFieldHeading,
          hintText: 'guarantor'),
//                    validator: (val) => val.isEmpty
//                        ? 'Please enter any property details'
//                        : null,
      onChanged: (val) => setState(() => _currentLeaseGuarantor = val),
    );
  }

  dropDownListLeaseProperty(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Text(
            'Property',
            style: kFieldHeading,
          ),
        ),
        SizedBox(
          width: 30,
        ),
        Flexible(
          flex: 3,
          child: StreamBuilder<List<UnitDetails>>(
            stream: DatabaseServices(uid: user.userUid).allUnitsForUser,
            builder: (context, allUserUnits) {
              if (!allUserUnits.hasData)
                return Loading();
              else {
                _propertyUnitNames['none'] = 'choose lease property';
                for (int i = 0; i < allUserUnits.data.length; i++) {
                  _propertyUnitNames[allUserUnits.data[i].unitUid] =
                      '${_mapProperties['${allUserUnits.data[i].propertyUid}']} - ${allUserUnits.data[i].unitName}';
                }
              }
              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currentLeasePropertySelected,
                items: _propertyUnitNames
                    .map(
                      (key, value) {
                        return MapEntry(
                          key,
                          DropdownMenuItem<String>(
                            child: Text(value),
                            value: key,
                          ),
                        );
                      },
                    )
                    .values
                    .toList(),
                onChanged: (String newPropertySelected) {
                  setState(() {
                    _currentLeasePropertySelected = newPropertySelected;
                  });
                },
                validator: (val) => val.contains('none')
                    ? 'Please select lease property'
                    : null,
              );
            },
          ),
        )
      ],
    );
  }
}
