import 'dart:convert';

import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/menu_constants.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:digitalgeolocater/models/early_out.dart';
import 'package:digitalgeolocater/models/late_comers.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class LateComersReportPage extends StatefulWidget {
  DateTime startDate, endDate;
  String brcode ,time, menuName;
  int userNo;
  LateComersReportPage(this.startDate, this.endDate,this.brcode, this.time, this.userNo ,this.menuName);
  @override
  _LateComersReportPageState createState() =>
      _LateComersReportPageState();
}

class _LateComersReportPageState extends State<LateComersReportPage> {
  bool isLoading;
  String loadingText ,subtitle= "";
  List<LateComers> lateComers = [];
  List<EarlyOut> earlyOut = [];
  final GlobalKey<ScaffoldState> _lateComersReportKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    if (widget.menuName == MenuNameConst.LateComers){
      subtitle ='Let\' see Late Comers Report..';
      fetchLateComersReport().then((result) {
        setState(() {
          lateComers = result;
        });
      });
    }else{
      fetchEarlyOutReport().then((result) {
        subtitle ='Let\' see Early Out Report..';
        setState(() {
          earlyOut = result;
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
        key: _lateComersReportKey,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: AppData. current.user != null?" Hi "+AppData.current.user.UserName: '',
            subtitle: subtitle,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (widget.menuName == MenuNameConst.LateComers){
              fetchLateComersReport().then((result) {
                setState(() {
                  lateComers = result;
                });
              });
            }else{
              fetchEarlyOutReport().then((result) {
                setState(() {
                  earlyOut = result;
                });
              });
            }
          },
          child:Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.menuName == MenuNameConst.LateComers ? getLateComers() : getEarlyOut() ,
            ],
          )
        ),
      ),
    );
  }
  Widget getLateComers() {
    int count = 0;
    return lateComers != null && lateComers.length != 0
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
                    "Expected Time",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Late By Minutes",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "AStatus",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              rows: new List<DataRow>.generate(
                lateComers.length,
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
                          lateComers[index].EntDate!=null?DateFormat('dd-MMM-yyyy').format(lateComers[index].EntDate):'',
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
                              lateComers[index].UserName),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          lateComers[index].In_Time!=null? lateComers[index].In_Time :'-',
                          //lateComers[index].In_Time!=null? DateFormat('hh:mm aaa').format(lateComers[index].In_Time):'-',
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
                          lateComers[index].ExpectedTime!=null? lateComers[index].ExpectedTime :'-',
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
                          lateComers[index].LateByMinutes.toString(),
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
                          lateComers[index].AStatus,
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
              description: "Late Mark Report Not available",
            );
          },
        ),
      ),
    );
  }
  Widget getEarlyOut() {
    int count = 0;
    return earlyOut != null && earlyOut.length != 0
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
                    "Out time",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Expected Time",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Early By Minutes",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    "AStatus",
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              rows: new List<DataRow>.generate(
                earlyOut.length,
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
                          earlyOut[index].EntDate!=null?DateFormat('dd-MMM-yyyy').format(earlyOut[index].EntDate):'',
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
                              earlyOut[index].UserName),
                          style:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          earlyOut[index].Out_Time!=null? earlyOut[index].Out_Time :'-',
                         // earlyOut[index].Out_Time!=null? earlyOut[index].Out_Time :'-',
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
                          earlyOut[index].ExpectedTime!=null? earlyOut[index].ExpectedTime:'-',
                        //  earlyOut[index].ExpectedTime!=null? earlyOut[index].ExpectedTime:'-',
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
                          earlyOut[index].EarlyByMinutes.toString(),
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
                          earlyOut[index].AStatus,
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
              description: "Late Mark Report Not available",
            );
          },
        ),
      ),
    );
  }

  Future<List<LateComers>> fetchLateComersReport() async {
    List<LateComers> lateComers = [];

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
              LateComersUrls.GET_LATE_EMPLOYEE,
        ).replace(
          queryParameters: {
            "sdt": formatter.format(widget.startDate),
            "edt": formatter.format(widget.endDate),
            "LateByMin": widget.time.toString(),
            "UserNo" : widget.userNo.toString(),
            "Brcode": widget.brcode,
            "ClientId": AppData.current.user.ClientId.toString(),
            "ReportType": "Detail",
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
            _lateComersReportKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          lateComers = responseData
              .map(
                (item) => LateComers.fromJson(item),
              )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _lateComersReportKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _lateComersReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return lateComers;
  }
  Future<List<EarlyOut>> fetchEarlyOutReport() async {
    List<EarlyOut> earlyOut = [];

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
              LateComersUrls.GET_EARLY_OUT_EMPLOYEE,
        ).replace(
          queryParameters: {
            "sdt": formatter.format(widget.startDate),
            "edt": formatter.format(widget.endDate),
            "EarlyByMin": widget.time,
            "UserNo" : widget.userNo.toString(),
            "Brcode": widget.brcode,
            "ClientId": AppData.current.user.ClientId.toString(),
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
            _lateComersReportKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          earlyOut = responseData
              .map(
                (item) => EarlyOut.fromJson(item),
          )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _lateComersReportKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _lateComersReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return earlyOut;
  }
}
