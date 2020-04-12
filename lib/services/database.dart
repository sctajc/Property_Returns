import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/user_details.dart';

class DatabaseServices {
  final String uid; // user uid
  final String taskID; // task id
  final String propertyUid;
  final String unitUid;

  DatabaseServices({this.uid, this.taskID, this.propertyUid, this.unitUid});

  // collection reference shorthand
  final CollectionReference userDetailsCollection =
      Firestore.instance.collection('user_details');

  final CollectionReference userTaskCollection =
      Firestore.instance.collection('tasks');

  final CollectionReference userPropertyCollection =
      Firestore.instance.collection('properties');

  final CollectionReference userUnitCollection =
      Firestore.instance.collection('units');

  //
  //
  // UserDetails (does not include userUid)
  //
  Future updateUserDetails(String userName, int leaseNotificationDays,
      int taskNotificationDays) async {
    return await userDetailsCollection.document(uid).setData(
      {
        'user_name': userName,
        'lease_notification_days': leaseNotificationDays,
        'task_notification_days': taskNotificationDays,
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
// **********  Property (& Units below) **********
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
    double propertyValuation,
    String propertyValuationSource,
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
        'propertyMarketValuation': propertyValuation,
        'propertyMarketValuationSource': propertyValuationSource,
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
    num propertyValuation,
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
        'propertyMarketValuation': propertyValuation,
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
      propertyDatePurchased:
          snapshot.data['propertyDatePurchased'] ?? DateTime.now(),
      propertyRatesBillingCode:
          snapshot.data['propertyRatesBillingCode'] ?? 'no code',
      propertyInsurancePolicy:
          snapshot.data['propertyInsurancePolicy'] ?? 'no policy',
      propertyInsuranceSource:
          snapshot.data['propertyInsuranceSource'] ?? 'no source',
      propertyInsuranceExpiryDate:
          snapshot.data['propertyInsuranceExpiryDate'] ?? DateTime.now(),
      propertyLegalDescription:
          snapshot.data['propertyLegalDescription'] ?? 'no desc',
      propertyMarketValuation: snapshot.data['propertyMarketValuation'] ?? 0,
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
    bool unitResidential,
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
        'unitResidential': unitResidential,
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
    bool unitResidential,
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
        'unitResidential': unitResidential,
        'unitArchived': unitArchived,
        'unitRecordCreatedDateTime': unitRecordCreatedDateTime,
        'unitRecordLastEdited': unitRecordLastEdited,
      },
    );
  }

  // get property Details stream for a given property
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
      unitLeaseDescription:
          snapshot.data['unitLeaseDescription'] ?? 'no description',
      unitResidential: snapshot.data['unitResidential'] ?? false,
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
}
