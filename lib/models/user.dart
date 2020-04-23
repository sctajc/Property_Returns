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
  final bool areaMeasurementM2;
  final String currencySymbol;

  UserData(
      {this.userUid,
      this.userName,
      this.leaseNotificationDays,
      this.taskNotificationDays,
      this.areaMeasurementM2,
      this.currencySymbol});
}
