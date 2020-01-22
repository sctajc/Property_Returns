import 'package:cloud_firestore/cloud_firestore.dart';

class TasksDetails {
  final String taskID;
  final String userUid;
  final String taskTitle;
  final String taskDetail;
  final bool taskArchived;
  final int taskImportance;
  final Timestamp taskDueDateTime;
  final Timestamp taskLastEditedDateTime;

  TasksDetails(
      {this.taskID,
      this.userUid,
      this.taskTitle,
      this.taskDetail,
      this.taskArchived,
      this.taskImportance,
      this.taskDueDateTime,
      this.taskLastEditedDateTime});
}
