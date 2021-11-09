

import 'package:digitalgeolocater/handlers/string_handlers.dart';

class EarlyOut{
  DateTime EntDate;
  String ExpectedTime;
  String Out_Time;
  int EarlyByMinutes;
  String UserName;
  String AStatus;


  EarlyOut({
    this.EntDate,
    this.ExpectedTime,
    this.Out_Time,
    this.EarlyByMinutes,
    this.UserName,
    this.AStatus,

  });


  factory EarlyOut.fromJson(Map<String, dynamic> parsedJson) {
    return EarlyOut(
      EntDate:parsedJson['EntDate'] != null
          ? DateTime.parse(parsedJson['EntDate'])
          : null,
      ExpectedTime:parsedJson['ExpectedTime'] ?? StringHandlers.NotAvailable,
      Out_Time:parsedJson['Out_Time']?? StringHandlers.NotAvailable,
     /* ExpectedTime:parsedJson['ExpectedTime'] != null
          ? DateTime.parse("2020-11-04T"+parsedJson['ExpectedTime'])
          : null,
      Out_Time:parsedJson['Out_Time'] != null
          ? DateTime.parse("2020-11-04T"+parsedJson['Out_Time'])
          : null,*/
      EarlyByMinutes: parsedJson['EarlyByMinutes'] ?? 0,
      UserName: parsedJson['UserName'] ?? StringHandlers.NotAvailable,
      AStatus: parsedJson['AStatus']??StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    EarlyOutConst.EntDate: EntDate,
    EarlyOutConst.ExpectedTime: ExpectedTime,
    EarlyOutConst.Out_Time: Out_Time,
    EarlyOutConst.EarlyByMinutes: EarlyByMinutes,
    EarlyOutConst.UserName: UserName,
    EarlyOutConst.AStatus: AStatus,
  };
}

class EarlyOutConst {
  static const String EntDate = "EntDate";
  static const String ExpectedTime = "ExpectedTime";
  static const String Out_Time = "Out_Time";
  static const String EarlyByMinutes = "EarlyByMinutes";
  static const String UserName = "UserName";
  static const String AStatus = "AStatus";
}

class EarlyOutUrls {
  static const String GET_EARLY_OUT_EMPLOYEE ="Report/GetEarlyOutEmployee";
}
