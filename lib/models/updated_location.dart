import 'package:digitalgeolocater/handlers/string_handlers.dart';

class UpdateLocation {
  int ClientId;
  String Brcode;
  int FloorNo;
  String Latitude;
  String Longitude;
  String Altitude;
  String UserId;
  DateTime EntDateTime;
  int Radius;


  UpdateLocation({this.ClientId, this.Brcode, this.FloorNo,
      this.Latitude, this.Longitude, this.Altitude, this.UserId,
      this.EntDateTime,this.Radius});

  factory UpdateLocation.fromJson(Map<String, dynamic> parsedJson) {
    return UpdateLocation(
      ClientId: parsedJson['ClientId']?? 0,
      Brcode: parsedJson['Brcode']?? StringHandlers.NotAvailable,
      FloorNo: parsedJson['FloorNo']?? 0,
      Latitude: parsedJson['Latitude']?? StringHandlers.NotAvailable,
      Longitude: parsedJson['Longitude']?? StringHandlers.NotAvailable,
      Altitude: parsedJson['Altitude']?? StringHandlers.NotAvailable,
      UserId: parsedJson['UserId']?? StringHandlers.NotAvailable,
      EntDateTime: parsedJson["EntDateTime"] != null
          ? DateTime.parse(parsedJson["EntDateTime"])
          : null,
      Radius: parsedJson['Radius']?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    LocationConst.ClientId: ClientId,
    LocationConst.Brcode: Brcode,
    LocationConst.FloorNo: FloorNo,
    LocationConst.Latitude: Latitude,
    LocationConst.Longitude: Longitude,
    LocationConst.Altitude: Altitude,
    LocationConst.UserId: UserId,
    LocationConst.EntDateTime :EntDateTime == null ? null : EntDateTime.toIso8601String(),
    LocationConst.Radius :Radius ,
  };



}
class LocationConst {
  static const String FloorNo = "FloorNo";
  static const String Brcode = "Brcode";
  static const String ClientId = "ClientId";
  static const String Latitude = "Latitude";
  static const String Longitude = "Longitude";
  static const String Altitude = "Altitude";
  static const String UserId = "UserId";
  static const String EntDateTime = "EntDateTime";
  static const String Radius = "Radius";
}
class LocationUrls {
  static const String POST_LOCATION = 'Attendance/PostBranchLocation';

}
