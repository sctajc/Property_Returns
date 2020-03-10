import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyDetails {
  final String propertyUid;
  final String userUid;
  final String propertyName;
  final String propertyNotes;
  final String propertyZone;
  final String propertyAddress;
  final double propertyLandArea;
  final Timestamp propertyDatePurchased;
  final String propertyRatesBillingCode;
  final String propertyInsurancePolicy;
  final String propertyInsuranceSource;
  final String propertyInsuranceDate;
  final String propertyLegalDescription;
  final String propertyMarketValuation;
  final String propertyMarketValuationSource;
  final bool propertyArchived;
  final Timestamp propertyRecordCreatedDateTime;
  final Timestamp propertyRecordLastEdited;

  PropertyDetails({
    this.propertyUid,
    this.propertyName,
    this.propertyAddress,
    this.propertyArchived,
    this.propertyDatePurchased,
    this.propertyInsuranceDate,
    this.propertyInsurancePolicy,
    this.propertyInsuranceSource,
    this.propertyLandArea,
    this.propertyLegalDescription,
    this.propertyMarketValuation,
    this.propertyMarketValuationSource,
    this.propertyNotes,
    this.propertyRatesBillingCode,
    this.propertyRecordCreatedDateTime,
    this.propertyZone,
    this.userUid,
    this.propertyRecordLastEdited,
  });
}

class UnitDetails {
  final String unitUid;
  final String propertyUid;
  final String userUid;
  final String unitName;
  final String unitNotes;
  final double unitArea;
  final String unitLeaseDescription;
  final bool unitResidential;
  final bool unitArchived;
  final Timestamp unitRecordCreatedDateTime;
  final Timestamp unitRecordLastEdited;

  UnitDetails({
    this.unitUid,
    this.propertyUid,
    this.unitResidential,
    this.unitRecordCreatedDateTime,
    this.unitNotes,
    this.unitName,
    this.unitLeaseDescription,
    this.unitArea,
    this.unitArchived,
    this.userUid,
    this.unitRecordLastEdited,
  });
}
