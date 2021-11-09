import 'package:digitalgeolocater/handlers/string_handlers.dart';

class Configuration {
  String ConfigurationGroup;
  String  ConfigurationName;
  String ConfigurationValue;

  Configuration({
    this.ConfigurationGroup,
    this.ConfigurationName,
    this.ConfigurationValue

  });
  Configuration.fromMap(Map<String, dynamic> map) {
    ConfigurationGroup = map[ConfigurationFieldNames.ConfigurationGroup] ?? 0;
    ConfigurationName = map[ConfigurationFieldNames.ConfigurationName]?? StringHandlers.NotAvailable;
    ConfigurationValue = map[ConfigurationFieldNames.ConfigurationValue]?? 0;
  }
  factory Configuration.fromJson(Map<String, dynamic> parsedJson) {
    return Configuration(
      ConfigurationGroup: parsedJson['ConfigurationGroup'],
      ConfigurationName: parsedJson['ConfigurationName'],
      ConfigurationValue: parsedJson['ConfigurationValue'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    ConfigurationFieldNames.ConfigurationGroup: ConfigurationGroup,
    ConfigurationFieldNames.ConfigurationName: ConfigurationName,
    ConfigurationFieldNames.ConfigurationValue: ConfigurationValue,
  };
}

class ConfigurationFieldNames {
  static const String ConfigurationGroup = "ConfigurationGroup";
  static const String ConfigurationName = "ConfigurationName";
  static const String ConfigurationValue = "ConfigurationValue";
}

class ConfigurationUrls {
  static const String GET_CONFIGURATION = "Users/GetConfigurationMst";
}
