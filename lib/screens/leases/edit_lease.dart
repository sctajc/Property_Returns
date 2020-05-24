import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/services/database.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:property_returns/models/lease_details.dart';

class EditLease extends StatefulWidget {
  static String id = 'edit_lease_screen';
  final String leaseUid;
  final String tenantName;
  final String propertyName;

  EditLease({
    this.leaseUid,
    this.tenantName,
    this.propertyName,
  });

  @override
  _EditLeaseState createState() => _EditLeaseState();
}

class _EditLeaseState extends State<EditLease> {
  bool _archiveLease = false;
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentLeaseTenantSelected = 'i';
  String _currentLeasePropertySelected = 'i';
  String _currentLeaseBusinessUse = 'i';
  String _currentLeaseDefaultInterestRate = 'i';
  String _currentLeaseCarParks = 'i';
  String _currentLeaseRentPaymentDay = 'i';
  DateTime _currentLeaseDateOfLease;
  String _currentLeaseGuarantor = 'i';
  String _currentLeaseComment = 'i';
  bool _currentLeaseArchived = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<LeaseDetails>(
      stream: DatabaseServices(uid: user.userUid, leaseUid: widget.leaseUid)
          .leaseByDocumentID,
      builder: (context, leaseDetails) {
        if (!leaseDetails.hasData) return Loading();

        _currentLeaseTenantSelected = leaseDetails.data.tenantUid;
        _currentLeasePropertySelected = leaseDetails.data.unitUid;
        _currentLeaseDateOfLease = leaseDetails.data.leaseDateOfLease.toDate();

        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(
              'Edit lease',
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
                    Text(
                      '${widget.tenantName}',
                      style: kFieldHeading,
                    ),
                    Text(
                      '${widget.propertyName}',
                      style: kFieldHeading,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Lease Date Of Lease
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
                                  initialValue: _currentLeaseDateOfLease,
                                  format: DateFormat("E,  MMM d, y"),
                                  onShowPicker: (context, currentValue) async {
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
                    _displayLeaseComments(leaseDetails),
                    SizedBox(
                      height: 10,
                    ),
                    _displayLeaseCarParks(leaseDetails),
                    SizedBox(
                      height: 20,
                    ),
                    _displayLeaseBusinessUse(leaseDetails),
                    SizedBox(
                      height: 20,
                    ),
                    _displayDefaultInterestRate(leaseDetails),
                    SizedBox(
                      height: 20,
                    ),
                    _displayLeaseGuarantor(leaseDetails),
                    SizedBox(
                      height: 20,
                    ),
                    _displayLeaseRentPaymentDay(leaseDetails),
                    SizedBox(
                      height: 1,
                    ),
                    _displayLeaseArchive(context),
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
                      if (_currentLeaseGuarantor == 'i')
                        _currentLeaseGuarantor =
                            leaseDetails.data.leaseGuarantor;
                      if (_currentLeaseCarParks == 'i')
                        _currentLeaseCarParks = leaseDetails.data.leaseCarParks;
                      if (_currentLeaseComment == 'i')
                        _currentLeaseComment = leaseDetails.data.leaseComment;
                      if (_currentLeaseRentPaymentDay == 'i')
                        _currentLeaseRentPaymentDay =
                            leaseDetails.data.leaseRentPaymentDay;
                      if (_currentLeaseDefaultInterestRate == 'i')
                        _currentLeaseDefaultInterestRate =
                            leaseDetails.data.leaseDefaultInterestRate;
                      if (_currentLeaseBusinessUse == 'i')
                        _currentLeaseBusinessUse =
                            leaseDetails.data.leaseBusinessUse;
                      print(
                          '_currentLeasePropertySelected: $_currentLeasePropertySelected');
                      await DatabaseServices(leaseUid: widget.leaseUid)
                          .updateUserLease(
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
                        _currentLeaseArchived,
                        leaseDetails.data.leaseRecordCreatedDateTime,
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

  _displayLeaseComments(AsyncSnapshot<LeaseDetails> leaseDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      initialValue: leaseDetails.data.leaseComment,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Comment', labelStyle: kFieldHeading, hintText: 'comment'),
//      validator: (val) => val.isNotEmpty && !EmailValidator.validate(val)
//          ? 'Please enter a valid email'
//          : null,
      onChanged: (val) => setState(() => _currentLeaseComment = val),
    );
  }

  _displayLeaseArchive(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        'Archive lease',
        style: kFieldHeading,
      ),
      value: _archiveLease,
      onChanged: (value) {
        setState(() {
          _archiveLease = value;
          _currentLeaseArchived = _archiveLease;
        });
      },
      secondary: GestureDetector(
        onTap: () => kShowHelpToast(
            context,
            "If selected the lease will be removed from your displayed leases. "
            "These will normally be leases which are expired."
            " These leases can be accessed through 'Lease Archived'"),
        child: Icon(
          Icons.help_outline,
          color: kColorOrange,
        ),
      ),
    );
  }

  _displayLeaseGuarantor(AsyncSnapshot<LeaseDetails> leaseDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      initialValue: leaseDetails.data.leaseGuarantor,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Guarantor',
          labelStyle: kFieldHeading,
          hintText: 'guarantor'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
      onChanged: (val) => setState(() => _currentLeaseGuarantor = val),
    );
  }

  _displayDefaultInterestRate(AsyncSnapshot<LeaseDetails> leaseDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      initialValue: leaseDetails.data.leaseDefaultInterestRate,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Default interest rate',
          labelStyle: kFieldHeading,
          hintText: 'default interest rate'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
      onChanged: (val) =>
          setState(() => _currentLeaseDefaultInterestRate = val),
    );
  }

  _displayLeaseBusinessUse(AsyncSnapshot<LeaseDetails> leaseDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      initialValue: leaseDetails.data.leaseBusinessUse,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Business use',
          labelStyle: kFieldHeading,
          hintText: 'business use'),
//                      validator: (val) => val.isEmpty
//                          ? 'Please enter any insurance policy name, code etc'
//                          : null,
      onChanged: (val) => setState(() => _currentLeaseBusinessUse = val),
    );
  }

  _displayLeaseCarParks(AsyncSnapshot<LeaseDetails> leaseDetails) {
    return TextFormField(
      keyboardType: TextInputType.text,
      initialValue: leaseDetails.data.leaseCarParks,
      decoration: kTextInputDecoration.copyWith(
          labelText: 'Car parks',
          labelStyle: kFieldHeading,
          hintText: 'car parks'),
//      validator: (val) => val.isNotEmpty && !isURL(val)
//          ? 'Please enter car parking details'
//          : null,
      onChanged: (val) => setState(() => _currentLeaseCarParks = val),
    );
  }

  _displayLeaseRentPaymentDay(AsyncSnapshot<LeaseDetails> leaseDetails) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.text,
              initialValue: leaseDetails.data.leaseRentPaymentDay,
              decoration: kTextInputDecoration.copyWith(
                  labelText: 'Rent payment day(s) of month',
                  labelStyle: kFieldHeading,
                  hintText: 'rent payment day'),
//      validator: (val) => val.isNotEmpty && !isURL(val)
//          ? 'Please enter day rent due'
//          : null,
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
}
