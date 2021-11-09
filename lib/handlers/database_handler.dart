import 'dart:io';
import 'package:digitalgeolocater/models/attendancConfigration.dart';
import 'package:digitalgeolocater/models/attendance.dart';
import 'package:digitalgeolocater/models/branch.dart';
import 'package:digitalgeolocater/models/client.dart';
import 'package:digitalgeolocater/models/location_time.dart';
import 'package:digitalgeolocater/models/menu.dart';
import 'package:digitalgeolocater/models/notification.dart';
import 'package:digitalgeolocater/models/purpose.dart';
import 'package:digitalgeolocater/models/selfy_flag.dart';
import 'package:digitalgeolocater/models/tracking_status.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHandler {
  static const int DB_VERSION = 9;
  static Database _db;
  static const String DB_NAME = 'DigitalAttde.db';
  static const String TABLE_USER_MASTER = 'user_master';
  static const String TABLE_MENU_MASTER = 'MenuMaster';
  static const String TABLE_NOTIFICATION_MASTER = 'NotificationMaster';
  static const String TABLE_CURRENT_BRNACH_MASTER = 'CurrentBranchMaster';
  static const String TABLE_BRNACH_MASTER = 'BranchMaster';
  static const String TABLE_ATTENDANCE_MASTER = 'AttendanceMaster';
  static const String TABLE_ATTENDANCE_SELFY_FLAG = 'SelfyMaster';
  static const String TABLE_PURPOSE_MASTER = 'PurposeMaster';
  static const String TABLE_ATTENDANCE_CONFIGRATION = 'ConfigrationMaster';
  static const String TABLE_LOCATION_TIME = 'LocationMaster';
  static const String TABLE_LOCATION_STATUS = 'TrackingStatusMaster';
  static const String TRUE = 'true';
  String UserStatus;
  int is_logged_in;
  static const String CREATE_USER_MASTER_TABLE =
      'CREATE TABLE $TABLE_USER_MASTER (' +
          '${UserFieldNames.UserNo} INTEGER,' +
          '${UserFieldNames.UserName} TEXT,' +
          '${UserFieldNames.BranchName} TEXT,' +
          '${UserFieldNames.Brcode} TEXT,' +
          '${UserFieldNames.UserID} TEXT,' +
          '${UserFieldNames.UserPass} TEXT,' +
          '${UserFieldNames.ClientId} INTEGER,' +
          '${UserFieldNames.RoleNo} INTEGER,' +
          '${UserFieldNames.RefUserNo} INTEGER,' +
          '${UserFieldNames.ContactNo} TEXT,' +
          '${UserFieldNames.is_logged_in} INTEGER,' +
          '${UserFieldNames.UserStatus} TEXT)';

  static const String CREATE_MENU_MASTER_TABLE =
      'CREATE TABLE $TABLE_MENU_MASTER (' +
          '${MenuFieldNames.Id} INTEGER,' +
          '${MenuFieldNames.MenuName} TEXT,' +
          '${MenuFieldNames.ParentId} INTEGER,' +
          '${MenuFieldNames.UserNo} INTEGER)';
  
  static const String CREATE_NOTIFICATION_TABLE =
      'CREATE TABLE $TABLE_NOTIFICATION_MASTER (' +
          '${NotificationFieldNames.NotificationDateTime} DATETIME,' +
          '${NotificationFieldNames.Title} TEXT,' +
          '${NotificationFieldNames.Content} TEXT,' +
          '${NotificationFieldNames.UserNo} TEXT,' +
          '${NotificationFieldNames.BranchCode} TEXT,' +
          '${NotificationFieldNames.ClientCode} TEXT,' +
          '${NotificationFieldNames.NotificationFor} TEXT,' +
          '${NotificationFieldNames.Topic} TEXT,' +
          '${NotificationFieldNames.isRead} TEXT)';

  static const String CREATE_CURRENT_BRANCH_TABLE =
      'CREATE TABLE $TABLE_CURRENT_BRNACH_MASTER (' +
          '${ClientConst.BranchName} TEXT,' +
          '${ClientConst.Brcode} TEXT,' +
          '${ClientConst.ClientId} INTEGER,' +
          '${ClientConst.FloorNo} INTEGER,' +
          '${ClientConst.latitude} TEXT,' +
          '${ClientConst.longitude} TEXT)';

  static const String CREATE_BRANCH_TABLE =
      'CREATE TABLE $TABLE_BRNACH_MASTER (' +
          '${BranchConst.BranchName} TEXT,' +
          '${BranchConst.brcode} TEXT,' +
          '${BranchConst.ClientId} INTEGER,' +
          '${BranchConst.client_no} INTEGER,' +
          '${BranchConst.Domain} INTEGER)';

  static const String CREATE_ATTENDANCE_TABLE =
      'CREATE TABLE $TABLE_ATTENDANCE_MASTER (' +
          '${AttendanceConst.entNo} INTEGER,' +
          '${AttendanceConst.UserNo} INTEGER,' +
          '${AttendanceConst.EntDate} DATETIME,' +
          '${AttendanceConst.EntType} TEXT,' +
          '${AttendanceConst.ClientId} INTEGER,' +
          '${AttendanceConst.PlaceDesc} TEXT,' +
          '${AttendanceConst.CPersonName} TEXT,' +
          '${AttendanceConst.ContactNo} TEXT,' +
          '${AttendanceConst.Brcode} TEXT,' +
          '${AttendanceConst.longitude} TEXT,' +
          '${AttendanceConst.latitude} TEXT,' +
          '${AttendanceConst.EntTime} latitude,' +
          '${AttendanceConst.SysRemark} INTEGER,' +
          '${AttendanceConst.MStatus} TEXT,' +
          '${AttendanceConst.UserRemark} TEXT,' +
          '${AttendanceConst.UserId} TEXT,' +
          '${AttendanceConst.EntDateTime} DATETIME,' +
          '${AttendanceConst.UpdUserId} TEXT,' +
          '${AttendanceConst.UpdDateTime} DATETIME,' +
          '${AttendanceConst.Address} TEXT,'+
          '${AttendanceConst.Selfy} TEXT,'+
          '${AttendanceConst.EntClientId} INTEGER,' +
          '${AttendanceConst.EntBrcode} TEXT,' +
          '${AttendanceConst.IsNet} TEXT,' +
          '${AttendanceConst.PassStatus} TEXT)';

   static const String CREATE_ATTENDANCE_SELFY_FLAG =
      'CREATE TABLE $TABLE_ATTENDANCE_SELFY_FLAG (' +
          '${SelfyFlagConst.SelfyFlag} INTEGER)';

  static const String CREATE_PURPOSE_MASTER =
      'CREATE TABLE $TABLE_PURPOSE_MASTER (' +
          '${PurposeConst.EntNo} INTEGER,' +
          '${PurposeConst.SysRemark} TEXT)';

  static const String CREATE_ATTENDANCE_CONFIGRATION =
      'CREATE TABLE $TABLE_ATTENDANCE_CONFIGRATION (' +
          '${ConfigurationFieldNames.Eitem} TEXT,' +
          '${ConfigurationFieldNames.Etype} TEXT,' +
          '${ConfigurationFieldNames.Evalue} TEXT)';

  static const String CREATE_LOCATION_TIME =
      'CREATE TABLE $TABLE_LOCATION_TIME (' +
          '${AttendanceConst.EntDateTime} DATETIME)';

  static const String CREATE_LOCATION_STATUS =
      'CREATE TABLE $TABLE_LOCATION_STATUS (' +
          '${TrackingStatusConst.Status} INTEGER)';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDatabase();
    }
    return _db;
  }
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
    );
    return db;
  }
  _onCreate(Database db, int version) async {
    //Create User TABLE_USER
    await db.execute(CREATE_USER_MASTER_TABLE);
    await db.execute(CREATE_MENU_MASTER_TABLE);
    await db.execute(CREATE_NOTIFICATION_TABLE);
    await db.execute(CREATE_CURRENT_BRANCH_TABLE);
    await db.execute(CREATE_BRANCH_TABLE);
    await db.execute(CREATE_ATTENDANCE_TABLE);
    await db.execute(CREATE_ATTENDANCE_SELFY_FLAG);
    await db.execute(CREATE_PURPOSE_MASTER);
    await db.execute(CREATE_ATTENDANCE_CONFIGRATION);
    await db.execute(CREATE_LOCATION_TIME);
    await db.execute(CREATE_LOCATION_STATUS);
  }
  Future<User> saveUser(User user) async {
    try {
      var dbClient = await db;
      await dbClient.insert(
        TABLE_USER_MASTER,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return user;
    } catch (e) {
      return null;
    }
  }
  Future<User> login(User user) async {
    try {
      var dbClient = await db;

      //  user.Login_Status = 'true';
      user.is_logged_in = 1;

      await dbClient.update(
        TABLE_USER_MASTER,
        user.toJson(),
        where:
            '${UserFieldNames.UserID} = ? AND ${UserFieldNames.UserPass} = ?',
        whereArgs: [
          user.UserID,
          user.UserPass,
        ],
      );

      User updatedUser = await getUser(user.UserID, user.UserPass);
      return updatedUser;
    } catch (e) {
      return null;
    }
  }
  Future<User> logout(User user) async {
    try {
      var dbClient = await db;
      //user.Login_Status = 'false';
      user.is_logged_in = 0;
      await dbClient.delete(
        TABLE_USER_MASTER,
        where: "${MenuFieldNames.UserNo} = ?",
        whereArgs: [user.UserNo],
      );
      await dbClient.delete(TABLE_USER_MASTER);
      return user;
    } catch (e) {
      return null;
    }
  }
  Future<User> updateUser(User user) async {
    try {
      var dbClient = await db;
      await dbClient.update(
        TABLE_USER_MASTER,
        user.toJson(),
        where: '${UserFieldNames.UserID} = ?',
        whereArgs: [
          user.UserPass,
        ],
      );
      return user;
    } catch (e) {
      return null;
    }
  }
  Future<User> getLoggedInUser() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_USER_MASTER WHERE ${UserFieldNames.is_logged_in} = 1",
        null,
      );

      return User.fromJson(maps[0]);
    } catch (e) {
      return null;
    }
  }
  Future<User> getUser(String userID, String userPassword) async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_USER_MASTER WHERE ${UserFieldNames.UserID} = ? AND ${UserFieldNames.UserPass} = ?",
        [
          userID,
          userPassword,
        ],
      );

      return User.fromJson(maps[0]);
    } catch (e) {
      return null;
    }
  }
  Future<List<User>> getUsersList() async {
    try {
      var dbClient = await db;
      final List<Map<String, dynamic>> maps =
          await dbClient.query(TABLE_USER_MASTER);

      List<User> users = [];
      users = maps
          .map(
            (item) => User.fromJson(item),
          )
          .toList();

      return users;
    } catch (e) {
      return null;
    }
  }
  Future<void> saveMenu(List<Menu> menus, int UserNo) async {
    try {
      var dbClient = await db;
      for (var menu in menus) {
        menu.UserNo = UserNo;

        int a = await dbClient.insert(
          TABLE_MENU_MASTER,
          menu.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('menu saved:$a');
        print('menu saved:${menu.MenuName}');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<bool> deleteMenu(int userNo, int parentid) async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_MENU_MASTER,
        where: "${MenuFieldNames.ParentId} = ?",
        whereArgs: [parentid],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<bool> deleteAllMenus() async {
    try {
      var dbClient = await db;
      await dbClient.delete(TABLE_MENU_MASTER);
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<List<Menu>> getMenus(int userNo,int ParentId) async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(
      /*  "SELECT * FROM $TABLE_MENU_MASTER",// WHERE ${MenuFieldNames.UserNo} = ? AND ${MenuFieldNames.ParentId} = ?",
        [
          userNo,
          ParentId,
        ],*/
        "SELECT * FROM $TABLE_MENU_MASTER WHERE ${MenuFieldNames.ParentId} = $ParentId",
      );

      List<Menu> m;
      m = maps
          .map(
            (item) => Menu.fromMap(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<void> saveNotification(Notification notification) async {
    try {
      var dbClient = await db;
      int a = await dbClient.insert(
        TABLE_NOTIFICATION_MASTER,
        notification.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print(a);
    } catch (e) {
      print('Save notification : ' + e.toString());
      return null;
    }
  }
  Future<List<Notification>> getNotifications(String studentNo, String brcode, String clientCode) async {
    try {
      var dbClient = await db;
      List<
          Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE_NOTIFICATION_MASTER "
          " WHERE ${NotificationFieldNames.UserNo} = '$studentNo'"
          " AND ${NotificationFieldNames.BranchCode} = '$brcode'"
          " AND ${NotificationFieldNames.ClientCode} = '$clientCode'"
          " ORDER BY " +
          NotificationFieldNames.NotificationDateTime +
          " DESC LIMIT 20");
      List<Notification> notifications = maps
          .map(
            (item) => Notification.fromMap(item),
      )
          .toList();
      return notifications;
    } catch (e) {
      print('Get notification : ' + e.toString());
      return null;
    }
  }
  Future<void> saveBranch(List<Client> currentBranch) async {
    try {
      var dbClient = await db;
      for (var branch in currentBranch) {
        int a = await dbClient.insert(
          TABLE_CURRENT_BRNACH_MASTER,
          branch.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Branch saved:$a');
        print('Branch saved:${branch.BranchName}');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<bool> deleteCurrentBranch(String brcode) async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_CURRENT_BRNACH_MASTER,
        where: "${ClientConst.Brcode} = ?",
        whereArgs: [brcode],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<User> getUserByUserNo(int UserNo) async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_USER_MASTER WHERE ${UserFieldNames.UserNo} = $UserNo",
      );

      List<User> users;
      users = maps
          .map(
            (item) => User.fromJson(item),
      )
          .toList();
      return users[0];
    } catch (e) {
      return null;
    }
  }
  Future<List<Client>> getCurrentBranch(int clientId, String brcode) async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(

        "SELECT * FROM $TABLE_CURRENT_BRNACH_MASTER WHERE ${ClientConst.ClientId} = $clientId"
              " AND ${ClientConst.Brcode} = '$brcode'",
      );

      List<Client> m;
      m = maps
          .map(
            (item) => Client.fromJson(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<List<Client>> getCurrentClientForVisit(int clientId) async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(

        "SELECT * FROM $TABLE_CURRENT_BRNACH_MASTER WHERE ${ClientConst.ClientId} = $clientId",
      );
      List<Client> m;
      m = maps
          .map(
            (item) => Client.fromJson(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<void> saveClientBranches(List<Branch> branch) async {
    try {
      var dbClient = await db;
      for (var branch in branch) {
        int a = await dbClient.insert(
          TABLE_BRNACH_MASTER,
          branch.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Branch saved:$a');
        print('Branch saved:${branch.BranchName}');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<bool> deleteClientBranches(int clientId) async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_BRNACH_MASTER,
        where: "${ClientConst.ClientId} = ?",
        whereArgs: [clientId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<List<Branch>> getClientBranches(int clientId) async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(

        "SELECT * FROM $TABLE_BRNACH_MASTER WHERE ${ClientConst.ClientId} = $clientId",
            //" AND ${ClientConst.Brcode} = '$brcode'",
      );

      List<Branch> m;
      m = maps
          .map(
            (item) => Branch.fromJson(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<List<Branch>> getClientBranchesByBrcode(int clientId ,String brcode) async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(

        "SELECT * FROM $TABLE_BRNACH_MASTER WHERE ${ClientConst.ClientId} = $clientId"
            " AND ${ClientConst.Brcode} = '$brcode'",
      );

      List<Branch> m;
      m = maps
          .map(
            (item) => Branch.fromJson(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<Attendance> saveAttendance(Attendance attendance) async {
    try {
      var dbClient = await db;
      dbClient.insert(
        TABLE_ATTENDANCE_MASTER,
        attendance.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return attendance;
    } catch (e) {
      print('not Save attendance : ' + e.toString());
      return null;
    }
  }
  Future<List<Attendance>> getAttendanceRecord() async {
    try {

      var dbClient = await db;
      final List<Map<String, dynamic>> maps =
      await dbClient.query(TABLE_ATTENDANCE_MASTER);
      List<Attendance> attendance = [];
      attendance = maps
          .map(
            (item) => Attendance.fromJson(item),
      ).toList();
      return attendance;
    } catch (e) {
      return null;
    }
  }
  Future<int> getCount() async {
    //database connection
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_ATTENDANCE_MASTER",
          );
      return maps.length;
    } catch (e) {
      return 0;

    }
  }
  Future<bool> deleteAttendance(int entNo) async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_ATTENDANCE_MASTER,
        where: "${AttendanceConst.entNo} = ?",
        whereArgs: [entNo],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<SelfyFlagAttendance> saveUserSelfyFlag(SelfyFlagAttendance selfyFlag) async {
    try {
      var dbClient = await db;
      await dbClient.insert(
        TABLE_ATTENDANCE_SELFY_FLAG,
        selfyFlag.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return selfyFlag;
    } catch (e) {
      return null;
    }
  }
  Future<bool> deleteUserSelfyFlag() async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_ATTENDANCE_SELFY_FLAG,
        //where: "${MenuFieldNames.UserNo} = ?",
        //whereArgs: [userNo],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<SelfyFlagAttendance> getUserSelfyFlag() async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_ATTENDANCE_SELFY_FLAG ",
      );

      List<SelfyFlagAttendance> selfy;
      selfy = maps
          .map(
            (item) => SelfyFlagAttendance.fromJson1(item),
      )
          .toList();
      return selfy[0];
    } catch (e) {
      return null;
    }
  }
  Future<void> savePurpose(List<Purpose> pupose) async {
    try {
      var dbClient = await db;
      for (var pur in pupose) {

        int a = await dbClient.insert(
          TABLE_PURPOSE_MASTER,
          pur.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Purpose saved:$a');
        print('Purpose saved:${pur.SysRemark}');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<bool> deletePurpose() async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_PURPOSE_MASTER,

      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<List<Purpose>> getPurpose() async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_PURPOSE_MASTER",
      );
      List<Purpose> m;
      m = maps
          .map(
            (item) => Purpose.fromMap(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<void> saveAttendanceConfig(List<AttendanceConfiguration> config) async {
    try {
      var dbClient = await db;
      for (var con in config) {

        int a = await dbClient.insert(
          TABLE_ATTENDANCE_CONFIGRATION,
          con.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Configration saved:$a');
        print('Configration saved:${con.Eitem}');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> saveLocationTime(LocationTime time) async {
    try {
      var dbClient = await db;
      int a = await dbClient.insert(
        TABLE_LOCATION_TIME,
        time.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('TIME saved:$a.');
    } catch (e) {
      print(e);
    }
  }
  Future<bool> deleteLocationTime() async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_LOCATION_TIME,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<List<LocationTime>> getLocationTime() async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_LOCATION_TIME",
      );
      List<LocationTime> m;
      m = maps
          .map(
            (item) => LocationTime.fromJson(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<bool> deleteAttendanceConfig() async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_ATTENDANCE_CONFIGRATION,

      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<List<AttendanceConfiguration>> getAttendanceConfig() async {
    try {
      var dbClient = await db;
      final List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_ATTENDANCE_CONFIGRATION",
      );
      List<AttendanceConfiguration> m;
      m = maps
          .map(
            (item) => AttendanceConfiguration.fromMap(item),
      )
          .toList();
      return m;
    } catch (e) {
      return null;
    }
  }
  Future<TrackingStatus> saveTrackingStatus(TrackingStatus status) async {
    try {
      var dbClient = await db;
      await dbClient.insert(
        TABLE_LOCATION_STATUS,
        status.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return status;
    } catch (e) {
      return null;
    }
  }
  Future<bool> deleteTrackingStatus() async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        TABLE_LOCATION_STATUS,

      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<TrackingStatus> getTrackingStatus() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_LOCATION_STATUS ",
      );
      return TrackingStatus.fromJson(maps[0]);
    } catch (e) {
      return null;
    }
  }

}
