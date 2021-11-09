class LeavesSummary {
  String BranchName;
  String ApplicantName;
  int PendingApp;
  int TotalApp ;

  LeavesSummary({
    this.BranchName,
    this.ApplicantName,
    this.PendingApp,
    this.TotalApp
  });

  LeavesSummary.fromMap(Map<String, dynamic> map) {
    BranchName = map[LeavesSummaryConst.BranchName];
    ApplicantName = map[LeavesSummaryConst.ApplicantName];
    PendingApp = map[LeavesSummaryConst.PendingApp];
    TotalApp = map[LeavesSummaryConst.TotalApp];
  }
  factory LeavesSummary.fromJson(Map<String, dynamic> parsedJson) {
    return LeavesSummary(
      BranchName: parsedJson['BranchName'] ?? "",
      ApplicantName: parsedJson['ApplicantName'] ?? "",
      PendingApp: parsedJson['PendingApp'] ?? 0,
      TotalApp: parsedJson['TotalApp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    LeavesSummaryConst.BranchName: BranchName,
    LeavesSummaryConst.ApplicantName: ApplicantName,
    LeavesSummaryConst.PendingApp: PendingApp,
    LeavesSummaryConst.TotalApp: TotalApp,
      };
}

class LeavesSummaryConst {
  static const String BranchName = "BranchName";
  static const String ApplicantName = "ApplicantName";
  static const String PendingApp = "PendingApp";
  static const String TotalApp = "TotalApp";
}

class LeavesSummaryUrls {
  static const String LEAVE_SUMMARY ="Report/GetLeaveAppSummary";
}
