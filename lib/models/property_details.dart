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
  final num propertyMarketValuationAmount;
  final Timestamp propertyMarketValuationDate;
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
    this.propertyMarketValuationAmount,
    this.propertyMarketValuationDate,
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
  final num unitPercentageSplit;
  final String unitLeaseDescription;
  final bool unitResidential;
  final num unitRentalValuationAmount;
  final Timestamp unitRentalValuationDate;
  final String unitRentalValuationSource;
  final bool unitArchived;
  final Timestamp unitRecordCreatedDateTime;
  final Timestamp unitRecordLastEdited;

  UnitDetails({
    this.unitUid,
    this.propertyUid,
    this.unitRecordCreatedDateTime,
    this.unitNotes,
    this.unitName,
    this.unitLeaseDescription,
    this.unitArea,
    this.unitPercentageSplit,
    this.unitResidential,
    this.unitRentalValuationAmount,
    this.unitRentalValuationDate,
    this.unitRentalValuationSource,
    this.unitArchived,
    this.userUid,
    this.unitRecordLastEdited,
  });
}
