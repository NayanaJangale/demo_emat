import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:digitalgeolocater/models/attendance.dart';

class LocationTime {
  DateTime EntDateTime;
  LocationTime({this.EntDateTime});

  Map<String, dynamic> toJson() => <String, dynamic>{
    AttendanceConst.EntDateTime:
    EntDateTime == null ? null : EntDateTime.toIso8601String(),

  };
  factory LocationTime.fromJson(Map<String, dynamic> parsedJson) {
    return LocationTime(
      EntDateTime: parsedJson["EntDateTime"] != null
          ? DateTime.parse(parsedJson["EntDateTime"])
          : null,
    );
  }

}

