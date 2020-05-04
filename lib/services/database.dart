import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/user_details.dart';
import 'package:property_returns/models/company_details.dart';

class DatabaseServices {
  final String uid; // user uid
  final String taskID; // task id
  final String propertyUid;
  final String unitUid;
  final String companyUid;
  final String personUid;

  DatabaseServices(
      {this.uid,
      this.taskID,
      this.propertyUid,
      this.unitUid,
      this.companyUid,
      this.personUid});

  // collection reference shorthand
  final CollectionReference userDetailsCollection =
      Firestore.instance.collection('user_details');

  final CollectionReference userTaskCollection =
      Firestore.instance.collection('tasks');

  final CollectionReference userPropertyCollection =
      Firestore.instance.collection('properties');

  final CollectionReference userUnitCollection =
      Firestore.instance.collection('units');

  final CollectionReference userCompanyCollection =
      Firestore.instance.collection('companies');

  final CollectionReference userPersonCollection =
      Firestore.instance.collection('persons');

  //
  //
  // UserDetails (does not include userUid)
  //
  Future updateUserDetails(
      String userName,
      int leaseNotificationDays,
      int taskNotificationDays,
      bool areaMeasurementM2,
      String currencySymbol) async {
    return await userDetailsCollection.document(uid).setData(
      {
        'user_name': userName,
        'lease_notification_days': leaseNotificationDays,
        'task_notification_days': taskNotificationDays,
        'areaMeasurementM2': areaMeasurementM2,
        'currencySymbol': currencySymbol,
      },
    );
  }

  //
  // list all users - only here for example sake
  //
  // get UserDetails stream
  Stream<List<UserDetails>> get users {
    return userDetailsCollection
        .orderBy('user_name')
        .snapshots()
        .map(_userListFromSnapshot);
  }

