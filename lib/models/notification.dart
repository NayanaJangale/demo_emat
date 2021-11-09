class Notification {
  String Title;
  String Content;
  String UserNo;
  String BranchCode;
  String ClientCode;
  String NotificationFor;
  String Topic;
  DateTime NotificationDateTime;
  String isRead;

  Notification({
    this.Title,
    this.Content,
    this.UserNo,
    this.BranchCode,
    this.ClientCode,
    this.NotificationFor,
    this.Topic,
    this.NotificationDateTime,
  });

  Notification.fromMap(Map<String, dynamic> map) {
    NotificationDateTime = DateTime.parse(
        map[NotificationFieldNames.NotificationDateTime]);
    Title = map[NotificationFieldNames.Title];
    Content = map[NotificationFieldNames.Content];
    UserNo = map[NotificationFieldNames.UserNo];
    BranchCode = map[NotificationFieldNames.BranchCode];
    ClientCode = map[NotificationFieldNames.ClientCode];
    NotificationFor = map[NotificationFieldNames.NotificationFor];
    Topic = map[NotificationFieldNames.Topic];
    isRead = map[NotificationFieldNames.isRead];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    NotificationFieldNames.NotificationDateTime:
    NotificationDateTime == null
        ? null
        : NotificationDateTime.toIso8601String(),
    NotificationFieldNames.Title: Title,
    NotificationFieldNames.Content: Content,
    NotificationFieldNames.UserNo: UserNo,
    NotificationFieldNames.BranchCode: BranchCode,
    NotificationFieldNames.ClientCode: ClientCode,
    NotificationFieldNames.Topic: Topic,
    NotificationFieldNames.NotificationFor: NotificationFor,
    NotificationFieldNames.isRead: isRead,
  };
}

class NotificationFieldNames {
  static const String NotificationID = "NotificationID";
  static const String Title = "Title";
  static const String Body = "Body";
  static const String Topic = "Topic";
  static const String NotificationFor = "NotificationFor";
  static const String SectionID = "SectionID";
  static const String ClassID = "ClassID";
  static const String DivisionID = "DivisionID";
  static const String SenderID = "SenderID";
  static const String ClientCode = "ClientCode";
  static const String BranchCode = "BranchCode";
  static const String Content = "Content";
  static const String UserNo = "UserNo";
  static const String NotificationDateTime = "NotificationDateTime";
  static const String isRead = "isRead";

}

class NotificationUrls {
  static const String GET_SAVEUSERTOKEN = 'Users/SaveUserToken';
}
