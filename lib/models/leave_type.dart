class LeavesType {
  String Type;
  int Id;

  LeavesType({
    this.Type,
    this.Id,
  });

  LeavesType.fromMap(Map<String, dynamic> map) {
    Type = map[LeavesTypeConst.Type];
    Id = map[LeavesTypeConst.Id];
  }
  factory LeavesType.fromJson(Map<String, dynamic> parsedJson) {
    return LeavesType(
      Type: parsedJson['Type'],
      Id: parsedJson['Id'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        LeavesTypeConst.Type: Type,
        LeavesTypeConst.Id: Id,
      };
}

class LeavesTypeConst {
  static const String Type = "Type";
  static const String Id = "Id";
}

class LeaveTypeUrls {
  static const String GET_LEAVES_TYPE = "Leave/GetLeaveType";
  static const String POST_EMPLOYEE_LEAVES =
      "Leave/PostLeaveApplication";
}
