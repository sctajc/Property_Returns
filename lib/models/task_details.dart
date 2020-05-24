import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetails {
  final String taskID;
  final String userUid;
  final String taskTitle;
  final String taskDetail;
  final bool taskArchived;
  final int taskImportance;
  final String taskUnitUid;
  final String taskTenantUid;
  final String taskTradeUid;
  final String taskAgentUid;
  final Timestamp taskDueDateTime;
  final Timestamp taskLastEditedDateTime;

  TaskDetails(
      {this.taskID,
      this.userUid,
      this.taskTitle,
      this.taskDetail,
      this.taskArchived,
      this.taskImportance,
      this.taskUnitUid,
      this.taskTenantUid,
      this.taskTradeUid,
      this.taskAgentUid,
      this.taskDueDateTime,
      this.taskLastEditedDateTime});
}
