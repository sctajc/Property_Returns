class User {
  final String userUid;
  final String userEmail;

  User({this.userUid, this.userEmail});
}

class UserData {
  final String userUid;
  final String userName;
  final int leaseNotificationDays;
  final int taskNotificationDays;

  UserData(
      {this.userUid,
      this.userName,
      this.leaseNotificationDays,
      this.taskNotificationDays});
}
