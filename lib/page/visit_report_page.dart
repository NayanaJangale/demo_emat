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
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/models/visitReport.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class VisitReportPage extends StatefulWidget {
  DateTime startDate, endDate;
  int UserNo;
  String brcode ,purposeCategoty;
  VisitReportPage(this.startDate, this.endDate,this.UserNo,this.brcode,this.purposeCategoty);
  @override
  _VisitReportPageState createState() =>
      _VisitReportPageState();
}

class _VisitReportPageState
    extends State<VisitReportPage> {
  bool isLoading;
  String loadingText;
  List<VisitReport> VisitReports = [];
  final GlobalKey<ScaffoldState> _visitReportKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchStudentAttendaceReport().then((result) {
      setState(() {
        VisitReports = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = "Loding..";
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _visitReportKey,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: AppData. current.user != null?" Hi "+AppData.current.user.UserName: '',
            subtitle: "Let\' see your Visit Report..",
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchStudentAttendaceReport().then((result) {
              setState(() {
                VisitReports = result;
              });
            });
          },
          child:Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getDataBody(),
            ],
          )
        ),
      ),
    );
  }
  Widget getDataBody() {
    int count = 0;
    return VisitReports != null && VisitReports.length != 0
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
                    "Intime",
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
                    "Purpose Category",
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
                VisitReports.length,
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
                          VisitReports[index].EntDate!=null?DateFormat('dd-MMM-yyyy').format(VisitReports[index].EntDate):'',
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
                              VisitReports[index].EmpName),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          VisitReports[index].VI!=null?DateFormat('hh:mm aaa').format(VisitReports[index].VI):'-',
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
                          VisitReports[index].VO!=null?DateFormat('hh:mm aaa').format(VisitReports[index].VO):'-',
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
                          VisitReports[index].PurposeCat,
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
                          VisitReports[index].Place,
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
              description: "Visit Report Not available",
            );
          },
        ),
      ),
    );
  }

  Future<List<VisitReport>> fetchStudentAttendaceReport() async {
    List<VisitReport> attendace = [];

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
              VisitReportUrls.VISIT_REPORT,
        ).replace(
          queryParameters: {
            "sdt": formatter.format(widget.startDate),
            "edt": formatter.format(widget.endDate),
            "EType": "V",
            "UserNo" : widget.UserNo.toString(),
            "Brcode": widget.brcode,
            "ClientId":AppData.current.user.ClientId.toString(),
            "PurposeCat": widget.purposeCategoty =='ALL'?'%': widget.purposeCategoty,
            UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":AppData.current.user.RoleNo == 3 ?"Manager":"Employee",
            UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
            UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
            UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()
          },
        );
        http.Response response =
            await http.get(fetchStudentAttendanceReportUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _visitReportKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          attendace = responseData
              .map(
                (item) => VisitReport.fromJson(item),
              )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _visitReportKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _visitReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return attendace;
  }
}
