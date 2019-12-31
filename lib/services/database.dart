import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_returns/models/user.dart';
import 'package:property_returns/models/user_details.dart';

class DatabaseServices {
  final String uid;

  DatabaseServices({this.uid});

  // collection reference
  final CollectionReference userDetailsCollection =
      Firestore.instance.collection('user_details');

  Future updateUserDetails(String userName, int leaseNotificationDays,
      int taskNotificationDays) async {
    return await userDetailsCollection.document(uid).setData({
      'user_name': userName,
      'lease_notification_days': leaseNotificationDays,
      'task_notification_days': taskNotificationDays,
    });
  }

  // list all users - only for example sake
  List<UserDetails> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return UserDetails(
        userName: doc.data['user_name'] ?? '',
        leaseNotificationDays: doc.data['lease_notification_days'] ?? 0,
        taskNotificationDays: doc.data['task_notification_days'] ?? 0,
      );
    }).toList();
  }

  // user details from snapshot
  UserData _userDetailsFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      userUid: uid,
      userName: snapshot.data['user_name'],
      leaseNotificationDays: snapshot.data['lease_notification_days'],
      taskNotificationDays: snapshot.data['task_notification_days'],
    );
  }

  // get users stream
  Stream<List<UserDetails>> get users {
    return userDetailsCollection
        .orderBy('user_name')
        .snapshots()
        .map(_userListFromSnapshot);
  }

  // get user doc stream
  Stream<UserData> get userData {
    return userDetailsCollection
        .document(uid)
        .snapshots()
        .map(_userDetailsFromSnapshot);
  }
}
