import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/user_details.dart';
import 'package:property_returns/models/company_details.dart';
import 'package:property_returns/models/lease_details.dart';

class DatabaseServices {
  final String uid; // user uid
  final String taskID; // task id
  final String propertyUid;
  final String unitUid;
  final String companyUid;
  final String personUid;
  final String leaseUid;
  final String leaseEventUid;
  final String leaseEventTypeUid;

  DatabaseServices({
    this.uid,
    this.taskID,
    this.propertyUid,
    this.unitUid,
    this.companyUid,
    this.personUid,
    this.leaseUid,
    this.leaseEventUid,
    this.leaseEventTypeUid,
  });

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

  final CollectionReference userLeaseCollection =
      Firestore.instance.collection('leases');

  final CollectionReference userLeaseEventCollection =
      Firestore.instance.collection('lease_events');

  final CollectionReference userLeaseEventTypeCollection =
      Firestore.instance.collection('lease_event_types');

  //
  //
  // UserDetails (does not include userUid)
  //
  Future updateUserDetails(
    String userName,
    int leaseNotificationDays,
    int taskNotificationDays,
    bool areaMeasurementM2,
    String currencySymbol,
    bool tasksInGoogleCalendar,
    bool leaseEventsInGoogleCalendar,
    bool contactsInGoogleContacts,
  ) async {
    return await userDetailsCollection.document(uid).setData(
      {
        'user_name': userName,
        'lease_notification_days': leaseNotificationDays,
        'task_notification_days': taskNotificationDays,
        'areaMeasurementM2': areaMeasurementM2,
        'currencySymbol': currencySymbol,
        'tasksInGoogleCalendar': tasksInGoogleCalendar,
        'leaseEventsInGoogleCalendar': leaseEventsInGoogleCalendar,
        'contactsInGoogleContacts': contactsInGoogleContacts,
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
      tasksInGoogleCalendar: snapshot.data['tasksInGoogleCalendar'],
      leaseEventsInGoogleCalendar: snapshot.data['leaseEventsInGoogleCalendar'],
      contactsInGoogleContacts: snapshot.data['contactsInGoogleCalendar'],
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
    String taskTradeUid,
    String taskAgentUid,
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
        'tradeUid': taskTradeUid,
        'agentUid': taskAgentUid,
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
    String taskTradeUid,
    String taskAgentUid,
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
        'tradeUid': taskTradeUid,
        'agentUid': taskAgentUid,
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
      taskTitle: snapshot.data['title'],
      taskDetail: snapshot.data['detail'],
      taskArchived: snapshot.data['archived'] ?? false,
      taskImportance: snapshot.data['importance'] ?? 5,
      taskDueDateTime: snapshot.data['dueDateTime'] ?? DateTime.now(),
      taskUnitUid: snapshot.data['unitUid'] ?? 'none',
      taskTenantUid: snapshot.data['tenantUid'] ?? 'none',
      taskTradeUid: snapshot.data['tradeUid'] ?? 'none',
      taskAgentUid: snapshot.data['agentUid'] ?? 'none',
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

  //
  // get Tasks archived stream for a given user ordered dueDateTime descending
  Stream<List<TaskDetails>> get userTasksArchivedByDueDateTimeDescending {
    return userTaskCollection
        .where('userUid', isEqualTo: uid)
        .where('archived', isEqualTo: true)
        .orderBy('dueDateTime', descending: false)
        .snapshots()
        .map(_userTasksFromSnapshot);
  }

  List<TaskDetails> _userTasksFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map(
      (doc) {
        return TaskDetails(
          taskID: doc.documentID,
          userUid: uid,
          taskTitle: doc.data['title'],
          taskDetail: doc.data['detail'],
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
      propertyName: snapshot.data['propertyName'],
      propertyNotes: snapshot.data['propertyNotes'],
      propertyAddress: snapshot.data['propertyAddress'],
      propertyZone: snapshot.data['propertyZone'],
      propertyLandArea: snapshot.data['propertyLandArea'] ?? 0,
      propertyDatePurchased: snapshot.data['propertyDatePurchased'],
      propertyRatesBillingCode: snapshot.data['propertyRatesBillingCode'],
      propertyInsurancePolicy: snapshot.data['propertyInsurancePolicy'],
      propertyInsuranceSource: snapshot.data['propertyInsuranceSource'],
      propertyInsuranceExpiryDate: snapshot.data['propertyInsuranceExpiryDate'],
      propertyLegalDescription: snapshot.data['propertyLegalDescription'],
      propertyMarketValuationAmount:
          snapshot.data['propertyMarketValuationAmount'] ?? 0,
      propertyMarketValuationDate: snapshot.data['propertyMarketValuationDate'],
      propertyMarketValuationSource:
          snapshot.data['propertyMarketValuationSource'],
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
        propertyName: doc.data['propertyName'],
        propertyNotes: doc.data['propertyNotes'],
        propertyArchived: doc.data['archived'] ?? false,
        propertyAddress: doc.data['propertyAddress'],
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
      unitName: snapshot.data['unitName'],
      unitNotes: snapshot.data['unitNotes'],
      unitArea: snapshot.data['unitArea'] ?? 0,
      unitPercentageSplit: snapshot.data['unitPercentageSplit'] ?? 0,
      unitLeaseDescription: snapshot.data['unitLeaseDescription'],
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
          unitName: doc.data['unitName'],
          unitNotes: doc.data['unitNotes'],
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
  Stream<List<CompanyDetails>> get userCompaniesAll {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .orderBy('companyName', descending: false)
        .snapshots()
        .map(_userCompaniesFromSnapshot);
  }

  // get tenant company details stream for a given user ordered by company name
  Stream<List<CompanyDetails>> get userCompaniesTenants {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .where('companySetTenant', isEqualTo: true)
        .orderBy('companyName', descending: false)
        .snapshots()
        .map(_userCompaniesFromSnapshot);
  }

// get trade company details stream for a given user ordered by company name
  Stream<List<CompanyDetails>> get userCompaniesTrades {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .where('companySetTrade', isEqualTo: true)
        .orderBy('companyName', descending: false)
        .snapshots()
        .map(_userCompaniesFromSnapshot);
  }

  // get agent company details stream for a given user ordered by company name
  Stream<List<CompanyDetails>> get userCompaniesAgents {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .where('companySetAgent', isEqualTo: true)
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

  // get trade details stream for a given user ordered by company name
  Stream<List<CompanyDetails>> get userTrades {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .where('companySetTrade', isEqualTo: true)
        .orderBy('companyName', descending: false)
        .snapshots()
        .map(_userCompaniesFromSnapshot);
  }

  // get agent details stream for a given user ordered by company name
  Stream<List<CompanyDetails>> get userAgents {
    return userCompanyCollection
        .where('userUid', isEqualTo: uid)
        .where('companyArchived', isEqualTo: false)
        .where('companySetAgent', isEqualTo: true)
        .orderBy('companyName', descending: false)
        .snapshots()
        .map(_userCompaniesFromSnapshot);
  }

  List<CompanyDetails> _userCompaniesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return CompanyDetails(
        companyUid: doc.documentID,
        userUid: uid,
        companyName: doc.data['companyName'],
        companyComment: doc.data['companyComment'],
        companyPhone: doc.data['companyPhone'],
        companyEmail: doc.data['companyEmail'],
        companySetTenant: doc.data['companySetTenant'],
        companySetTrade: doc.data['companySetTrade'],
        companySetAgent: doc.data['companySetAgent'],
        companyArchived: doc.data['companyArchived'] ?? false,
        companyPostalAddress: doc.data['companyPostalAddress'],
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

//
// **********  Leases (& then Lease Events ) **********
//

// add a lease
  Future addUserLease(
    String userUid,
    String tenantUid,
    String unitUid,
    String leaseBusinessUse,
    String leaseDefaultInterestRate,
    String leaseCarParks,
    String leaseRentPaymentDay,
    DateTime leaseDateOfLease,
    String leaseGuarantor,
    String leaseComment,
    bool leaseArchived,
    Timestamp leaseRecordCreatedDateTime,
    Timestamp leaseRecordLastEdited,
  ) async {
    DocumentReference document =
        userLeaseCollection.document(); //new document is created here
    await document.setData(
      {
        'userUid': userUid,
        'tenantUid': tenantUid,
        'unitUid': unitUid,
        'leaseBusinessUse': leaseBusinessUse,
        'leaseDefaultInterestRate': leaseDefaultInterestRate,
        'leaseCarParks': leaseCarParks,
        'leaseRentPaymentDay': leaseRentPaymentDay,
        'leaseDateOfLease': leaseDateOfLease,
        'leaseGuarantor': leaseGuarantor,
        'leaseComment': leaseComment,
        'leaseArchived': leaseArchived,
        'leaseRecordCreatedDateTime': leaseRecordCreatedDateTime,
        'leaseRecordLastEdited': leaseRecordLastEdited,
      },
    );
    // returns the document after setting the data finishes so in this way,
    // your docRef must not be null anymore.
    return document;
  }

// update a lease
  Future updateUserLease(
    String userUid,
    String tenantUid,
    String unitUid,
    String leaseBusinessUse,
    String leaseDefaultInterestRate,
    String leaseCarParks,
    String leaseRentPaymentDay,
    DateTime leaseDateOfLease,
    String leaseGuarantor,
    String leaseComment,
    bool leaseArchived,
    Timestamp leaseRecordCreatedDateTime,
    Timestamp leaseRecordLastEdited,
  ) async {
    return await userLeaseCollection.document(leaseUid).updateData(
      {
        'userUid': userUid,
        'tenantUid': tenantUid,
        'unitUid': unitUid,
        'leaseBusinessUse': leaseBusinessUse,
        'leaseDefaultInterestRate': leaseDefaultInterestRate,
        'leaseCarParks': leaseCarParks,
        'leaseRentPaymentDay': leaseRentPaymentDay,
        'leaseDateOfLease': leaseDateOfLease,
        'leaseGuarantor': leaseGuarantor,
        'leaseComment': leaseComment,
        'leaseArchived': leaseArchived,
        'leaseRecordCreatedDateTime': leaseRecordCreatedDateTime,
        'leaseRecordLastEdited': leaseRecordLastEdited,
      },
    );
  }

  // get lease Details stream for a given lease
  Stream<LeaseDetails> get leaseByDocumentID {
    return userLeaseCollection
        .document(leaseUid)
        .snapshots()
        .map(_leaseDetailsFromSnapshot);
  }

  LeaseDetails _leaseDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return LeaseDetails(
      userUid: uid,
      tenantUid: snapshot.data['tenantUid'],
      unitUid: snapshot.data['unitUid'],
      leaseBusinessUse: snapshot.data['leaseBusinessUse'],
      leaseDefaultInterestRate: snapshot.data['leaseDefaultInterestRate'],
      leaseCarParks: snapshot.data['leaseCarParks'],
      leaseRentPaymentDay: snapshot.data['leaseRentPaymentDay'],
      leaseDateOfLease: snapshot.data['leaseDateOfLease'],
      leaseGuarantor: snapshot.data['leaseGuarantor'],
      leaseComment: snapshot.data['leaseComment'],
      leaseArchived: snapshot.data['leaseArchived'],
      leaseRecordCreatedDateTime: snapshot.data['leaseRecordCreatedDateTime'],
      leaseRecordLastEdited: snapshot.data['leaseRecordLastEdited'],
    );
  }

  // get lease details stream for a given user ordered by date
  Stream<List<LeaseDetails>> get userLeases {
    return userLeaseCollection
        .where('userUid', isEqualTo: uid)
        .where('leaseArchived', isEqualTo: false)
        .orderBy('leaseDateOfLease', descending: false)
        .snapshots()
        .map(_userLeasesFromSnapshot);
  }

//  // get lease Events details stream for a given user ordered by date
//  Stream<List<LeaseDetails>> get userTenants {
//    return userCompanyCollection
//        .where('userUid', isEqualTo: uid)
//        .where('companyArchived', isEqualTo: false)
//        .where('companySetTenant', isEqualTo: true)
//        .orderBy('companyName', descending: false)
//        .snapshots()
//        .map(_userCompaniesFromSnapshot);
//  }

  List<LeaseDetails> _userLeasesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return LeaseDetails(
        leaseUid: doc.documentID,
        userUid: uid,
        tenantUid: doc.data['tenantUid'],
        unitUid: doc.data['unitUid'],
        leaseBusinessUse: doc.data['leaseBusinessUse'],
        leaseDefaultInterestRate: doc.data['leaseDefaultInterestRate'],
        leaseCarParks: doc.data['leaseCarParks'],
        leaseRentPaymentDay: doc.data['leasePaymentDay'],
        leaseDateOfLease: doc.data['leaseDateOfLease'],
        leaseGuarantor: doc.data['leaseGuarantor'],
        leaseComment: doc.data['leaseComment'],
        leaseRecordLastEdited:
            doc.data['leaseRecordLastEdited'] ?? Timestamp.now(),
      );
    }).toList();
  }

//
//
//   ******** Lease Events ********
//

// add a lease event to a lease
  Future addUserLeaseEvent(
    String leaseUid,
    String userUid,
    String leaseEventType,
    DateTime leaseEventDate,
    bool leaseEventHappened,
    String leaseEventComment,
    Timestamp leaseEventRecordCreatedDateTime,
    Timestamp leaseEventRecordLastEdited,
  ) async {
    DocumentReference document =
        userLeaseEventCollection.document(); //new document is created here
    await document.setData(
      {
        'leaseUid': leaseUid,
        'userUid': userUid,
        'leaseEventType': leaseEventType,
        'leaseEventDate': leaseEventDate,
        'leaseEventHappened': leaseEventHappened,
        'leaseEventComment': leaseEventComment,
        'leaseEventRecordCreatedDateTime': leaseEventRecordCreatedDateTime,
        'leaseEventRecordLastEdited': leaseEventRecordLastEdited,
      },
    );
  }

  // update a lease event
  Future updateUserLeaseEvent(
    // String leaseUid,
    // String userUid,
    String leaseEventType,
    DateTime leaseEventDate,
    bool leaseEventHappened,
    String leaseEventComment,
//    Timestamp leaseEventRecordCreatedDateTime,
    Timestamp leaseEventRecordLastEdited,
  ) async {
    return await userLeaseEventCollection.document(leaseEventUid).updateData(
      {
        //  'leaseUid': leaseUid,
        // 'userUid': userUid,
        'leaseEventType': leaseEventType,
        'leaseEventDate': leaseEventDate,
        'leaseEventHappened': leaseEventHappened,
        'leaseEventComment': leaseEventComment,
//        'leaseEventRecordCreatedDateTime': leaseEventRecordCreatedDateTime,
        'leaseEventRecordLastEdited': leaseEventRecordLastEdited,
      },
    );
  }

  // get lease event Details stream for a given lease event
  Stream<LeaseEventDetails> get leaseEventByDocumentID {
    return userLeaseEventCollection
        .document(leaseEventUid)
        .snapshots()
        .map(_leaseEventDetailsFromSnapshot);
  }

  LeaseEventDetails _leaseEventDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return LeaseEventDetails(
      leaseEventUid: snapshot.data['leaseEventUid'],
      leaseUid: snapshot.data['leaseUid'],
      userUid: snapshot.data['userUid'],
      leaseEventType: snapshot.data['leaseEventType'],
      leaseEventDate: snapshot.data['leaseEventDate'],
      leaseEventHappened: snapshot.data['leaseEventHappened'],
      leaseEventComment: snapshot.data['leaseEventComment'],
      leaseEventRecordCreatedDateTime:
          snapshot.data['leaseEventRecordCreatedDateTime'],
      leaseEventRecordLastEdited: snapshot.data['leaseEventRecordLastEdited'],
    );
  }

  // get lease event date stream for a given lease ordered by lease event date
  Stream<List<LeaseEventDetails>> get userLeaseEventsForLease {
    return userLeaseEventCollection
        .where('leaseUid', isEqualTo: leaseUid)
        .orderBy('leaseEventDate', descending: false)
        .snapshots()
        .map(_userLeaseEventsFromSnapshot);
  }

  // get leaseEvent stream for a user
  Stream<List<LeaseEventDetails>> get allLeaseEventsForUser {
    return userLeaseEventCollection
        .where('userUid', isEqualTo: uid)
        .where('leaseEventHappened', isEqualTo: false)
        .orderBy('leaseEventDate', descending: false)
        .snapshots()
        .map(_userLeaseEventsFromSnapshot);
  }

  List<LeaseEventDetails> _userLeaseEventsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map(
      (doc) {
        return LeaseEventDetails(
            leaseEventUid: doc.documentID,
            userUid: uid,
            leaseUid: doc.data['leaseUid'],
            leaseEventType: doc.data['leaseEventType'],
            leaseEventDate: doc.data['leaseEventDate'],
            leaseEventHappened: doc.data['leaseEventHappened'],
            leaseEventComment: doc.data['leaseEventComment']);
      },
    ).toList();
  }

//
//
//   ******** Lease Event Types ********
//
  // get lease event Type Details for a given lease event type
  Stream<LeaseEventTypeDetails> get leaseEventTypeByDocumentID {
    return userLeaseEventTypeCollection
        .document(leaseEventTypeUid)
        .snapshots()
        .map(_leaseEventTypeDetailsFromSnapshot);
  }

  LeaseEventTypeDetails _leaseEventTypeDetailsFromSnapshot(
      DocumentSnapshot snapshot) {
    return LeaseEventTypeDetails(
      leaseEventTypeOrder: snapshot.data['leaseEventTypeUid'],
      leaseEventTypeName: snapshot.data['leaseEventTypeName'],
    );
  }

  // get all lease event types
  Stream<List<LeaseEventTypeDetails>> get allLeaseEventTypes {
    return userLeaseEventTypeCollection
        .orderBy('leaseEventTypeOrder')
        .snapshots()
        .map(_leaseEventTypesDetailsFromSnapshot);
  }

  List<LeaseEventTypeDetails> _leaseEventTypesDetailsFromSnapshot(
      QuerySnapshot snapshot) {
    return snapshot.documents.map(
      (doc) {
        return LeaseEventTypeDetails(
            leaseEventTypeUid: doc.documentID,
            leaseEventTypeName: doc.data['leaseEventTypeName'],
            leaseEventTypeOrder: doc.data['leaseEventTypeOrder']);
      },
    ).toList();
  }
}
