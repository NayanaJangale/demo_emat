import 'dart:convert';
import 'package:digitalgeolocater/components/custom_alert_dialog.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:digitalgeolocater/models/leavesApproval.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class LeaveApprovalPage extends StatefulWidget {
  @override
  _LeaveApprovalPageState createState() => _LeaveApprovalPageState();
}

class _LeaveApprovalPageState extends State<LeaveApprovalPage> {
  bool isLoading,isDate ;
  String loadingText;
  GlobalKey<ScaffoldState> _LeavesApprovalPageGlobalKey;
  List<LeaveApproval> _employeeLeaves = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _LeavesApprovalPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.isDate = true;
    this.loadingText = 'Loading . . .';

    fetchEmpAppliedLeaves().then((result) {
      setState(() {
        _employeeLeaves = result;
      });
    });
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: this.endDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2025, 8),
    );
    if (picked != null && picked != endDate) {
      if (endDate.isBefore(startDate)) {
        UserMessageHandler.showMessage(
          _LeavesApprovalPageGlobalKey,
          "Date not valid For Leave.",
          MessageTypes.warning,
        );
        setState(() {
          startDate = DateTime.now();
        });
      }
      setState(() {
        isDate = false;
        endDate = picked;
      });

    }
  }
  Future<Null> _selectstartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: this.startDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2025, 8),
    );
    if (picked != null && picked != startDate) {
      if (endDate.isBefore(startDate)) {
        UserMessageHandler.showMessage(
          _LeavesApprovalPageGlobalKey,
          "Date not valid For Leave Approval.",
          MessageTypes.warning,
        );
        setState(() {
          startDate = DateTime.now();
        });
      }
      setState(() {
        isDate = false;
        startDate = picked;
      });

    }
  }
  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _LeavesApprovalPageGlobalKey,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title:  "Pending Leave Approval",
            subtitle: "Let' see your pending Leave Approval.",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(3.0),
          child: getEmployeeAppliedLeaves(),
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget getEmployeeAppliedLeaves() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchEmpAppliedLeaves().then((result) {
          setState(() {
            _employeeLeaves = result;
          });
        });
      },
      child: _employeeLeaves != null && _employeeLeaves.length != 0
          ? ListView.builder(
        itemCount: _employeeLeaves.length,
        itemBuilder: (BuildContext context, int index) {
          if (isDate == true){
            startDate =  _employeeLeaves[index].FromDate;
            endDate =_employeeLeaves[index].UptoDate;
          }else{

          }
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                topLeft: Radius.circular(3.0),
                bottomRight: Radius.circular(3.0),
                bottomLeft: Radius.circular(3.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Table(
                    columnWidths: {
                      0: FractionColumnWidth(.4),
                    },
                    children: [
                      TableRow(
                        children: [
                          Container(),
                          Container(),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Text(
                              "Leave Type",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Text(
                              StringHandlers.capitalizeWords(_employeeLeaves[index].Type),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              "Applied Duration",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              StringHandlers.capitalizeWords(
                                  "${_employeeLeaves[index].FromDate != null
                                      ? DateFormat('dd MMM yy ')
                                      .format(_employeeLeaves[index].FromDate)
                                      : ""} - ${_employeeLeaves[index].UptoDate != null
                                      ? DateFormat('dd MMM yy ')
                                      .format(_employeeLeaves[index].UptoDate)
                                      : ""}"),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              "Applied On",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              _employeeLeaves[index].EntDate != null
                                  ? DateFormat('dd MMM yy')
                                  .format(_employeeLeaves[index].EntDate)
                                  : "",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              "Applicant Name",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              StringHandlers.capitalizeWords(
                                  _employeeLeaves[index].ApplicantName),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        ],
                      ),
                      TableRow(

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              "Leave Category",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              StringHandlers.capitalizeWords(
                                  _employeeLeaves[index].LeaveCategory),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              "Pre. Approved By",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              StringHandlers.capitalizeWords(
                                  _employeeLeaves[index].ApprovedBy) ,
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              "Pre. Assign From Date",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                                _employeeLeaves[index].AssignFromDate!=null?
                              DateFormat('dd-MMM-yyyy').format( _employeeLeaves[index].AssignFromDate):"N/a",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                              "Pre. Assign Upto Date",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            child: Text(
                                _employeeLeaves[index].AssignUptoDate!=null?
                              DateFormat('dd-MMM-yyyy').format( _employeeLeaves[index].AssignUptoDate) :"N/a",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.lightBlue[100],
                            ),
                          ),
                        ),
                        children: [

                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 10.0,
                            ),
                            child: Text(
                              "Status",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 10.0,
                            ),
                            child: Text(
                              _employeeLeaves[index].LeaveStatus=='N'?
                              "Not Approved": _employeeLeaves[index].LeaveStatus=='A'? "Approved" : _employeeLeaves[index].LeaveStatus=='R'? "Rejected" :"Partial Approved",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                color: _employeeLeaves[index].LeaveStatus=='A'? Colors.green[800] : _employeeLeaves[index].LeaveStatus=='R'? Colors.red[800]:Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey[200],
                      ),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Assign From Date ",
                            style:  Theme
                                .of(context)
                                .textTheme
                                .body2
                                .copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Center(
                                child: Text(
                                  DateFormat('dd-MMM-yyyy').format(startDate),
                                  style:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .body2
                                      .copyWith(
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                _selectstartDate(this.context);

                              },
                              child: Icon(
                                Icons.date_range,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey[200],
                      ),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Assign Upto Date ",
                            style:  Theme
                                .of(context)
                                .textTheme
                                .body2
                                .copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Center(
                                child: Text(
                                  DateFormat('dd-MMM-yyyy').format(endDate),
                                  style:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .body2
                                      .copyWith(
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                _selectEndDate(this.context);
                              },
                              child: Icon(
                                Icons.date_range,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //crossAxisAlignment: CrossAxisAlignment.,
                      children: <Widget>[
                        Expanded(child:
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){
                            _ApproveEmployeeLeave(_employeeLeaves[index].AppId,"A");
                          },
                          child: Container(
                            color: Colors.blue[100],
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Approved",
                                  style: Theme.of(context).textTheme.body1.copyWith(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              _RejectEmployeeLeave(_employeeLeaves[index].AppId,"R");
                            },
                            child: Container(
                              color: Colors.blue[100],
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    "Reject",
                                    style: Theme.of(context).textTheme.body1.copyWith(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      )
          : Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return CustomDataNotFound(
              description: "No Leave Available for Approval.",
            );
          },
        ),
      ),
    );
  }
  void _RejectEmployeeLeave(int application_no,String status) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: "Yes",
        onActionTapped: () {
          Navigator.pop(context);
          UpdateEmployeeLeave(application_no ,status);
        },
        actionColor: Colors.red,
        message: "Do you really want to Reject this leave ?",
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  void _ApproveEmployeeLeave(int application_no,String status) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: "Yes",
        onActionTapped: () {
          Navigator.pop(context);
          UpdateEmployeeLeave(application_no ,status);
        },
        actionColor: Colors.red,
        message: "Do you really want to Approve this leave ?",
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  Future<void> UpdateEmployeeLeave(int application_no , String status) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing . .';
      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        var formatter = new DateFormat('yyyy-MM-dd');
        Uri postLeaveApprovalUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              LeaveApprovalUrls.APPROVED_PENDING_LEAVES,
          {
            LeaveApprovalFieldNames.AppId: application_no.toString(),
            LeaveApprovalFieldNames.AssignFromDate: formatter.format(startDate),
            LeaveApprovalFieldNames.AssignUptoDate:formatter.format(endDate),
            LeaveApprovalFieldNames.LeaveStatus: status,

          },
        );
        http.Response response = await http.post(postLeaveApprovalUri);
        setState(() {
          isLoading = false;
          loadingText = 'Saving..';
        });

        if (response.statusCode == HttpStatusCodes.CREATED) {
          //TODO: Call login
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                response.body,
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(
                      "Ok",
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                      // It worked for me instead of above line
                      fetchEmpAppliedLeaves().then((result) {
                        setState(() {
                          _employeeLeaves = result;
                        });
                      });
                    })
              ],
            ),
          );
        } else {
          UserMessageHandler.showMessage(
            _LeavesApprovalPageGlobalKey,
            response.body,
            MessageTypes.error,
          );
        }
      } else {
        UserMessageHandler.showMessage(
          _LeavesApprovalPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _LeavesApprovalPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }
  Future<List<LeaveApproval>> fetchEmpAppliedLeaves() async {
    List<LeaveApproval> employeeLeave = [];
    try {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> params = {
        // "user_id": user != null ? user.user_id : "",

      };

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                LeaveApprovalUrls.GET_PENDING_LEAVES,
            params);

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _LeavesApprovalPageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
        } else {
          List responseData = json.decode(response.body);
          employeeLeave = responseData
              .map(
                (item) => LeaveApproval.fromJson(item),
          )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _LeavesApprovalPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _LeavesApprovalPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return employeeLeave;
  }
}
