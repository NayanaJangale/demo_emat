import 'package:digitalgeolocater/handlers/string_handlers.dart';

class LocationTrack{
  double latitude;
  double longitude;
  double altitude;
  bool isMocked;
  DateTime Entdate;
  DateTime EntDateTime;
  int ClientId;
  int UserNo;
  String Brcode;
  String UserId;
  String address;

  LocationTrack({this.latitude, this.longitude, this.altitude,this.isMocked,this.Entdate ,this.EntDateTime, this.ClientId,this.UserNo,this.Brcode,this.UserId,this.address});
  factory LocationTrack.fromJson(Map<String, dynamic> parsedJson) {
    return LocationTrack(
      latitude: parsedJson['latitude']??
         0.0,
      longitude: parsedJson['longitude']??
          0.0,
      altitude: parsedJson['altitude']?? 0.0,
      isMocked: parsedJson['isMocked']?? false,
      Entdate: parsedJson["Entdate"] != null
          ? DateTime.parse(parsedJson["Entdate"])
          : null,
      EntDateTime: parsedJson["EntDateTime"] != null
          ? DateTime.parse(parsedJson["EntDateTime"])
          : null,
      ClientId: parsedJson['ClientId']?? 0,
      UserNo: parsedJson['UserNo']?? 0,
      Brcode: parsedJson['Brcode']??  StringHandlers.NotAvailable,
      UserId: parsedJson['UserId']??  StringHandlers.NotAvailable,
      address: parsedJson['address']??  StringHandlers.NotAvailable,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    LocationConst.latitude: latitude,
    LocationConst.longitude: longitude,
    LocationConst.altitude: altitude,
    LocationConst.isMocked: isMocked,
    LocationConst.Entdate:
    Entdate == null ? null : Entdate.toIso8601String(),
    LocationConst.EntDateTime:
    EntDateTime == null ? null : EntDateTime.toIso8601String(),
    LocationConst.ClientId: ClientId,
    LocationConst.UserNo: UserNo,
    LocationConst.Brcode: Brcode,
    LocationConst.UserId: UserId,
    LocationConst.address: address,
  };

}
class LocationConst {
  static const String latitude = "latitude";
  static const String longitude = "longitude";
  static const String altitude = "altitude";
  static const String isMocked = "isMocked";
  static const String Entdate = "Entdate";
  static const String EntDateTime = "EntDateTime";
  static const String ClientId = "ClientId";
  static const String UserNo = "UserNo";
  static const String Brcode = "Brcode";
  static const String UserId = "UserId";
  static const String address = "address";
}
class LocationUrls {
  static const String POST_LOCATION= 'LocationTracking/PostLocationTrack';
  static const String GET_LOCATION_TRACK= 'LocationTracking/GetLocationTrack';
}