  List<UserDetails> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map(
      (doc) {
        return UserDetails(
          userName: doc.data['user_name'] ?? '',
          leaseNotificationDays: doc.data['lease_notification_days'] ?? 0,
          taskNotificationDays: doc.data['task_notification_days'] ?? 0,
        );
      },
    ).toList();
  }

  //
  // UserData (part of user model & includes userUid)
  //
  // get UserData stream
  Stream<UserData> get userData {
    return userDetailsCollection
        .document(uid)
        .snapshots()
        .map(_userDetailsFromSnapshot);
  }

  UserData _userDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      userUid: uid,
      userName: snapshot.data['user_name'],
      leaseNotificationDays: snapshot.data['lease_notification_days'],
      taskNotificationDays: snapshot.data['task_notification_days'],
      areaMeasurementM2: snapshot.data['areaMeasurementM2'],
      currencySymbol: snapshot.data['currencySymbol'],
    );
  }

  //
  // TASKS
  //
  // add a task
  Future addUserTask(
    String userUid,
    String taskTitle,
    String taskDetail,
    bool taskArchived,
    int taskImportance,
    String taskUnitUid,
    String taskTenantUid,
    DateTime taskDueDateTime,
    Timestamp taskEditedDateTime,
  ) async {
    return await userTaskCollection.document().setData(
      {
        'userUid': userUid,
        'title': taskTitle,
        'detail': taskDetail,
        'archived': taskArchived,
        'importance': taskImportance,
        'unitUid': taskUnitUid,
        'tenantUid': taskTenantUid,
        'dueDateTime': taskDueDateTime,
        'editedDateTime': taskEditedDateTime,
      },
    );
  }

  // update a task
  Future updateUserTask(
    String taskID,
    String userUid,
    String taskTitle,
    String taskDetail,
    bool taskArchived,
    int taskImportance,
    DateTime taskDueDateTime,
    String taskUnitUid,
    String taskTenantUid,
    Timestamp taskEditedDateTime,
  ) async {
    return await userTaskCollection.document(taskID).updateData(
      {
        'userUid': userUid,
        'title': taskTitle,
        'detail': taskDetail,
        'archived': taskArchived,
        'importance': taskImportance,
        'dueDateTime': taskDueDateTime,
        'unitUid': taskUnitUid,
        'tenantUid': taskTenantUid,
        'editedDateTime': taskEditedDateTime,
      },
    );
  }

  // get Task Details stream for a given task
  Stream<TaskDetails> get taskByDocumentID {
    return userTaskCollection
        .document(taskID)
        .snapshots()
        .map(_tasksDetailsFromSnapshot);
  }

  TaskDetails _tasksDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return TaskDetails(
      taskID: snapshot.documentID,
      userUid: uid,
      taskTitle: snapshot.data['title'] ?? 'no title',
      taskDetail: snapshot.data['detail'] ?? 'no detail',
      taskArchived: snapshot.data['archived'] ?? false,
      taskImportance: snapshot.data['importance'] ?? 5,
      taskDueDateTime: snapshot.data['dueDateTime'] ?? DateTime.now(),
      taskUnitUid: snapshot.data['unitUid'] ?? 'none',
      taskTenantUid: snapshot.data['tenantUid'] ?? 'none',
      taskLastEditedDateTime: snapshot.data['editedDateTime'] ?? DateTime.now(),
    );
  }

  // get TaskDetails stream for a given user ordered by importance
  // for home summary screen
  Stream<List<TaskDetails>> get userTasksByImportance {
    return userTaskCollection
        .where('userUid', isEqualTo: uid)
        .where('archived', isEqualTo: false)
        .orderBy('importance', descending: true)
//        .limit(8)
        .snapshots()
        .map(_userTasksFromSnapshot);
  }

  // get TaskDetails stream for a given user ordered by dueDateTime descending
  Stream<List<TaskDetails>> get userTasksByDueDateEarliestFirst {
    return userTaskCollection
        .where('userUid', isEqualTo: uid)
        .where('archived', isEqualTo: false)
        .orderBy('dueDateTime', descending: false)
        .snapshots()
        .map(_userTasksFromSnapshot);
  }

  // get TaskDetails stream for a given user ordered by dueDateTime ascending
  Stream<List<TaskDetails>> get userTasksByDueDateLatestFirst {
    return userTaskCollection
        .where('userUid', isEqualTo: uid)
        .where('archived', isEqualTo: false)
        .orderBy('dueDateTime', descending: true)
        .snapshots()
        .map(_userTasksFromSnapshot);
  }

  // get TaskDetails stream for a given user ordered by importance descending
  Stream<List<TaskDetails>> get userTasksByImportanceHighestFirst {
    return userTaskCollection
        .where('userUid', isEqualTo: uid)
        .where('archived', isEqualTo: false)
        .orderBy('importance', descending: true)
        .snapshots()
        .map(_userTasksFromSnapshot);
  }

  //
  // get TaskDetails stream for a given user ordered by importance ascending
  Stream<List<TaskDetails>> get userTasksByImportanceLowestFirst {
    return userTaskCollection
        .where('userUid', isEqualTo: uid)
        .where('archived', isEqualTo: false)
        .orderBy('importance', descending: false)
        .snapshots()
        .map(_userTasksFromSnapshot);
  }

  List<TaskDetails> _userTasksFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map(
      (doc) {
        return TaskDetails(
          taskID: doc.documentID,
          userUid: uid,
          taskTitle: doc.data['title'] ?? 'no title',
          taskDetail: doc.data['detail'] ?? 'no detail',
          taskArchived: doc.data['archived'] ?? false,
          taskImportance: doc.data['importance'] ?? 5,
          taskDueDateTime: doc.data['dueDateTime'] ?? Timestamp.now(),
          taskLastEditedDateTime: doc.data['editedDateTime'] ?? Timestamp.now(),
        );
      },
    ).toList();
  }

  //

  //
  // simple way to get all tasks in database for a user
  // not using a model (TaskDetails in this case)
  Stream<QuerySnapshot> get allTasks {
    return userTaskCollection
        .where('userUid', isEqualTo: uid)
        .where('archived', isEqualTo: false)
        .orderBy('importance')
        .snapshots();
  }

