import 'dart:convert';

import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:digitalgeolocater/models/leave_summary.dart';
import 'package:digitalgeolocater/models/leavesApproval.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LeaveApplicationReportPage extends StatefulWidget {
  DateTime startDate, endDate;
  int userNo;
  String brcode, leaveType ,reportType;

  LeaveApplicationReportPage(
      this.startDate, this.endDate, this.brcode, this.leaveType, this.reportType,this.userNo);

  @override
  _LeaveApplicationReportPageState createState() =>
      _LeaveApplicationReportPageState();
}

class _LeaveApplicationReportPageState extends State<LeaveApplicationReportPage> {
  bool isLoading;
  String loadingText;
  List<LeaveApproval> leaveApproval = [];
  List<LeavesSummary> leaveSummary = [];
  final GlobalKey<ScaffoldState> _LeaveApplicationReportKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    if (widget.reportType =='Details'){
      fetchLeaveApplicationReport().then((result) {
        setState(() {
          leaveApproval = result;
        });
      });
    }else{
      fetchLeaveSummaryReport().then((result) {
        setState(() {
          leaveSummary = result;
        });
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    loadingText = "Loding..";
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _LeaveApplicationReportKey,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: AppData.current.user != null
                ? "Hi, " + AppData.current.user.UserName
                : '',
            subtitle: "Let\' see your Leave Application Report..",
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              if (widget.reportType =='Details'){
                fetchLeaveApplicationReport().then((result) {
                  setState(() {
                    leaveApproval = result;
                  });
                });
              }else{
                fetchLeaveSummaryReport().then((result) {
                  setState(() {
                    leaveSummary = result;
                  });
                });
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widget.reportType =='Details' ? getLeaveDetailReport() : getLeaveSummaryReport (),
              ],
            )),
      ),
    );
  }
  Widget getLeaveDetailReport() {
    int count = 0;
    return leaveApproval != null && leaveApproval.length != 0
        ? Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowHeight: 40,
                    columns: [
                      DataColumn(
                        label: Text(
                          "Sr.No",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Applicant Name",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Applied Duration (From - Upto)",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Assigned Duration (From - Upto)",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Applied On",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Leave Type",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Leave Category",
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Leave Reason",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Leave Status",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Approved By",
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    rows: new List<DataRow>.generate(
                      leaveApproval.length,
                      (int index) {
                        count++;
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                count.toString(),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    leaveApproval[index].ApplicantName),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    "${leaveApproval[index].FromDate != null ? DateFormat('dd MMM yy ').format(leaveApproval[index].FromDate) : ""} - ${leaveApproval[index].UptoDate != null ? DateFormat('dd MMM yy ').format(leaveApproval[index].UptoDate) : ""}"),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    "${leaveApproval[index].AssignFromDate != null ? DateFormat('dd MMM yy ').format(leaveApproval[index].AssignFromDate) : ""} - ${leaveApproval[index].AssignUptoDate != null ? DateFormat('dd MMM yy ').format(leaveApproval[index].AssignUptoDate) : ""}"),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                leaveApproval[index].EntDate != null
                                    ? DateFormat('dd MMM yy')
                                        .format(leaveApproval[index].EntDate)
                                    : "",
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            DataCell(
                              Text(
                                leaveApproval[index].Type.toString(),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            DataCell(
                              Text(
                                leaveApproval[index].LeaveCategory.toString(),
                                style:
                                Theme.of(context).textTheme.body2.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            DataCell(
                              Text(
                                leaveApproval[index].Reason.toString(),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            DataCell(
                              Text(
                                leaveApproval[index].LeaveStatus.toString(),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            DataCell(
                              Text(
                                leaveApproval[index].ApprovedBy.toString(),
                                style:
                                Theme.of(context).textTheme.body2.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        : Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return CustomDataNotFound(
                    description: "Leave Application Report Not available",
                  );
                },
              ),
            ),
          );
  }
  Widget getLeaveSummaryReport() {
    int count = 0;
    return leaveSummary != null && leaveSummary.length != 0
        ? Expanded(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowHeight: 40,
              columns: [
                DataColumn(
                  label: Text(
                    "Sr.No",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Applicant Name",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Branch Name",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Total Application",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Pending Application",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              ],
              rows: new List<DataRow>.generate(
                leaveSummary.length,
                    (int index) {
                  count++;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          count.toString(),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataCell(
                        Text(
                          StringHandlers.capitalizeWords(
                              leaveSummary[index].ApplicantName),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataCell(
                        Text(
                          StringHandlers.capitalizeWords(
                              leaveSummary[index].BranchName),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          leaveSummary[index].TotalApp.toString(),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          leaveSummary[index].PendingApp.toString(),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    )
        : Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return CustomDataNotFound(
              description: "Leave Application Report Not available",
            );
          },
        ),
      ),
    );
  }
  Future<List<LeaveApproval>> fetchLeaveApplicationReport() async {
    List<LeaveApproval> leaveApproval = [];

    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        var formatter = new DateFormat('yyyy-MM-dd');
        Uri fetchStudentAttendanceReportUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              LeaveApprovalUrls.GET_LEAVE_APPLICATION,
        ).replace(
          queryParameters: {
            "LStatus": widget.leaveType,
            "sdt": formatter.format(widget.startDate),
            "edt": formatter.format(widget.endDate),
            "UserNo": widget.userNo.toString(),
            "Brcode": widget.brcode,
            "ClientId": AppData.current.user.ClientId.toString(),
            UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":AppData.current.user.RoleNo == 3?"Manager":"Employee",
            UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
            UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
            UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()
          },
        );

        http.Response response =
            await http.get(fetchStudentAttendanceReportUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _LeaveApplicationReportKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          int cnt = 0;
          leaveApproval = responseData
              .map(
                (item) => LeaveApproval.fromJson(item),
              )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _LeaveApplicationReportKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _LeaveApplicationReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return leaveApproval;
  }
  Future<List<LeavesSummary>> fetchLeaveSummaryReport() async {
    List<LeavesSummary> leaveSummary = [];

    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        var formatter = new DateFormat('yyyy-MM-dd');
        Uri fetchStudentAttendanceReportUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              LeavesSummaryUrls.LEAVE_SUMMARY,
        ).replace(
          queryParameters: {
            "sdt": formatter.format(widget.startDate),
            "edt": formatter.format(widget.endDate),
            "UserNo": widget.userNo.toString(),
            "Brcode": widget.brcode,
            "ClientId": AppData.current.user.ClientId.toString(),
            UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":AppData.current.user.RoleNo == 3?"Manager":"Employee",
            UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
            UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
            UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()
          },
        );

        http.Response response =
        await http.get(fetchStudentAttendanceReportUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _LeaveApplicationReportKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          int cnt = 0;
          leaveSummary = responseData
              .map(
                (item) => LeavesSummary.fromJson(item),
          )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _LeaveApplicationReportKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _LeaveApplicationReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return leaveSummary;
  }
}
