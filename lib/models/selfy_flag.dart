class SelfyFlagAttendance {
  bool SelfyFlag = false;
  //int UserNo;

  SelfyFlagAttendance({
    this.SelfyFlag,
   // this.UserNo,
  });

  SelfyFlagAttendance.fromMap(Map<String, dynamic> map) {
    SelfyFlag = map[SelfyFlagConst.SelfyFlag];
  //  UserNo = map[SelfyFlagConst.UserNo];
  }
  factory SelfyFlagAttendance.fromJson(Map<String, dynamic> parsedJson) {
    return SelfyFlagAttendance(
      SelfyFlag: parsedJson['SelfyFlag'],
     // UserNo: parsedJson['UserNo'],
    );
  }
  factory SelfyFlagAttendance.fromJson1(Map<String, dynamic> parsedJson) {
    return SelfyFlagAttendance(
      SelfyFlag: parsedJson['SelfyFlag']==1? true:false,
      // UserNo: parsedJson['UserNo'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    SelfyFlagConst.SelfyFlag: SelfyFlag ? 1:0 ,
      };
}

class SelfyFlagConst {
  static const String SelfyFlag = "SelfyFlag";
  static const String UserNo = "UserNo";
}

class SelfyFlagUrls {
  static const String GET_SELFIE_FLAG = "Attendance/GetSelfieFlag";
}
