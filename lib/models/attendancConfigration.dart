import 'package:digitalgeolocater/handlers/string_handlers.dart';

class AttendanceConfiguration {
  String Eitem ;
  String Etype;
  String Evalue;

  AttendanceConfiguration({
    this.Eitem,
    this.Etype,
    this.Evalue

  });
  AttendanceConfiguration.fromMap(Map<String, dynamic> map) {
    Eitem = map[ConfigurationFieldNames.Eitem] ?? StringHandlers.NotAvailable;
    Etype = map[ConfigurationFieldNames.Etype]?? StringHandlers.NotAvailable;
    Evalue = map[ConfigurationFieldNames.Evalue]?? StringHandlers.NotAvailable;
  }
  factory AttendanceConfiguration.fromJson(Map<String, dynamic> parsedJson) {
    return AttendanceConfiguration(
      Eitem: parsedJson['Eitem'],
      Etype: parsedJson['Etype'],
      Evalue: parsedJson['Evalue'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    ConfigurationFieldNames.Eitem: Eitem,
    ConfigurationFieldNames.Etype: Etype,
    ConfigurationFieldNames.Evalue: Evalue,
  };
}

class ConfigurationFieldNames {
  static const String Eitem = "Eitem";
  static const String Etype = "Etype";
  static const String Evalue = "Evalue";
}

class AttendanceConfigurationUrls {
  static const String GET_CONFIGURATION = "Users/GetAttendanceConfig";
  static const String GET_SELFIE_CONFIGURATION = "Attendance/GetAttendanceModeConfig";
}
