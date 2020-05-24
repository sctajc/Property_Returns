import 'package:cloud_firestore/cloud_firestore.dart';

class LeaseDetails {
  final String leaseUid;
  final String userUid;
  final String tenantUid;
  final String unitUid;
  final String leaseBusinessUse;
  final String leaseDefaultInterestRate;
  final String leaseCarParks;
  final String leaseRentPaymentDay;
  final Timestamp leaseDateOfLease;
  final String leaseGuarantor;
  final String leaseComment;
  final bool leaseArchived;
  final Timestamp leaseRecordCreatedDateTime;
  final Timestamp leaseRecordLastEdited;

  LeaseDetails({
    this.leaseUid,
    this.userUid,
    this.tenantUid,
    this.unitUid,
    this.leaseBusinessUse,
    this.leaseDefaultInterestRate,
    this.leaseCarParks,
    this.leaseRentPaymentDay,
    this.leaseDateOfLease,
    this.leaseGuarantor,
    this.leaseComment,
    this.leaseArchived,
    this.leaseRecordCreatedDateTime,
    this.leaseRecordLastEdited,
  });
}

class LeaseEventDetails {
  final String leaseEventUid;
  final String leaseUid;
  final String userUid;
  final String leaseEventType;
  final Timestamp leaseEventDate;
  final bool leaseEventHappened;
  final String leaseEventComment;
  final Timestamp leaseEventRecordCreatedDateTime;
  final Timestamp leaseEventRecordLastEdited;

  LeaseEventDetails({
    this.leaseEventUid,
    this.leaseUid,
    this.userUid,
    this.leaseEventType,
    this.leaseEventDate,
    this.leaseEventHappened,
    this.leaseEventComment,
    this.leaseEventRecordCreatedDateTime,
    this.leaseEventRecordLastEdited,
  });
}

class LeaseEventTypeDetails {
  final String leaseEventTypeUid;
  final int leaseEventTypeOrder;
  final String leaseEventTypeName;

  LeaseEventTypeDetails({
    this.leaseEventTypeUid,
    this.leaseEventTypeOrder,
    this.leaseEventTypeName,
  });
}
