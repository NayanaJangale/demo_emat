import 'package:digitalgeolocater/handlers/string_handlers.dart';
class VisitReport {
  int UserNo;
  String EmpName;
  DateTime EntDate;
  DateTime I;
  DateTime O;
  String Place;
  DateTime VI;
  DateTime VO;
  String PurposeCat;


  VisitReport({ this.UserNo, this.EmpName, this.EntDate, this.I,
      this.O, this.Place,this.VI,this.VO,this.PurposeCat});


  factory VisitReport.fromJson(Map<String, dynamic> parsedJson) {
    return VisitReport(
      UserNo: parsedJson[VisitReportConst.UserNo] ?? 0, 
      EmpName: parsedJson[VisitReportConst.EmpName] ?? StringHandlers.NotAvailable,
      EntDate:parsedJson[VisitReportConst.EntDate] != null
          ? DateTime.parse(parsedJson[VisitReportConst.EntDate])
          : null,
      I:parsedJson[VisitReportConst.I] != null
          ? DateTime.parse(parsedJson[VisitReportConst.I])
          : null,
      O:parsedJson[VisitReportConst.  O] != null
          ? DateTime.parse(parsedJson[VisitReportConst.  O])
          : null,
      Place: parsedJson[VisitReportConst.Place] ?? StringHandlers.NotAvailable,
      VI:parsedJson[VisitReportConst.VI] != null
          ? DateTime.parse(parsedJson[VisitReportConst.VI])
          : null,
      VO:parsedJson[VisitReportConst.VO] != null
          ? DateTime.parse(parsedJson[VisitReportConst.VO])
          : null,
      PurposeCat: parsedJson[VisitReportConst.PurposeCat] ?? StringHandlers.NotAvailable,
    );
  }



  Map<String, dynamic> toJson() => <String, dynamic>{
    VisitReportConst.UserNo: UserNo,
    VisitReportConst.EmpName: EmpName,
    VisitReportConst.EntDate: EntDate == null ? null : EntDate.toIso8601String(),
    VisitReportConst.I: I,
    VisitReportConst.O: O,
    VisitReportConst.Place: Place,
    VisitReportConst.VI: VI,
    VisitReportConst.VO: VO,
    VisitReportConst.PurposeCat: PurposeCat,
  };
}

class VisitReportConst {
  static const String UserNo = "UserNo";
  static const String EntDate = "EntDate";
  static const String EmpName = "EmpName";
  static const String I = "I";
  static const String O = "O";
  static const String Place = "Place";
  static const String VI = "VI";
  static const String VO = "VO";
  static const String PurposeCat = "PurposeCat";

}

class VisitReportUrls {
  static const String VISIT_REPORT =
      "Report/GetVisitReport";
}