//
// **********  Property (& then Units below) **********
//

  // add a property
  Future addUserProperty(
    String userUid,
    String propertyName,
    String propertyNotes,
    String propertyZone,
    String propertyAddress,
    double propertyLandArea,
    DateTime propertyDatePurchased,
    String propertyRatesBillingCode,
    String propertyInsurancePolicy,
    String propertyInsuranceSource,
    DateTime propertyInsuranceExpiryDate,
    String propertyLegalDescription,
    double propertyMarketValuationAmount,
    DateTime propertyMarketValuationDate,
    String propertyMarketValuationSource,
    bool propertyArchived,
    Timestamp propertyRecordCreatedDateTime,
    Timestamp propertyRecordLastEdited,
  ) async {
    DocumentReference document =
        userPropertyCollection.document(); //new document is created here
    await document.setData(
      {
        'userUid': userUid,
        'propertyName': propertyName,
        'propertyNotes': propertyNotes,
        'propertyZone': propertyZone,
        'propertyAddress': propertyAddress,
        'propertyLandArea': propertyLandArea,
        'propertyDatePurchased': propertyDatePurchased,
        'propertyRatesBillingCode': propertyRatesBillingCode,
        'propertyInsurancePolicy': propertyInsurancePolicy,
        'propertyInsuranceSource': propertyInsuranceSource,
        'propertyInsuranceExpiryDate': propertyInsuranceExpiryDate,
        'propertyLegalDescription': propertyLegalDescription,
        'propertyMarketValuationAmount': propertyMarketValuationAmount,
        'propertyMarketValuationDate': propertyMarketValuationDate,
        'propertyMarketValuationSource': propertyMarketValuationSource,
        'propertyArchived': propertyArchived,
        'propertyRecordCreatedDateTime': propertyRecordCreatedDateTime,
        'propertyRecordLastEdited': propertyRecordLastEdited,
      },
    );
    // returns the document after setting the data finishes so in this way, your docRef must not be null anymore.
    return document;
  }

  // update a property
  Future updateUserProperty(
    String userUid,
    String propertyName,
    String propertyNotes,
    String propertyZone,
    String propertyAddress,
    num propertyLandArea,
    DateTime propertyDatePurchased,
    String propertyRatesBillingCode,
    String propertyInsurancePolicy,
    String propertyInsuranceSource,
    DateTime propertyInsuranceExpiryDate,
    String propertyLegalDescription,
    num propertyMarketValuationAmount,
    DateTime propertyMarketValuationDate,
    String propertyValuationSource,
    bool propertyArchived,
    Timestamp propertyRecordCreatedDateTime,
    Timestamp propertyRecordLastEdited,
  ) async {
    return await userPropertyCollection.document(propertyUid).updateData(
      {
        'userUid': userUid,
        'propertyName': propertyName,
        'propertyNotes': propertyNotes,
        'propertyZone': propertyZone,
        'propertyAddress': propertyAddress,
        'propertyLandArea': propertyLandArea,
        'propertyDatePurchased': propertyDatePurchased,
        'propertyRatesBillingCode': propertyRatesBillingCode,
        'propertyInsurancePolicy': propertyInsurancePolicy,
        'propertyInsuranceSource': propertyInsuranceSource,
        'propertyInsuranceExpiryDate': propertyInsuranceExpiryDate,
        'propertyLegalDescription': propertyLegalDescription,
        'propertyMarketValuationAmount': propertyMarketValuationAmount,
        'propertyMarketValuationDate': propertyMarketValuationDate,
        'propertyMarketValuationSource': propertyValuationSource,
        'propertyArchived': propertyArchived,
        'propertyRecordCreatedDateTime': propertyRecordCreatedDateTime,
        'propertyRecordLastEdited': propertyRecordLastEdited,
      },
    );
  }

  // get property Details stream for a given property
  //TODO why is stream not updating edit field when data changed in firebase
  Stream<PropertyDetails> get propertyByDocumentID {
    return userPropertyCollection
        .document(propertyUid)
        .snapshots()
        .map(_propertyDetailsFromSnapshot);
  }

  PropertyDetails _propertyDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return PropertyDetails(
      userUid: uid,
      propertyName: snapshot.data['propertyName'] ?? 'no name',
      propertyNotes: snapshot.data['propertyNotes'] ?? 'no notes',
      propertyAddress: snapshot.data['propertyAddress'] ?? 'no address',
      propertyZone: snapshot.data['propertyZone'] ?? 'no zone',
      propertyLandArea: snapshot.data['propertyLandArea'] ?? 0,
      propertyDatePurchased: snapshot.data['propertyDatePurchased'],
      propertyRatesBillingCode:
          snapshot.data['propertyRatesBillingCode'] ?? 'no code',
      propertyInsurancePolicy:
          snapshot.data['propertyInsurancePolicy'] ?? 'no policy',
      propertyInsuranceSource:
          snapshot.data['propertyInsuranceSource'] ?? 'no source',
      propertyInsuranceExpiryDate: snapshot.data['propertyInsuranceExpiryDate'],
      propertyLegalDescription:
          snapshot.data['propertyLegalDescription'] ?? 'no desc',
      propertyMarketValuationAmount:
          snapshot.data['propertyMarketValuationAmount'] ?? 0,
      propertyMarketValuationDate: snapshot.data['propertyMarketValuationDate'],
      propertyMarketValuationSource:
          snapshot.data['propertyMarketValuationSource'] ?? 'no source',
      propertyArchived: snapshot.data['propertyArchived'] ?? false,
      propertyRecordCreatedDateTime:
          snapshot.data['propertyRecordCreatedDateTime'],
      propertyRecordLastEdited: snapshot.data['propertyRecordLastEdited'],
    );
  }

  // get property details stream for a given user ordered by property name
  Stream<List<PropertyDetails>> get userProperties {
    return userPropertyCollection
        .where('userUid', isEqualTo: uid)
        .where('propertyArchived', isEqualTo: false)
        .orderBy('propertyName', descending: false)
        .snapshots()
        .map(_userPropertiesFromSnapshot);
  }

  List<PropertyDetails> _userPropertiesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return PropertyDetails(
        propertyUid: doc.documentID,
        userUid: uid,
        propertyName: doc.data['propertyName'] ?? 'no name',
        propertyNotes: doc.data['propertyNotes'] ?? 'no notes',
        propertyArchived: doc.data['archived'] ?? false,
        propertyAddress: doc.data['propertyAddress'] ?? 'no address',
        propertyDatePurchased:
            doc.data['propertyDatePurchased'] ?? Timestamp.now(),
        propertyRecordLastEdited: doc.data['editedDateTime'] ?? Timestamp.now(),
      );
    }).toList();
  }

  //
  //
  //   ******** Units ********
  //

  // add a unit to a property
  Future addPropertyUnit(
    String userUid,
    String unitPropertyUid,
    String unitName,
    String unitNotes,
    String unitLeaseDescription,
    num unitArea,
    num unitPercentageSplit,
    bool unitResidential,
    num unitRentalValuationAmount,
    DateTime unitRentalValuationDate,
    String unitRentalValuationSource,
    bool unitArchived,
    Timestamp unitRecordCreatedDateTime,
    Timestamp unitRecordLastEdited,
  ) async {
    return await userUnitCollection.document().setData(
      {
        'userUid': userUid,
        'propertyUid': unitPropertyUid,
        'unitName': unitName,
        'unitNotes': unitNotes,
        'unitLeaseDescription': unitLeaseDescription,
        'unitArea': unitArea,
        'unitPercentageSplit': unitPercentageSplit,
        'unitResidential': unitResidential,
        'unitRentalValuationAmount': unitRentalValuationAmount,
        'unitRentalValuationDate': unitRentalValuationDate,
        'unitRentalValuationSource': unitRentalValuationSource,
        'unitArchived': unitArchived,
        'unitRecordCreatedDateTime': unitRecordCreatedDateTime,
        'unitRecordLastEdited': unitRecordLastEdited,
      },
    );
  }

  // update a unit's details
  Future updatePropertyUnit(
    String userUid,
    String unitPropertyUid,
    String unitName,
    String unitNotes,
    String unitLeaseDescription,
    num unitArea,
    num unitPercentageSplit,
    bool unitResidential,
    num unitRentalValuationAmount,
    DateTime unitRentalValuationDate,
    String unitRentalValuationSource,
    bool unitArchived,
    Timestamp unitRecordCreatedDateTime,
    Timestamp unitRecordLastEdited,
  ) async {
    return await userUnitCollection.document(unitUid).updateData(
      {
        'userUid': userUid,
        'unitName': unitName,
        'unitNotes': unitNotes,
        'unitLeaseDescription': unitLeaseDescription,
        'unitArea': unitArea,
        'unitPercentageSplit': unitPercentageSplit,
        'unitResidential': unitResidential,
        'unitRentalValuationAmount': unitRentalValuationAmount,
        'unitRentalValuationDate': unitRentalValuationDate,
        'unitRentalValuationSource': unitRentalValuationSource,
        'unitArchived': unitArchived,
        'unitRecordCreatedDateTime': unitRecordCreatedDateTime,
        'unitRecordLastEdited': unitRecordLastEdited,
      },
    );
  }

  // get unit Details stream for a given unit
  //TODO why is stream not updating edit field when data changed in firebase
  Stream<UnitDetails> get unitByDocumentID {
    return userUnitCollection
        .document(unitUid)
        .snapshots()
        .map(_unitDetailsFromSnapshot);
  }

  UnitDetails _unitDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return UnitDetails(
      unitUid: snapshot.data['unitUid'],
      propertyUid: snapshot.data['propertyUid'],
      userUid: snapshot.data['userUid'],
      unitName: snapshot.data['unitName'] ?? 'no name',
      unitNotes: snapshot.data['unitNotes'] ?? 'no notes',
      unitArea: snapshot.data['unitArea'] ?? 0,
      unitPercentageSplit: snapshot.data['unitPercentageSplit'] ?? 0,
      unitLeaseDescription:
          snapshot.data['unitLeaseDescription'] ?? 'no description',
      unitResidential: snapshot.data['unitResidential'] ?? false,
      unitRentalValuationAmount: snapshot['unitRentalValuationAmount'] ?? 0,
      unitRentalValuationDate: snapshot['unitRentalValuationDate'],
      unitRentalValuationSource: snapshot['unitRentalValuationSource'],
      unitArchived: snapshot.data['unitArchived'],
      unitRecordCreatedDateTime: snapshot.data['unitRecordCreatedDateTime'],
      unitRecordLastEdited: snapshot.data['unitRecordLastEdited'],
    );
  }

  // get unit name stream for a given property ordered by unit name
  Stream<List<UnitDetails>> get userUnitsForProperty {
    return userUnitCollection
        .where('propertyUid', isEqualTo: propertyUid)
        .where('unitArchived', isEqualTo: false)
        .orderBy('unitName', descending: false)
        .snapshots()
        .map(_userUnitsFromSnapshot);
  }

  // get unit name stream for a user
  Stream<List<UnitDetails>> get allUnitsForUser {
    return userUnitCollection
        .where('userUid', isEqualTo: uid)
        .where('unitArchived', isEqualTo: false)
        .orderBy('unitName', descending: false)
        .snapshots()
        .map(_userUnitsFromSnapshot);
  }

  List<UnitDetails> _userUnitsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map(
      (doc) {
        return UnitDetails(
          unitUid: doc.documentID,
          userUid: uid,
          propertyUid: doc.data['propertyUid'],
          unitName: doc.data['unitName'] ?? 'no name',
          unitNotes: doc.data['unitNotes'] ?? 'no notes',
        );
      },
    ).toList();
  }

