import 'package:digitalgeolocater/handlers/string_handlers.dart';

class DashboardSummary {
  int  AbsentCount;
  int LateCount;
  int PresentCount;
  int TotalEmp;

  DashboardSummary({this.AbsentCount,this.LateCount,this.PresentCount,this.TotalEmp});
  factory DashboardSummary.fromJson(Map<String, dynamic> parsedJson) {
    return DashboardSummary(
      AbsentCount: parsedJson['AbsentCount']?? 0,
      LateCount: parsedJson['LateCount']?? 0,
      PresentCount: parsedJson['PresentCount']?? 0,
      TotalEmp: parsedJson['TotalEmp']?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    DashboardSummaryConst.AbsentCount: AbsentCount,
    DashboardSummaryConst.LateCount: LateCount,
    DashboardSummaryConst.PresentCount: PresentCount,
    DashboardSummaryConst.TotalEmp: TotalEmp,
  };

}
class DashboardSummaryConst {
  static const String AbsentCount = "AbsentCount";
  static const String LateCount = "LateCount";
  static const String PresentCount = "PresentCount";
  static const String TotalEmp = "TotalEmp";
}
class DashboardSummaryUrls {
  static const String GET_DASHBOARD_ATTENDANCE = 'Report/GetDashboardAttendanceSummary';

}
