import 'package:digitalgeolocater/handlers/string_handlers.dart';

class Calender {
  String h_Status;
  String h_Desc;
  DateTime eDate;



  Calender({this.h_Status, this.h_Desc, this.eDate});

  factory Calender.fromJson(Map<String, dynamic> parsedJson) {
    return Calender(
      h_Status: parsedJson['h_Status']?? 0,
      h_Desc: parsedJson['h_Desc']?? StringHandlers.NotAvailable,
      eDate: parsedJson["eDate"] != null
          ? DateTime.parse(parsedJson["eDate"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    CalenderConst.h_Status: h_Status,
    CalenderConst.h_Desc: h_Desc,
    CalenderConst.eDate :eDate == null ? null : eDate.toIso8601String(),
  };



}
class CalenderConst {
  static const String h_Status = "h_Status";
  static const String h_Desc = "h_Desc";
  static const String eDate = "eDate";
}
class CalenderUrls {
  static const String GET_CALENDER = 'Leave/GetCalender';

}
