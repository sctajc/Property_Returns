import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyDetails {
  final String propertyUid;
  final String userUid;
  final String propertyName;
  final String propertyNotes;
  final String propertyAddress;
  final String propertyZone;
  final num propertyLandArea;
  final Timestamp propertyDatePurchased;
  final String propertyRatesBillingCode;
  final String propertyInsurancePolicy;
  final String propertyInsuranceSource;
  final Timestamp propertyInsuranceExpiryDate;
  final String propertyLegalDescription;
  final num propertyMarketValuation;
  final String propertyMarketValuationSource;
  final bool propertyArchived;
  final Timestamp propertyRecordCreatedDateTime;
  final Timestamp propertyRecordLastEdited;

  PropertyDetails({
    this.propertyUid,
    this.userUid,
    this.propertyName,
    this.propertyAddress,
    this.propertyZone,
    this.propertyDatePurchased,
    this.propertyInsuranceExpiryDate,
    this.propertyInsurancePolicy,
    this.propertyInsuranceSource,
    this.propertyLandArea,
    this.propertyLegalDescription,
    this.propertyMarketValuation,
    this.propertyMarketValuationSource,
    this.propertyNotes,
    this.propertyRatesBillingCode,
    this.propertyArchived,
    this.propertyRecordCreatedDateTime,
    this.propertyRecordLastEdited,
  });
}

class UnitDetails {
  final String unitUid;
  final String propertyUid;
  final String userUid;
  final String unitName;
  final String unitNotes;
  final num unitArea;
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
