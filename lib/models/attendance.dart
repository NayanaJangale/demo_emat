import 'package:digitalgeolocater/handlers/string_handlers.dart';

class Attendance {
  int entNo;
  int UserNo;
  DateTime EntDate;
  String EntType;
  int ClientId;
  String PlaceDesc;
  String CPersonName;
  String ContactNo;
  String Brcode;
  String longitude;
  String latitude;
  DateTime EntTime;
  String MStatus;
  int SysRemark;
  String UserRemark;
  String UserId;
  DateTime EntDateTime;
  String UpdUserId;
  DateTime UpdDateTime;
  String Address;
  String Selfy;
  int EntClientId;
  String EntBrcode;
  String IsNet;
  String PassStatus;

  Attendance(
      {this.entNo,
      this.UserNo,
      this.EntDate,
      this.EntType,
      this.ClientId,
      this.PlaceDesc,
      this.CPersonName,
      this.ContactNo,
      this.Brcode,
      this.longitude,
      this.latitude,
      this.EntTime,
      this.MStatus,
      this.SysRemark,
      this.UserRemark,
      this.UserId,
      this.EntDateTime,
      this.UpdUserId,
      this.UpdDateTime,
      this.Address,
      this.Selfy,
      this.EntClientId,
      this.EntBrcode,
      this.IsNet,
      this.PassStatus
      });

  factory Attendance.fromJson(Map<String, dynamic> parsedJson) {
    return Attendance(
        entNo: parsedJson[AttendanceConst.entNo] ?? 0,
        UserNo: parsedJson[AttendanceConst.UserNo] ?? 0,
        EntDate: parsedJson["EntDate"] != null
            ? DateTime.parse(parsedJson["EntDate"])
            : null,
        EntType:
            parsedJson[AttendanceConst.EntType] ?? StringHandlers.NotAvailable,
        ClientId:
            parsedJson[AttendanceConst.ClientId] ?? 0,
        PlaceDesc: parsedJson[AttendanceConst.PlaceDesc] ??
            StringHandlers.NotAvailable,
        CPersonName: parsedJson[AttendanceConst.CPersonName] ??
            StringHandlers.NotAvailable,
        ContactNo: parsedJson[AttendanceConst.ContactNo] ??
            StringHandlers.NotAvailable,
        Brcode:
            parsedJson[AttendanceConst.Brcode] ?? StringHandlers.NotAvailable,
        longitude: parsedJson[AttendanceConst.longitude] ??
            StringHandlers.NotAvailable,
        latitude:
            parsedJson[AttendanceConst.latitude] ?? StringHandlers.NotAvailable,
        EntTime: parsedJson["EntTime"] != null
            ? DateTime.parse(parsedJson["EntTime"])
            : null,
        MStatus:
            parsedJson[AttendanceConst.MStatus] ?? StringHandlers.NotAvailable,
        SysRemark: parsedJson[AttendanceConst.SysRemark] ?? 0,
        UserRemark: parsedJson[AttendanceConst.UserRemark] ??
            StringHandlers.NotAvailable,
        UserId:
            parsedJson[AttendanceConst.UserId] ?? StringHandlers.NotAvailable,
        EntDateTime: parsedJson["EntDateTime"] != null
            ? DateTime.parse(parsedJson["EntDateTime"])
            : null,
        UpdUserId: parsedJson[AttendanceConst.UpdUserId] ??
            StringHandlers.NotAvailable,
        UpdDateTime: parsedJson["UpdDateTime"] != null
            ? DateTime.parse(parsedJson["UpdDateTime"])
            : null,
        Address:
            parsedJson[AttendanceConst.Address] ?? StringHandlers.NotAvailable,
        Selfy: parsedJson[AttendanceConst.Selfy] ?? null,
        EntClientId :  parsedJson[AttendanceConst.EntClientId] ?? 0,
        EntBrcode : parsedJson[AttendanceConst.EntBrcode] ?? StringHandlers.NotAvailable,
        IsNet : parsedJson[AttendanceConst.IsNet] ?? StringHandlers.NotAvailable,
        PassStatus : parsedJson[AttendanceConst.PassStatus] ?? StringHandlers.NotAvailable,

    );
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        AttendanceConst.entNo: entNo,
        AttendanceConst.UserNo: UserNo,
        AttendanceConst.EntDate:
            EntDate == null ? null : EntDate.toIso8601String(),
        AttendanceConst.EntType: EntType,
        AttendanceConst.ClientId: ClientId,
        AttendanceConst.Brcode: Brcode,
        AttendanceConst.PlaceDesc: PlaceDesc,
        AttendanceConst.CPersonName: CPersonName,
        AttendanceConst.ContactNo: ContactNo,
        AttendanceConst.longitude: longitude,
        AttendanceConst.latitude: latitude,
        AttendanceConst.EntTime:
            EntTime == null ? null : EntTime.toIso8601String(),
        AttendanceConst.MStatus: MStatus,
        AttendanceConst.SysRemark: SysRemark,
        AttendanceConst.UserRemark: UserRemark,
        AttendanceConst.UserId: UserId,
        AttendanceConst.EntDateTime:
            EntDateTime == null ? null : EntDateTime.toIso8601String(),
        AttendanceConst.UpdUserId: UpdUserId,
        AttendanceConst.UpdDateTime:
            UpdDateTime == null ? null : UpdDateTime.toIso8601String(),
        AttendanceConst.Address: Address,
        AttendanceConst.Selfy: Selfy ?? null,
       AttendanceConst.EntClientId: EntClientId,
       AttendanceConst.EntBrcode: EntBrcode,
       AttendanceConst.IsNet: IsNet,
       AttendanceConst.PassStatus: PassStatus,
      };


}

class AttendanceConst {
  static const String UserNo = "UserNo";
  static const String entNo = "entNo";
  static const String EntDate = "EntDate";
  static const String EntType = "EntType";
  static const String ClientId = "ClientId";
  static const String Brcode = "Brcode";
  static const String PlaceDesc = "PlaceDesc";
  static const String CPersonName = "CPersonName";
  static const String ContactNo = "ContactNo";
  static const String longitude = "longitude";
  static const String latitude = "latitude";
  static const String EntTime = "EntTime";
  static const String MStatus = "MStatus";
  static const String UserRemark = "UserRemark";
  static const String SysRemark = "SysRemark";
  static const String UserId = "UserId";
  static const String EntDateTime = "EntDateTime";
  static const String UpdUserId = "UpdUserId";
  static const String UpdDateTime = "UpdDateTime";
  static const String Address = "Address";
  static const String Selfy = "Selfy";
  static const String EntClientId = "EntClientId";
  static const String EntBrcode = "EntBrcode";
  static const String IsNet = "IsNet";
  static const String PassStatus = "PassStatus";
}

class AttendanceUrls {
  static const String POST_ATTENDANCE = "Attendance/PostAttendance";
}
