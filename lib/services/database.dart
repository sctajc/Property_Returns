import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_returns/models/property_details.dart';
import 'package:property_returns/models/task_details.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/user_details.dart';

class DatabaseServices {
  final String uid; // user uid
  final String taskID; // task id
  final String propertyUid;

  DatabaseServices({this.uid, this.taskID, this.propertyUid});

  //
  // collection reference shorthand
  //
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
    return await userDetailsCollection.document(uid).setData({
      'user_name': userName,
      'lease_notification_days': leaseNotificationDays,
      'task_notification_days': taskNotificationDays,
    });
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
    return snapshot.documents.map((doc) {
      return UserDetails(
        userName: doc.data['user_name'] ?? '',
        leaseNotificationDays: doc.data['lease_notification_days'] ?? 0,
        taskNotificationDays: doc.data['task_notification_days'] ?? 0,
      );
    }).toList();
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
  Future addUserTask(String userUid, String title, String detail, bool archived,
      int importance, DateTime dueDateTime, DateTime editedDateTime) async {
    return await userTaskCollection.document().setData(
      {
        'userUid': userUid,
        'title': title,
        'detail': detail,
        'archived': archived,
        'importance': importance,
        'dueDateTime': dueDateTime,
        'editedDateTime': editedDateTime,
      },
    );
  }

  // update a task
  Future updateUserTask(
      String taskID,
      String userUid,
      String title,
      String detail,
      bool archived,
      int importance,
      DateTime dueDateTime,
      DateTime editedDateTime) async {
    return await userTaskCollection.document(taskID).updateData({
      'userUid': userUid,
      'title': title,
      'detail': detail,
      'archived': archived,
      'importance': importance,
      'dueDateTime': dueDateTime,
      'editedDateTime': editedDateTime,
    });
  }

  // get TaskDetails stream for a given task and user ordered by importance
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
    return snapshot.documents.map((doc) {
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
    }).toList();
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

// use below to access in class
//need import cloud_firestore to class file
//  final allTasks = Provider.of<QuerySnapshot>(context);
//  for (var doc in allTasks.screens.documents) {
//  print(doc.data);
//  }

// **********  Property & Units **********
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
      DateTime propertyRecordCreatedDateTime,
      DateTime propertyRecordLastEdited) async {
    return await userPropertyCollection.document().setData(
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
        'propertyInsuranceDate': propertyInsuranceExpiryDate,
        'propertyLegalDescription': propertyLegalDescription,
        'propertyMarketValuation': propertyValuation,
        'propertyMarketValuationSource': propertyValuationSource,
        'propertyArchived': propertyArchived,
        'propertyRecordCreatedDateTime': propertyRecordCreatedDateTime,
        'propertyRecordLastEdited': propertyRecordLastEdited,
      },
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

// get unit name stream for a given property ordered by unit name
  Stream<List<UnitDetails>> get userUnitsForProperty {
    return userUnitCollection
        .where('propertyUid', isEqualTo: propertyUid)
        .orderBy('unitName', descending: false)
        .snapshots()
        .map(_userUnitsFromSnapshot);
  }

  List<UnitDetails> _userUnitsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return UnitDetails(
        unitUid: doc.documentID,
        userUid: uid,
        unitName: doc.data['unitName'] ?? 'no name',
        unitNotes: doc.data['unitNotes'] ?? 'no notes',
      );
    }).toList();
  }
}
