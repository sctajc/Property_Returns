import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyDetails {
  final String companyUid;
  final String userUid;
  final String companyName;
  final String companyComment;
  final String companyPhone;
  final String companyEmail;
  final String companyWebsite;
  final String companyPostalAddress;
  final bool companySetTenant;
  final bool companySetTrade;
  final bool companySetAgent;
  final bool companyArchived;
  final Timestamp companyRecordCreatedDateTime;
  final Timestamp companyRecordLastEdited;

  CompanyDetails({
    this.companyUid,
    this.userUid,
    this.companyName,
    this.companyComment,
    this.companyPhone,
    this.companyEmail,
    this.companyWebsite,
    this.companyPostalAddress,
    this.companySetTenant,
    this.companySetTrade,
    this.companySetAgent,
    this.companyArchived,
    this.companyRecordCreatedDateTime,
    this.companyRecordLastEdited,
  });
}

class PersonDetails {
  final String personUid;
  final String companyUid;
  final String userUid;
  final String personName;
  final String personPhone;
  final String personEmail;
  final String personRole;
  final String personComment;
  final bool personArchived;
  final Timestamp personRecordCreatedDateTime;
  final Timestamp personRecordLastEdited;

  PersonDetails({
    this.personUid,
    this.companyUid,
    this.userUid,
    this.personName,
    this.personPhone,
    this.personEmail,
    this.personRole,
    this.personComment,
    this.personArchived,
    this.personRecordCreatedDateTime,
    this.personRecordLastEdited,
  });
}
