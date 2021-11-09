import 'package:digitalgeolocater/handlers/string_handlers.dart';

class LeaveApproval {
  int AppId;
  String ApplicantName;
  DateTime ApprovalDate;
  String ApprovedBy;
  DateTime AssignFromDate;
  DateTime AssignUptoDate;
  int ClientId;
  String Brcode;
  DateTime FromDate;
  DateTime UptoDate;
  String Reason;
  String LeaveStatus;
  String Type;
  DateTime EntDate;
  String LeaveCategory;

  LeaveApproval(
      {this.AppId,
      this.ApplicantName,
      this.ApprovalDate,
      this.ApprovedBy,
      this.AssignFromDate,
      this.AssignUptoDate,
      this.ClientId,
      this.Brcode,
      this.FromDate,
      this.UptoDate,
      this.Reason,
      this.LeaveStatus,
      this.Type,
      this.EntDate,
      this.LeaveCategory});

  factory LeaveApproval.fromJson(Map<String, dynamic> parsedJson) {
    return LeaveApproval(
      AppId: parsedJson[LeaveApprovalFieldNames.AppId] ?? 0,
      ApplicantName: parsedJson[LeaveApprovalFieldNames.ApplicantName] ??
          StringHandlers.NotAvailable,
      ApprovalDate: parsedJson["ApprovalDate"] != null
          ? DateTime.parse(parsedJson["ApprovalDate"])
          : null,
      ApprovedBy: parsedJson[LeaveApprovalFieldNames.ApprovedBy] ??
          StringHandlers.NotAvailable,
      AssignFromDate: parsedJson[LeaveApprovalFieldNames.AssignFromDate] != null
          ? DateTime.parse(parsedJson[LeaveApprovalFieldNames.AssignFromDate])
          : null,
      AssignUptoDate: parsedJson[LeaveApprovalFieldNames.AssignUptoDate] != null
          ? DateTime.parse(parsedJson[LeaveApprovalFieldNames.AssignUptoDate])
          : null,
      ClientId: parsedJson[LeaveApprovalFieldNames.ClientId] ??
          StringHandlers.NotAvailable,
      Brcode: parsedJson[LeaveApprovalFieldNames.Brcode] ??
          StringHandlers.NotAvailable,
      FromDate: parsedJson[LeaveApprovalFieldNames.FromDate] != null
          ? DateTime.parse(parsedJson[LeaveApprovalFieldNames.FromDate])
          : null,
      UptoDate: parsedJson[LeaveApprovalFieldNames.UptoDate] != null
          ? DateTime.parse(parsedJson[LeaveApprovalFieldNames.UptoDate])
          : null,
      Reason: parsedJson[LeaveApprovalFieldNames.Reason] ??
          StringHandlers.NotAvailable,
      LeaveStatus: parsedJson[LeaveApprovalFieldNames.LeaveStatus] ??
          StringHandlers.NotAvailable,
      Type: parsedJson[LeaveApprovalFieldNames.Type] ??
          StringHandlers.NotAvailable,
      EntDate: parsedJson[LeaveApprovalFieldNames.EntDate] != null
          ? DateTime.parse(parsedJson[LeaveApprovalFieldNames.EntDate])
          : null,
      LeaveCategory: parsedJson[LeaveApprovalFieldNames.LeaveCategory] ??
          StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        LeaveApprovalFieldNames.AppId: AppId,
        LeaveApprovalFieldNames.ApplicantName: ApplicantName,
        LeaveApprovalFieldNames.ApprovalDate:
            ApprovalDate == null ? null : ApprovalDate.toIso8601String(),
        LeaveApprovalFieldNames.ApprovedBy: ApprovedBy,
        LeaveApprovalFieldNames.AssignFromDate:
            AssignFromDate == null ? null : AssignFromDate.toIso8601String(),
        LeaveApprovalFieldNames.AssignUptoDate:
            AssignUptoDate == null ? null : AssignUptoDate.toIso8601String(),
        LeaveApprovalFieldNames.ClientId: ClientId,
        LeaveApprovalFieldNames.Brcode: Brcode,
        LeaveApprovalFieldNames.FromDate:
            FromDate == null ? null : FromDate.toIso8601String(),
        LeaveApprovalFieldNames.UptoDate:
            UptoDate == null ? null : UptoDate.toIso8601String(),
        LeaveApprovalFieldNames.Reason: Reason,
        LeaveApprovalFieldNames.LeaveStatus: LeaveStatus,
        LeaveApprovalFieldNames.Type: Type,
        LeaveApprovalFieldNames.EntDate:
            EntDate == null ? null : EntDate.toIso8601String(),
    LeaveApprovalFieldNames.LeaveCategory: LeaveCategory,
      };
}

class LeaveApprovalFieldNames {
  static String AppId = "AppId";
  static String Type = "Type";
  static String ApplicantName = "ApplicantName";
  static String EntDate = "EntDate";
  static String LeaveType = "LeaveType";
  static String Reason = "Reason";
  static String ApprovedBy = "ApprovedBy";
  static String FromDate = "FromDate";
  static String UptoDate = "UptoDate";
  static String LeaveStatus = "LeaveStatus";
  static String AssignFromDate = "AssignFromDate";
  static String AssignUptoDate = "AssignUptoDate";
  static String ApprovalDate = "ApprovalDate";
  static String UserID = "UserID";
  static String EntDateTime = "EntDateTime";
  static String UserNo = "UserNo";
  static String ClientId = "ClientId";
  static String Brcode = "Brcode";
  static String LeaveTypeName = "LeaveTypeName";
  static String LeaveCategory = "LeaveCategory";
}

class LeaveApprovalUrls {
  static const String GET_PENDING_LEAVES = 'Leave/GetUnapprovedLeaveApplication';
  static const String APPROVED_PENDING_LEAVES = 'Leave/UpdateLeaveStatus';
  static const String GET_LEAVE_APPLICATION = 'Report/GetLeaveApplication';
}