//
// **********  Company (& then Person below) **********
//

// add a company
  Future addUserCompany(
    String userUid,
    String companyName,
    String companyComment,
    String companyPhone,
    String companyEmail,
    String companyWebsite,
    String companyPostalAddress,
    bool companySetTenant,
    bool companySetTrade,
    bool companySetAgent,
    bool companyArchived,
    Timestamp companyRecordCreatedDateTime,
    Timestamp companyRecordLastEdited,
  ) async {
    DocumentReference document =
        userCompanyCollection.document(); //new document is created here
    await document.setData(
      {
        'userUid': userUid,
        'companyName': companyName,
        'companyComment': companyComment,
        'companyPhone': companyPhone,
        'companyEmail': companyEmail,
        'companyWebsite': companyWebsite,
        'companyPostalAddress': companyPostalAddress,
        'companySetTenant': companySetTenant,
        'companySetTrade': companySetTrade,
        'companySetAgent': companySetAgent,
        'companyArchived': companyArchived,
        'companyRecordCreatedDateTime': companyRecordCreatedDateTime,
        'companyRecordLastEdited': companyRecordLastEdited,
      },
    );
    // returns the document after setting the data finishes so in this way, your docRef must not be null anymore.
    return document;
  }

// update a company
  Future updateUserCompany(
    String userUid,
    String companyName,
    String companyComment,
    String companyPhone,
    String companyEmail,
    String companyWebsite,
    String companyPostalAddress,
    bool companySetTenant,
    bool companySetTrade,
    bool companySetAgent,
    bool companyArchived,
    Timestamp companyRecordCreatedDateTime,
    Timestamp companyRecordLastEdited,
  ) async {
    return await userCompanyCollection.document(companyUid).updateData(
      {
        'userUid': userUid,
        'companyName': companyName,
        'companyComment': companyComment,
        'companyPhone': companyPhone,
        'companyEmail': companyEmail,
        'companyWebsite': companyWebsite,
        'companyPostalAddress': companyPostalAddress,
        'companySetTenant': companySetTenant,
        'companySetTrade': companySetTrade,
        'companySetAgent': companySetAgent,
        'companyArchived': companyArchived,
        'companyRecordCreatedDateTime': companyRecordCreatedDateTime,
        'companyRecordLastEdited': companyRecordLastEdited,
      },
    );
  }

