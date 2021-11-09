class Employee {
  int UserNo;
  int RefUserNo;
  String UserName;


  Employee({
    this.UserNo,
    this.RefUserNo,
    this.UserName,
  
  });

  Employee.fromMap(Map<String, dynamic> map) {
    UserNo = map[EmployeeConst.UserNo];
    RefUserNo = map[EmployeeConst.RefUserNo];
    UserName = map[EmployeeConst.UserName];
  }
  factory Employee.fromJson(Map<String, dynamic> parsedJson) {
    return Employee(
      UserNo: parsedJson['UserNo'],
      RefUserNo: parsedJson['RefUserNo'],
      UserName: parsedJson['UserName'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    EmployeeConst.UserNo: UserNo,
    EmployeeConst.RefUserNo: RefUserNo,
    EmployeeConst.UserName: UserName,
  };
}

class EmployeeConst {
  static const String UserNo = "UserNo";
  static const String RefUserNo = "RefUserNo";
  static const String UserName = "UserName";
}

class EmployeeUrls {
  //static const String GET_EMPLOYEE ="Users/GetEmpList";
  static const String GET_EMPLOYEE_FOR_REPORT ="Users/GetEmpListForReport";
}
