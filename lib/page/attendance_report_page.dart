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
import 'package:digitalgeolocater/models/attendanceReport.dart';
import 'package:digitalgeolocater/models/attendanceSummary.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class AttendanceReportPage extends StatefulWidget {
  DateTime startDate, endDate;
  int UserNo;
  String brcode, reportType, AttendanceStatus;

  AttendanceReportPage(this.startDate, this.endDate, this.UserNo, this.brcode,
      this.reportType, this.AttendanceStatus);

  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  bool isLoading;
  String loadingText;
  List<AttendanceReport> attendanceReports = [];
  List<AttendanceSummary> summaryReports = [];
  final GlobalKey<ScaffoldState> _AttendanceReportKey =
      new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    if (widget.reportType == "Details") {
      fetchAttendaceReport().then((result) {
        setState(() {
          attendanceReports = result;
        });
      });
    } else {
      fetchAttendaceSummaryReport().then((result) {
        setState(() {
          summaryReports = result;
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
        key: _AttendanceReportKey,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: AppData.current.user != null
                ? " Hi, " + AppData.current.user.UserName
                : '',
            subtitle: "Let\' see your Attendance Report..",
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              if (widget.reportType == "Details") {
                fetchAttendaceReport().then((result) {
                  setState(() {
                    attendanceReports = result;
                  });
                });
              } else {
                fetchAttendaceSummaryReport().then((result) {
                  setState(() {
                    summaryReports = result;
                  });
                });
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widget.reportType == "Details"
                    ? getAtendanceDetailReport()
                    : getAtendanceSummaryReport(),
              ],
            )),
      ),
    );
  }

  Widget getAtendanceSummaryReport() {
    int count = 0;
    return summaryReports != null && summaryReports.length != 0
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
                          "UserName",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Total Days",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Holiday",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Present Count",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Late Mark Count",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Half Day Count",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Leave With App.",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Leave Without App.",
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Extra Count",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    rows: new List<DataRow>.generate(
                      summaryReports.length,
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
                                    summaryReports[index].UserName),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                summaryReports[index].TotalDays.toString(),
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
                                summaryReports[index].Holiday.toString(),
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
                                summaryReports[index].PresentCount.toString(),
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
                                summaryReports[index].LateMarkCount.toString(),
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
                                summaryReports[index].HalfDayCount.toString(),
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
                                summaryReports[index].LeaveCountWithAppn.toString(),
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
                                summaryReports[index].LeaveCountWithoutAppn.toString(),
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
                                summaryReports[index].ExtraCount.toString(),
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
                    description: "Attendance Report Not available",
                  );
                },
              ),
            ),
          );
  }

  Widget getAtendanceDetailReport() {
    int count = 0;
    return attendanceReports != null && attendanceReports.length != 0
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
                          "Entry Date",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Employee Name",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "In time",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Out Time",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Status",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Working Hours",
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Extra Hours",
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Leave Permission. Status",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Approval Status",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Address",
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    rows: new List<DataRow>.generate(
                      attendanceReports.length,
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
                                attendanceReports[index].EntDate != null
                                    ? DateFormat('dd-MMM-yyyy').format(
                                        attendanceReports[index].EntDate)
                                    : '',
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
                                    attendanceReports[index].UserName),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(attendanceReports[index].Ent_IN != null
                                ? Text(
                                    DateFormat('hh:mm aaa').format(
                                        attendanceReports[index].Ent_IN),
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    textAlign: TextAlign.center,
                                  )
                                : Center(
                                    child: Text(
                                      '-',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                            DataCell(
                              attendanceReports[index].Ent_Out != null
                                  ? Text(
                                      DateFormat('hh:mm aaa').format(
                                          attendanceReports[index].Ent_Out),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      textAlign: TextAlign.center,
                                    )
                                  : Center(
                                      child: Text(
                                        "-",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                            ),
                            DataCell(
                              Text(
                                attendanceReports[index].AtStatus,
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
                                attendanceReports[index].WorkingHrs,
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
                                attendanceReports[index].ExtraHrs,
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
                                attendanceReports[index].LeavePerStatus,
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
                                attendanceReports[index].PassStatus,
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
                                attendanceReports[index].Place,
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
                    description: "Attendance Report Not available",
                  );
                },
              ),
            ),
          );
  }

  Future<List<AttendanceReport>> fetchAttendaceReport() async {
    List<AttendanceReport> attendace = [];
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
              AttendanceReportUrls.ATTENDANCE_REPORT,
        ).replace(
          queryParameters: {
            "Client_No": AppData.current.client_No.toString(),
            "sdt": formatter.format(widget.startDate),
            "edt": formatter.format(widget.endDate),
            UserFieldNames.UserNo:  AppData.current.user.UserNo.toString(),
            UserFieldNames.RefUserNo : widget.UserNo.toString(),
            "Brcode": widget.brcode,
            "AtStatus": widget.AttendanceStatus,
            "Domain": AppData.current.Domain.toString(),
            "ClientId": AppData.current.user.ClientId.toString(),
            UserFieldNames.userType: AppData.current.user == null
                ? ""
                : AppData.current.user.RoleNo == 1
                    ? "Admin"
                    : AppData.current.user.RoleNo == 3?"Manager":"Employee",
            UserFieldNames.macAddress: AppData.current.deviceId == null
                ? ""
                : AppData.current.deviceId.toString(),
            UserFieldNames.SessionUserNo: AppData.current.user == null
                ? ""
                : AppData.current.user.UserNo.toString(),
            UserFieldNames.UserID: AppData.current.user == null
                ? ""
                : AppData.current.user.UserID.toString()
          },
        );
        http.Response response =
            await http.get(fetchStudentAttendanceReportUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _AttendanceReportKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          int cnt = 0;
          attendace = responseData
              .map(
                (item) => AttendanceReport.fromJson(item),
              )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _AttendanceReportKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _AttendanceReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return attendace;
  }
  Future<List<AttendanceSummary>> fetchAttendaceSummaryReport() async {
    List<AttendanceSummary> attendacesummary = [];

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
              AttendanceSummaryUrls.ATTENDANCE_REPORT,
        ).replace(
          queryParameters: {
            "Client_No": AppData.current.client_No.toString(),
            "sdt": formatter.format(widget.startDate),
            "edt": formatter.format(widget.endDate),
             UserFieldNames.UserNo:  AppData.current.user.UserNo.toString(),
             UserFieldNames.RefUserNo : widget.UserNo.toString(),
            "Brcode": widget.brcode,
            "ClientId": AppData.current.user.ClientId.toString(),
            "Domain": AppData.current.Domain.toString(),
            UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":"Employee",
            UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
            UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
            UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()
          },
        );

        http.Response response =
            await http.get(fetchStudentAttendanceReportUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _AttendanceReportKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          int cnt = 0;
          attendacesummary = responseData
              .map(
                (item) => AttendanceSummary.fromJson(item),
              )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _AttendanceReportKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _AttendanceReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return attendacesummary;
  }
}