// get property Details stream for a given property
//TODO why is stream not updating edit field when data changed in firebase
  Stream<CompanyDetails> get companyByDocumentID {
    return userCompanyCollection
        .document(companyUid)
        .snapshots()
        .map(_companyDetailsFromSnapshot);
  }

  CompanyDetails _companyDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return CompanyDetails(
      userUid: uid,
      companyName: snapshot.data['companyName'],
      companyComment: snapshot.data['companyComment'],
      companyPhone: snapshot.data['companyPhone'],
      companyEmail: snapshot.data['companyEmail'],
      companyWebsite: snapshot.data['companyWebsite'],
      companyPostalAddress: snapshot.data['companyPostalAddress'],
      companySetTenant: snapshot.data['companySetTenant'] ?? false,
      companySetTrade: snapshot.data['companySetTrade'] ?? false,
      companySetAgent: snapshot.data['companySetAgent'] ?? false,
      companyArchived: snapshot.data['companyArchived'] ?? false,
      companyRecordCreatedDateTime:
          snapshot.data['companyRecordCreatedDateTime'],
      companyRecordLastEdited: snapshot.data['companyRecordLastEdited'],
    );
  }

// get company details stream for a given user ordered by company name
  Stream<List<CompanyDetails>> get userCompanies {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .orderBy('companyName', descending: false)
        .snapshots()
        .map(_userCompaniesFromSnapshot);
  }

  // get tenant details stream for a given user ordered by company name
  Stream<List<CompanyDetails>> get userTenants {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .where('companySetTenant', isEqualTo: true)
        .orderBy('companyName', descending: false)
        .snapshots()
        .map(_userCompaniesFromSnapshot);
  }

  List<CompanyDetails> _userCompaniesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return CompanyDetails(
        companyUid: doc.documentID,
        userUid: uid,
        companyName: doc.data['companyName'] ?? 'no name',
        companyComment: doc.data['companyComment'] ?? 'no notes',
        companyPhone: doc.data['companyPhone'],
        companyEmail: doc.data['companyEmail'],
        companySetTenant: doc.data['companySetTenant'],
        companyArchived: doc.data['companyArchived'] ?? false,
        companyPostalAddress: doc.data['companyPostalAddress'] ?? 'no address',
        companyRecordLastEdited:
            doc.data['companyRecordLastEdited'] ?? Timestamp.now(),
      );
    }).toList();
  }

