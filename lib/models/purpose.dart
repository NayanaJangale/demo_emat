class Purpose {
  int EntNo;
  String SysRemark;


  Purpose({
    this.EntNo,
    this.SysRemark,
  
  });

  Purpose.fromMap(Map<String, dynamic> map) {
    EntNo = map[PurposeConst.EntNo];
    SysRemark = map[PurposeConst.SysRemark];
  }
  factory Purpose.fromJson(Map<String, dynamic> parsedJson) {
    return Purpose(
      EntNo: parsedJson['EntNo'],
      SysRemark: parsedJson['SysRemark'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    PurposeConst.EntNo: EntNo,
    PurposeConst.SysRemark: SysRemark,
  };
}

class PurposeConst {
  static const String EntNo = "EntNo";
  static const String SysRemark = "SysRemark";
}

class PurposeUrls {
  static const String GET_PURPOSE =
      "Attendance/GetPurpose";
}
