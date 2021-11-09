import 'package:digitalgeolocater/handlers/string_handlers.dart';

class EmployeeLeave {
  int LeaveType;
  String Reason;
  DateTime FromDate;
  DateTime UptoDate;
  String LeaveStatus;
  String ApprovedBy;
  DateTime AssignFromDate;
  DateTime AssignUptoDate;
  DateTime ApprovalDate;
  String UserID;
  DateTime EntDateTime;
  int UserNo;
  int ClientId;
  String Brcode;
  String LeaveTypeName;
  int LeaveCat;
  String LeaveCategory;

  EmployeeLeave(
      {this.LeaveType,
      this.Reason,
      this.FromDate,
      this.UptoDate,
      this.LeaveStatus,
      this.ApprovedBy,
      this.AssignFromDate,
      this.AssignUptoDate,
      this.ApprovalDate,
      this.UserID,
      this.EntDateTime,
      this.UserNo,
      this.ClientId,
      this.Brcode,
      this.LeaveTypeName,
      this.LeaveCat,
      this.LeaveCategory});

  factory EmployeeLeave.fromJson(Map<String, dynamic> parsedJson) {
    return EmployeeLeave(
      LeaveType: parsedJson[EmployeeLeaveFieldNames.LeaveType] ?? 0,
      Reason: parsedJson[EmployeeLeaveFieldNames.Reason] ??
          StringHandlers.NotAvailable,
      FromDate: parsedJson["FromDate"] != null
          ? DateTime.parse(parsedJson["FromDate"])
          : null,
      UptoDate: parsedJson["UptoDate"] != null
          ? DateTime.parse(parsedJson["UptoDate"])
          : null,
      LeaveStatus: parsedJson[EmployeeLeaveFieldNames.LeaveStatus] ??
          StringHandlers.NotAvailable,
      ApprovedBy: parsedJson[EmployeeLeaveFieldNames.ApprovedBy] ??
          0,
      AssignFromDate: parsedJson[EmployeeLeaveFieldNames.AssignFromDate] != null
          ? DateTime.parse(parsedJson[EmployeeLeaveFieldNames.AssignFromDate])
          : null,
      AssignUptoDate:parsedJson[EmployeeLeaveFieldNames.AssignUptoDate] != null
          ? DateTime.parse(parsedJson[EmployeeLeaveFieldNames.AssignUptoDate])
          : null,
      ApprovalDate:parsedJson[EmployeeLeaveFieldNames.ApprovalDate] != null
          ? DateTime.parse(parsedJson[EmployeeLeaveFieldNames.ApprovalDate])
          : null,
      UserID: parsedJson[EmployeeLeaveFieldNames.UserID] ??
          StringHandlers.NotAvailable,
      EntDateTime:parsedJson[EmployeeLeaveFieldNames.EntDateTime] != null
          ? DateTime.parse(parsedJson[EmployeeLeaveFieldNames.EntDateTime])
          : null,
      UserNo: parsedJson[EmployeeLeaveFieldNames.UserNo] ??
          StringHandlers.NotAvailable,
      ClientId: parsedJson[EmployeeLeaveFieldNames.ClientId] ??
          StringHandlers.NotAvailable,
      Brcode: parsedJson[EmployeeLeaveFieldNames.Brcode] ??
          StringHandlers.NotAvailable,
      LeaveTypeName: parsedJson[EmployeeLeaveFieldNames.LeaveTypeName] ??
          StringHandlers.NotAvailable,
      LeaveCat: parsedJson[EmployeeLeaveFieldNames.LeaveCat] ??
         0,
      LeaveCategory: parsedJson[EmployeeLeaveFieldNames.LeaveCategory] ??
          StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        EmployeeLeaveFieldNames.LeaveType: LeaveType,
        EmployeeLeaveFieldNames.Reason: Reason,
        EmployeeLeaveFieldNames.FromDate:
            FromDate == null ? null : FromDate.toIso8601String(),
        EmployeeLeaveFieldNames.UptoDate:
            UptoDate == null ? null : UptoDate.toIso8601String(),
        EmployeeLeaveFieldNames.LeaveStatus: LeaveStatus,
        EmployeeLeaveFieldNames.ApprovedBy: ApprovedBy,
        EmployeeLeaveFieldNames.AssignFromDate:
            AssignFromDate == null ? null : AssignFromDate.toIso8601String(),
        EmployeeLeaveFieldNames.AssignUptoDate:
            AssignUptoDate == null ? null : AssignUptoDate.toIso8601String(),
        EmployeeLeaveFieldNames.AssignUptoDate:
            ApprovalDate == null ? null : ApprovalDate.toIso8601String(),
        EmployeeLeaveFieldNames.UserID: UserID,
        EmployeeLeaveFieldNames.EntDateTime:
            EntDateTime == null ? null : EntDateTime.toIso8601String(),
        EmployeeLeaveFieldNames.UserNo: UserNo,
        EmployeeLeaveFieldNames.ClientId: ClientId,
        EmployeeLeaveFieldNames.Brcode: Brcode,
        EmployeeLeaveFieldNames.LeaveTypeName: LeaveTypeName,
        EmployeeLeaveFieldNames.LeaveCat: LeaveCat,
        EmployeeLeaveFieldNames.LeaveCategory: LeaveCategory,
      };
}

class EmployeeLeaveFieldNames {
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
  static String LeaveCat = "LeaveCat";
  static String LeaveCategory = "LeaveCategory";
}

class EmployeeLeaveUrls {
  static const String GET_EMPLOYEE_LEAVES = 'Leave/GetApplicationStatus';
}
