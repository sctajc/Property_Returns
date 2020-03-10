import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UnitDetails {
  final String unitUid;
  final String userUid;
  final String propertyUid;
  final String unitName;
  final String unitNotes;
  final double unitArea;
  final String unitLeaseDescription;
  final bool unitResidential;
  final bool unitArchived;
  final Timestamp unitRecordCreatedDateTime;

  UnitDetails({
    this.unitUid,
    this.propertyUid,
    this.userUid,
    this.unitArchived,
    this.unitArea,
    this.unitLeaseDescription,
    this.unitName,
    this.unitNotes,
    this.unitRecordCreatedDateTime,
    this.unitResidential,
  });
}
