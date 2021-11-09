import 'package:digitalgeolocater/handlers/string_handlers.dart';
class AttendanceReport {
  String AtStatus;
  DateTime EntDate;
  DateTime Ent_IN;
  DateTime Ent_Out;
  String Place;
  String UserName;
  String LeavePerStatus;
  String PassStatus;
  String ExtraHrs;
  String WorkingHrs;



  AttendanceReport({this.AtStatus, this.EntDate, this.Ent_IN, this.Ent_Out,
      this.Place,this.UserName,this.LeavePerStatus ,this.PassStatus,this.ExtraHrs,this.WorkingHrs});

  factory AttendanceReport.fromJson(Map<String, dynamic> parsedJson) {
    return AttendanceReport(
      AtStatus: parsedJson[AttendanceReportConst.AtStatus] ??  StringHandlers.NotAvailable,
      EntDate:parsedJson[AttendanceReportConst.EntDate] != null
          ? DateTime.parse(parsedJson[AttendanceReportConst.EntDate])
          : null,
      Ent_IN:parsedJson[AttendanceReportConst.Ent_IN] != null
          ? DateTime.parse(parsedJson[AttendanceReportConst.Ent_IN])
          : null,
      Ent_Out:parsedJson[AttendanceReportConst.Ent_Out] != null
          ? DateTime.parse(parsedJson[AttendanceReportConst.Ent_Out])
          : null,
      Place: parsedJson[AttendanceReportConst.Place] ?? StringHandlers.NotAvailable,
      UserName: parsedJson[AttendanceReportConst.UserName] ??  StringHandlers.NotAvailable,
      LeavePerStatus: parsedJson[AttendanceReportConst.LeavePerStatus] ??  StringHandlers.NotAvailable,
      PassStatus: parsedJson[AttendanceReportConst.PassStatus] ??  StringHandlers.NotAvailable,
      ExtraHrs: parsedJson[AttendanceReportConst.ExtraHrs] ??  StringHandlers.NotAvailable,
      WorkingHrs: parsedJson[AttendanceReportConst.WorkingHrs] ??  StringHandlers.NotAvailable,
    );
  }



  Map<String, dynamic> toJson() => <String, dynamic>{
    AttendanceReportConst.AtStatus: AtStatus,
    AttendanceReportConst.EntDate: EntDate == null ? null : EntDate.toIso8601String(),
    AttendanceReportConst.Ent_IN: Ent_IN,
    AttendanceReportConst.Ent_Out: Ent_Out,
    AttendanceReportConst.Place: Place,
    AttendanceReportConst.UserName: UserName,
    AttendanceReportConst.LeavePerStatus: LeavePerStatus,
    AttendanceReportConst.PassStatus: PassStatus,
    AttendanceReportConst.ExtraHrs: ExtraHrs,
    AttendanceReportConst.WorkingHrs: WorkingHrs,
  };
}

class AttendanceReportConst {
  static const String AtStatus = "AtStatus";
  static const String EntDate = "EntDate";
  static const String Ent_IN = "Ent_IN";
  static const String Ent_Out = "Ent_Out";
  static const String Place = "Place";
  static const String UserName = "UserName";
  static const String LeavePerStatus = "LeavePerStatus";
  static const String PassStatus = "PassStatus";
  static const String ExtraHrs = "ExtraHrs";
  static const String WorkingHrs = "WorkingHrs";

}

class AttendanceReportUrls {
  static const String ATTENDANCE_REPORT ="Report/GetAttendanceDetails";
  static const String DASHBOARD_DETAIL ="Report/GetDashboardAttendanceDetail";
}