//
//
//   ******** Persons ********
//

// add a person to a company
  Future addCompanyPerson(
    String userUid,
    String personCompanyUid,
    String personName,
    String personPhone,
    String personEmail,
    String personRole,
    String personComment,
    bool personArchived,
    Timestamp personRecordCreatedDateTime,
    Timestamp personRecordLastEdited,
  ) async {
    return await userPersonCollection.document().setData(
      {
        'userUid': userUid,
        'companyUid': personCompanyUid,
        'personName': personName,
        'personPhone': personPhone,
        'personEmail': personEmail,
        'personRole': personRole,
        'personComment': personComment,
        'personArchived': personArchived,
        'personRecordCreatedDateTime': personRecordCreatedDateTime,
        'personRecordLastEdited': personRecordLastEdited,
      },
    );
  }

// update a person's details
  Future updateCompanyPerson(
    String userUid,
    String companyUid,
    String personName,
    String personPhone,
    String personEmail,
    String personRole,
    String personComment,
    bool personArchived,
    Timestamp personRecordCreatedDateTime,
    Timestamp personRecordLastEdited,
  ) async {
    return await userPersonCollection.document(personUid).updateData(
      {
        'userUid': userUid,
        'personName': personName,
        'personPhone': personPhone,
        'personEmail': personEmail,
        'personRole': personRole,
        'personComment': personComment,
        'personArchived': personArchived,
//        'personRecordCreatedDateTime': personRecordCreatedDateTime,
        'personRecordLastEdited': personRecordLastEdited,
      },
    );
  }

