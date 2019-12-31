class User {
  final String userUid;
  User({this.userUid});
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
