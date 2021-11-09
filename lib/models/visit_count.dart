import 'package:digitalgeolocater/handlers/string_handlers.dart';

class VisitCount {
  int  AbsentCount;
  int HalfDayCount;
  int LateCount;
  int PresentCount;
  int TotalVisits;

  VisitCount({this.AbsentCount, this.HalfDayCount,this.LateCount,this.PresentCount,this.TotalVisits});
  factory VisitCount.fromJson(Map<String, dynamic> parsedJson) {
    return VisitCount(
      AbsentCount: parsedJson['AbsentCount']?? 0,
      HalfDayCount: parsedJson['HalfDayCount']?? 0,
      LateCount: parsedJson['LateCount']?? 0,
      PresentCount: parsedJson['PresentCount']?? 0,
      TotalVisits: parsedJson['TotalVisits']?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    VisitCountConst.AbsentCount: AbsentCount,
    VisitCountConst.HalfDayCount: HalfDayCount,
    VisitCountConst.LateCount: LateCount,
    VisitCountConst.PresentCount: PresentCount,
    VisitCountConst.TotalVisits: TotalVisits,
  };

}
class VisitCountConst {
  static const String AbsentCount = "AbsentCount";
  static const String HalfDayCount = "HalfDayCount";
  static const String LateCount = "LateCount";
  static const String PresentCount = "PresentCount";
  static const String TotalVisits = "TotalVisits";
}
class VisitCountConstUrls {
  static const String GET_DASHBOARD_VISIT = 'Report/GetDashboardVisits';
}
