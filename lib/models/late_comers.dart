
import 'package:digitalgeolocater/handlers/string_handlers.dart';

class LateComers {
  DateTime EntDate;
  String ExpectedTime;
  String In_Time;
  int LateByMinutes;
  String UserName;
  String AStatus;


  LateComers({
    this.EntDate,
    this.ExpectedTime,
    this.In_Time,
    this.LateByMinutes,
    this.UserName,
    this.AStatus,

  });


  factory LateComers.fromJson(Map<String, dynamic> parsedJson) {
    return LateComers(
      EntDate:parsedJson['EntDate'] != null
          ? DateTime.parse(parsedJson['EntDate'])
          : null,
      ExpectedTime:parsedJson['ExpectedTime'] ?? StringHandlers.NotAvailable,
      In_Time:parsedJson['In_Time']?? StringHandlers.NotAvailable,
      LateByMinutes: parsedJson['LateByMinutes'] ?? 0,
      UserName: parsedJson['UserName'] ?? StringHandlers.NotAvailable,
      AStatus: parsedJson['AStatus']??StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    LateComersConst.EntDate: EntDate,
    LateComersConst.ExpectedTime: ExpectedTime,
    LateComersConst.In_Time: In_Time,
    LateComersConst.LateByMinutes: LateByMinutes,
    LateComersConst.UserName: UserName,
    LateComersConst.AStatus: AStatus,
  };
}

class LateComersConst {
  static const String EntDate = "EntDate";
  static const String ExpectedTime = "ExpectedTime";
  static const String In_Time = "In_Time";
  static const String LateByMinutes = "LateByMinutes";
  static const String UserName = "UserName";
  static const String AStatus = "AStatus";
}

class  LateComersUrls {
  static const String GET_LATE_EMPLOYEE ="Report/GetLateEmployee";
  static const String GET_EARLY_OUT_EMPLOYEE ="Report/GetEarlyOutEmployee";
}
