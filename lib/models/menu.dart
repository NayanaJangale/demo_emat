import 'package:digitalgeolocater/handlers/string_handlers.dart';

class Menu {
  int Id;
  String MenuName;
  int UserNo;
  int ParentId;

  Menu({
    this.Id,
    this.MenuName,
    this.ParentId

  });
  Menu.fromMap(Map<String, dynamic> map) {
    Id = map[MenuFieldNames.Id] ?? 0;
    MenuName = map[MenuFieldNames.MenuName]?? StringHandlers.NotAvailable;
    ParentId = map[MenuFieldNames.ParentId]?? 0;
  }
  factory Menu.fromJson(Map<String, dynamic> parsedJson) {
    return Menu(
      Id: parsedJson['Id'],
      MenuName: parsedJson['MenuName'],
      ParentId: parsedJson['ParentId'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    MenuFieldNames.Id: Id,
    MenuFieldNames.MenuName: MenuName,
    MenuFieldNames.UserNo: UserNo,
    MenuFieldNames.ParentId: ParentId,
  };
}

class MenuFieldNames {
  static const String Id = "Id";
  static const String MenuName = "MenuName";
  static const String UserNo = "UserNo";
  static const String ParentId = "ParentId";
}

class MenuUrls {
  static const String GET_MENU = "Users/GetRolewiseMenus";
}
