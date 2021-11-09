import 'package:digitalgeolocater/handlers/string_handlers.dart';

class User {
  int UserNo;
  String UserName;
  String BranchName;
  String Brcode;
  String UserID;
  String UserPass;
  int ClientId;
  int RoleNo;
  int RefUserNo;
  String ContactNo;
  int is_logged_in;
  String UserStatus;

  User({
    this.UserNo,
    this.UserName,
    this.BranchName,
    this.Brcode,
    this.UserID,
    this.UserPass,
    this.ClientId,
    this.RoleNo,
    this.RefUserNo,
    this.ContactNo,
    this.is_logged_in,
    this.UserStatus

  });
  User.fromJson(Map<String, dynamic> map) {
    UserNo = map[UserFieldNames.UserNo] ?? 0;
    UserName = map[UserFieldNames.UserName] ?? '';
    BranchName = map[UserFieldNames.BranchName] ?? '';
    Brcode = map[UserFieldNames.Brcode] ?? '';
    UserID = map[UserFieldNames.UserID] ?? '';
    UserPass = map[UserFieldNames.UserPass] ?? '';
    ClientId = map[UserFieldNames.ClientId] ?? 0;
    RoleNo = map[UserFieldNames.RoleNo] ?? 0;
    RefUserNo = map[UserFieldNames.RefUserNo] ?? 0;
    ContactNo = map[UserFieldNames.ContactNo] ?? '';
    is_logged_in = map[UserFieldNames.is_logged_in] ?? 0;
    UserStatus = map[UserFieldNames.UserStatus] ?? StringHandlers.NotAvailable;

  }

  /*User.fromMap(Map<String, dynamic> map) {
    UserNo =
        map[UserFieldNames.UserNo] ?? 0;
    UserID = map[UserFieldNames.UserID] ?? '';
    UserName = map[UserFieldNames.UserName] ?? StringHandlers.NotAvailable;
    BranchName = map[UserFieldNames.BranchName] ?? StringHandlers.NotAvailable;
    Brcode = map[UserFieldNames.Brcode] ?? StringHandlers.NotAvailable;
    UserPass = map[UserFieldNames.UserPass] ?? '';
    ClientId = map[UserFieldNames.ClientId] ?? 0;
    RoleNo = map[UserFieldNames.RoleNo] ?? 0;
    RefUserNo = map[UserFieldNames.RefUserNo] ?? '';
    ContactNo = map[UserFieldNames.ContactNo] ?? StringHandlers.NotAvailable;
    is_logged_in = map[UserFieldNames.is_logged_in] ?? 0;
    UserStatus = map[UserFieldNames.UserStatus] ?? StringHandlers.NotAvailable;

  }*/

  Map<String, dynamic> toJson() => <String, dynamic>{
        UserFieldNames.UserNo: UserNo,
        UserFieldNames.UserName: UserName,
        UserFieldNames.BranchName: BranchName,
        UserFieldNames.Brcode: Brcode,
        UserFieldNames.UserID: UserID,
        UserFieldNames.UserPass: UserPass,
        UserFieldNames.ClientId: ClientId,
        UserFieldNames.RoleNo: RoleNo,
        UserFieldNames.RefUserNo: RefUserNo,
        UserFieldNames.ContactNo: ContactNo,
        UserFieldNames.is_logged_in: is_logged_in,
        UserFieldNames.UserStatus: UserStatus

      };
}

class UserFieldNames {
  static const String UserNo = "UserNo";
  static const String UserName = "UserName";
  static const String BranchName = "BranchName";
  static const String Brcode = "Brcode";
  static const String UserID = "UserID";
  static const String UserPass = "UserPass";
  static const String MobileNo = "MobileNo";
  static const String ClientId = "ClientId";
  static const String RoleNo = "RoleNo";
  static const String RefUserNo = "RefUserNo";
  static const String ContactNo = 'ContactNo';
  static const String UserStatus = 'UserStatus';
  static const String is_logged_in = 'is_logged_in';
  static const String Domain = 'Domain';
  static const String macAddress = 'MacAddress';
  static const String userType = 'userType';
  static const String SessionUserNo = 'SessionUserNo';

  static const String OldPassword = "OldPassword";
  static const String NewPassword = "NewPassword";
}

class UserUrls {
  static const String GET_USER = 'Users/GetEmployeeDetails';
  static const String POST_UNIQUE_ID = 'Users/PostDeviceIdAndPassword';
  static const String CHANGE_PARENT_PASSWORD = 'Users/ChangeEmployeePassword';
  static const String POST_PASSWORD = 'SMS/PostPassword';
  static const String RESET_PASSWORD = 'SMS/ResetPassword';
  static const String GENERATE_OTP = 'SMS/GenerateOTP';
  static const String VALIDATE_OTP = 'SMS/ValidateOTP';
  static const String GET_REGISTRATION_CONFIG = 'Users/GetRegistrationConfig';

}