// get person Details stream for a given person
//TODO why is stream not updating edit field when data changed in firebase
  Stream<PersonDetails> get personByDocumentID {
    return userPersonCollection
        .document(personUid)
        .snapshots()
        .map(_personDetailsFromSnapshot);
  }

  PersonDetails _personDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return PersonDetails(
      personUid: snapshot.data['personUid'],
      companyUid: snapshot.data['companyUid'],
      userUid: snapshot.data['userUid'],
      personName: snapshot.data['personName'],
      personPhone: snapshot.data['personPhone'],
      personEmail: snapshot.data['personEmail'],
      personRole: snapshot.data['personRole'],
      personComment: snapshot.data['personComment'],
      personArchived: snapshot.data['personArchived'],
      personRecordCreatedDateTime: snapshot.data['personRecordCreatedDateTime'],
      personRecordLastEdited: snapshot.data['personRecordLastEdited'],
    );
  }

// get person name stream for a given company ordered by person name
  Stream<List<PersonDetails>> get userPersonsForCompany {
    return userPersonCollection
        .where('companyUid', isEqualTo: companyUid)
        .where('personArchived', isEqualTo: false)
        .orderBy('personName', descending: false)
        .snapshots()
        .map(_userPersonsFromSnapshot);
  }

// get person name stream for a user
  Stream<List<PersonDetails>> get allPersonsForUser {
    return userPersonCollection
        .where('userUid', isEqualTo: uid)
        .where('personArchived', isEqualTo: false)
        .orderBy('personName', descending: false)
        .snapshots()
        .map(_userPersonsFromSnapshot);
  }

  List<PersonDetails> _userPersonsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map(
      (doc) {
        return PersonDetails(
          personUid: doc.documentID,
          userUid: uid,
          companyUid: doc.data['companyUid'],
          personName: doc.data['personName'],
          personRole: doc.data['personRole'],
          personComment: doc.data['personComment'],
          personEmail: doc.data['personEmail'],
          personPhone: doc.data['personPhone'],
        );
      },
    ).toList();
  }
}
