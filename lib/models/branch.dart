import 'package:digitalgeolocater/handlers/string_handlers.dart';

class Branch {
  String BranchName;
  String brcode;
  int ClientId;
  int client_no;
  int Domain;

  Branch({this.BranchName, this.brcode, this.ClientId,this.client_no,this.Domain});
  factory Branch.fromJson(Map<String, dynamic> parsedJson) {
    return Branch(
      BranchName: parsedJson['BranchName']??
          StringHandlers.NotAvailable,
      brcode: parsedJson['brcode']??
          StringHandlers.NotAvailable,
      ClientId: parsedJson['ClientId']?? 0,
      client_no: parsedJson['client_no']?? 0,
      Domain: parsedJson['Domain']?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    BranchConst.BranchName: BranchName,
    BranchConst.brcode: brcode,
    BranchConst.ClientId: ClientId,
    BranchConst.client_no: client_no,
    BranchConst.Domain: Domain,
  };

}
class BranchConst {
  static const String BranchName = "BranchName";
  static const String brcode = "brcode";
  static const String ClientId = "ClientId";
  static const String client_no = "client_no";
  static const String Domain = "Domain";
}
class BranchUrls {
  static const String GET_CLIENT = 'Attendance/GetClientForOfficeAtt';
  static const String GET_BRANCH = 'Attendance/GetBranchtlist';
  static const String GET_BRANCH_FOR_ATTENDANCE = 'Attendance/GetBranchtlistForAttendance';
}
