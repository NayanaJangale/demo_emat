import 'package:digitalgeolocater/handlers/string_handlers.dart';

class Client {
  String BranchName;
  String Brcode;
  int ClientId;
  int FloorNo;
  double distance;
  String latitude;
  String longitude;

  Client({this.BranchName, this.Brcode, this.ClientId, this.FloorNo,
      this.distance,this.latitude,this.longitude});
  factory Client.fromJson(Map<String, dynamic> parsedJson) {
    return Client(
      BranchName: parsedJson['BranchName']?? StringHandlers.NotAvailable,
      Brcode: parsedJson['Brcode']?? StringHandlers.NotAvailable,
      ClientId: parsedJson['ClientId']?? 0,
      FloorNo: parsedJson['FloorNo']?? 0.0,
      latitude: parsedJson['latitude']?? "0",
      longitude: parsedJson['longitude']?? "0",
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    ClientConst.BranchName: BranchName,
    ClientConst.Brcode: Brcode,
    ClientConst.ClientId: ClientId,
    ClientConst.FloorNo: FloorNo,
    ClientConst.latitude: latitude,
    ClientConst.longitude: longitude,
  };



}
class ClientConst {
  static const String BranchName = "BranchName";
  static const String Brcode = "Brcode";
  static const String ClientId = "ClientId";
  static const String FloorNo = "FloorNo";
  static const String latitude = "latitude";
  static const String longitude = "longitude";
}
class ClientUrls {
  static const String GET_CLIENT = 'Attendance/GetClientForOfficeAtt';
  static const String GET_VISIT_CLIENT = 'Attendance/GetClientForVisit';
}
