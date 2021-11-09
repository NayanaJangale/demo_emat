
class TrackingStatus{
  int Status ;


  TrackingStatus({ this.Status});


  factory TrackingStatus.fromJson(Map<String, dynamic> parsedJson) {
    return TrackingStatus(
      Status: parsedJson[TrackingStatusConst.Status] ?? 0,
    );
  }



  Map<String, dynamic> toJson() => <String, dynamic>{
    TrackingStatusConst.Status: Status,
  };
}

class TrackingStatusConst {
  static const String Status = "Status";

  
}

