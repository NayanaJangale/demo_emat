import 'package:digitalgeolocater/handlers/string_handlers.dart';
class AttendanceSummary {
  int  ExtraCount;
  int  HalfDayCount;
  int Holiday;
  int  LateMarkCount;
  int  LeaveCountWithAppn;
  int  LeaveCountWithoutAppn;
  int  PresentCount;
  int  RefUserNo;
  int TotalDays;
  String UserName;


  AttendanceSummary({this.ExtraCount,this.Holiday, this.HalfDayCount, this.LateMarkCount,
      this.LeaveCountWithAppn, this.LeaveCountWithoutAppn ,this.PresentCount, this.RefUserNo, this.TotalDays,
      this.UserName});

  factory AttendanceSummary.fromJson(Map<String, dynamic> parsedJson) {
    return AttendanceSummary(
      ExtraCount: parsedJson[AttendanceSummaryConst.ExtraCount] ?? 0,
      Holiday: parsedJson[AttendanceSummaryConst.Holiday] ?? 0,
      HalfDayCount: parsedJson[AttendanceSummaryConst.HalfDayCount] ?? 0,
      LateMarkCount: parsedJson[AttendanceSummaryConst.LateMarkCount] ?? 0,
      LeaveCountWithAppn: parsedJson[AttendanceSummaryConst.LeaveCountWithAppn] ?? 0,
      LeaveCountWithoutAppn: parsedJson[AttendanceSummaryConst.LeaveCountWithoutAppn] ?? 0,
      PresentCount: parsedJson[AttendanceSummaryConst.PresentCount] ?? 0,
      RefUserNo: parsedJson[AttendanceSummaryConst.RefUserNo] ?? 0,
      TotalDays: parsedJson[AttendanceSummaryConst.TotalDays] ?? 0, 
      UserName: parsedJson[AttendanceSummaryConst.UserName] ??  StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    AttendanceSummaryConst.ExtraCount: ExtraCount,
    AttendanceSummaryConst.Holiday: Holiday,
    AttendanceSummaryConst.HalfDayCount: HalfDayCount,
    AttendanceSummaryConst.LateMarkCount: LateMarkCount,
    AttendanceSummaryConst.LeaveCountWithAppn: LeaveCountWithAppn,
    AttendanceSummaryConst.LeaveCountWithoutAppn: LeaveCountWithoutAppn,
    AttendanceSummaryConst.PresentCount: PresentCount,
    AttendanceSummaryConst.RefUserNo: RefUserNo,
    AttendanceSummaryConst.TotalDays: TotalDays,
    AttendanceSummaryConst.UserName: UserName,
  };
}

class AttendanceSummaryConst {
  static const String ExtraCount = "ExtraCount";
  static const String Holiday = "Holiday";
  static const String HalfDayCount = "HalfDayCount";
  static const String LateMarkCount = "LateMarkCount";
  static const String LeaveCountWithAppn = "LeaveCountWithAppn";
  static const String LeaveCountWithoutAppn = "LeaveCountWithoutAppn";
  static const String PresentCount = "PresentCount";
  static const String RefUserNo = "RefUserNo";
  static const String TotalDays = "TotalDays";
  static const String UserName = "UserName";

}

class AttendanceSummaryUrls {
  static const String ATTENDANCE_REPORT =
      "Report/GetAttendanceSummary";
}
