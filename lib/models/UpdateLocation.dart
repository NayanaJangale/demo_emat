import 'package:digitalgeolocater/handlers/string_handlers.dart';

class UpdatedLocation {
  String BranchName;
  String Brcode;
  int FloorNo;
  int Radius;

  UpdatedLocation({
    this.BranchName,
    this.Brcode,
    this.FloorNo,
    this.Radius
  });

  UpdatedLocation.fromMap(Map<String, dynamic> map) {
    BranchName = map[UpdatedLocationConst.BranchName]??StringHandlers.NotAvailable;
    Brcode = map[UpdatedLocationConst.Brcode]??0;
    FloorNo = map[UpdatedLocationConst.FloorNo]??0;
    Radius = map[UpdatedLocationConst.Radius]??0;
  }
  factory UpdatedLocation.fromJson(Map<String, dynamic> parsedJson) {
    return UpdatedLocation(
      BranchName: parsedJson['BranchName'],
      Brcode: parsedJson['Brcode'],
      FloorNo: parsedJson['FloorNo'],
      Radius: parsedJson['Radius'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    UpdatedLocationConst.BranchName: BranchName,
    UpdatedLocationConst.Brcode: Brcode,
    UpdatedLocationConst.FloorNo: FloorNo,
    UpdatedLocationConst.Radius: Radius,
      };
}

class UpdatedLocationConst {
  static const String BranchName = "BranchName";
  static const String Brcode = "Brcode";
  static const String FloorNo = "FloorNo";
  static const String Radius = "Radius";
}

class UpdatedLocationUrls {
  static const String GET_UPDATED_LOCATION = "Attendance/GetBranchLocation";
}
