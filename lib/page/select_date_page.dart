import 'dart:convert';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action_message.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/list_filter_bar.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/menu_constants.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/branch.dart';
import 'package:digitalgeolocater/models/employee.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/models/visitReport.dart';
import 'package:digitalgeolocater/page/attendance_report_page.dart';
import 'package:digitalgeolocater/page/visit_report_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';


class SelectDatePage extends StatefulWidget {
  String MenuName;
  SelectDatePage({this.MenuName});

  @override
  _SelectDatePageState createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  bool isLoading;
  String loadingText,filter ,selectedReportType ="Details", selectedPurposeCat = "ALL" , SelectedAttendanceStatus="ALL",attendancecat;
  List<String> reportType = [
    'Details',
    'Summary',
  ];
  List<String> purposeCategory = [
    'ALL',
    'Official',
    'Private',
  ];
  List<String> attendanceStatus = [
    'ALL',
    'Absent',
    'Half Day',
    'Late Mark',
    'Present',
    'With Leave',
    'Without Leave',
  ];
  List<VisitReport> VisitReports = [];
  List<Employee> _employee = [];
  List<Employee> _filteredList = [];
  Employee selectedEmployee;
  Branch selectedbranch;
  final GlobalKey<ScaffoldState> _SelectDateKey = new GlobalKey<ScaffoldState>();
  TextEditingController filterController;
  List<Branch> branches = [];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      if (endDate.isBefore(startDate)) {
        UserMessageHandler.showMessage(
          _SelectDateKey,
          "Date not valid For Report",
          MessageTypes.warning,
        );
        setState(() {
          startDate = DateTime.now();
        });
      }
    }
  }
  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      if (endDate.isBefore(startDate)) {
        UserMessageHandler.showMessage(
          _SelectDateKey,
          "Date not valid For Report",
          MessageTypes.warning,
        );
        setState(() {
          endDate = DateTime.now();
        });
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    filterController = new TextEditingController();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });
    if( AppData.current.user.RoleNo == 1 || AppData.current.user.RoleNo == 3){
      String brcode ;
      fetchBranches().then((result) {
        setState(() {
          this.branches = result;
          if (branches != null && branches.length != 0 ) {
           // branches.insert(0, new Branch(BranchName: "ALL",brcode: "%",client_no: 0,ClientId: 0));
            if(AppData.current.user.RoleNo == 3){
              selectedbranch = null;
              brcode = AppData.current.user.Brcode;
            }else{
              selectedbranch = branches[0];
              brcode = selectedbranch.brcode;
            }

            fetchEmployee(brcode).then((result) {
              setState(() {
                _employee = result;
                if (_employee != null && _employee.length != 0 &&_employee.length > 1 ) {
                  _employee.insert(0, new Employee(UserNo: 0, UserName: "ALL"));
                  selectedEmployee = _employee[0];
                }else if(_employee != null && _employee.length != 0){
                  selectedEmployee = _employee[0];
                }
              });
            });
          }
        });
      });
    }
}

  @override
  Widget build(BuildContext context) {
    _filteredList = _employee.where((item) {
      if (filter == null || filter == '')
        return true;
      else {
        return item.UserName.toLowerCase().contains(filter.toLowerCase());
      }
    }).toList();

    loadingText = "Loding..";
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _SelectDateKey,
     //   resizeToAvoidBottomPadding: false,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: AppData. current.user != null?"Hi "+ AppData.current.user.UserName: '',
            subtitle: "Select Date for Report..",
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            getInputWidgets(context),
          ],
        )
      ),
    );
  }

  Widget getInputWidgets(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 10.0,
          right: 10.0,
          bottom: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[

                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).primaryColor,
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
                            "Start Date",
                            style:  Theme
                                .of(context)
                                .textTheme
                                .body2
                                .copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
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
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _selectStartDate(context);
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
                        color: Theme.of(context).primaryColor,
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
                            "End date",
                            style:  Theme
                                .of(context)
                                .textTheme
                                .body2
                                .copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
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
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _selectEndDate(context);
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
                  Visibility(
                    visible: AppData.current.user.RoleNo == 1,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  Visibility(
                    visible: AppData.current.user.RoleNo == 1,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 10.0,
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                          },
                          child:  Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Text(
                              "Select Branch",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .body2
                                  .copyWith(
                                  color: Colors.blue[800],
                                  fontSize: 15
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: AppData.current.user.RoleNo == 1,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if(branches==null){
                              UserMessageHandler.showMessage(
                                _SelectDateKey,
                                "Branches not available",
                                MessageTypes.warning,
                              );
                            }else{
                              showClientbranches();
                            }

                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child:  Text(
                                      selectedbranch != null? selectedbranch.BranchName:'',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.MenuName == MenuNameConst.AttendanceReport ,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0,
                           // bottom: 10.0
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showReportType();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor
                              ),
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Report Type",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                        color: Colors.grey[700],
                                        //fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    selectedReportType,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: widget.MenuName == MenuNameConst.VisitReport ,
                    child:   Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 0.0,
                          right: 0.0,
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showPurposeCategory();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Purpose Category",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                        color: Colors.grey[700],
                                        //fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    selectedPurposeCat,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.MenuName == MenuNameConst.VisitReport ,
                    child: SizedBox(
                    height: 10,
                  ),
                  ),
                  Visibility(
                    visible: AppData.current.user.RoleNo == 1 || AppData.current.user.RoleNo == 3,
                    child: Container(
                      padding: selectedReportType == "Details" ? const EdgeInsets.only(bottom: 3): const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (_employee == null) {
                            UserMessageHandler.showMessage(
                              _SelectDateKey,
                              "Employee Not Available.",
                              MessageTypes.warning,
                            );
                          } else {
                          //showEmployee();
                            filterController.text = '';
                            _settingModalBottomSheet(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "Select Employee",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(
                                      color: Colors.grey[700],
                                      //fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  selectedEmployee != null ? selectedEmployee
                                      .UserName : '',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(
                                    color: Colors.black45,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: selectedReportType == "Details" && widget.MenuName == MenuNameConst.AttendanceReport ,
                    child:   Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10.0,
                          right: 0.0,
                          top:5
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showAttendanceStatus();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Attendance Status",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                        color: Colors.grey[700],
                                        //fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    SelectedAttendanceStatus,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      String valMsg = getValidationMessage();
                      if (valMsg != '') {
                        UserMessageHandler.showMessage(
                          _SelectDateKey,
                          valMsg,
                          MessageTypes.warning,
                        );
                      } else {
                        if(SelectedAttendanceStatus =="ALL"){
                            attendancecat ="%";

                        }else if (SelectedAttendanceStatus =="Absent"){
                            attendancecat ="A";
                      }else if (SelectedAttendanceStatus =="Half Day"){
                            attendancecat ="HD";
                      }else if (SelectedAttendanceStatus =="Late Mark"){
                            attendancecat ="LM";
                      }else if (SelectedAttendanceStatus =="Present") {
                          attendancecat="P";
                        }else if (SelectedAttendanceStatus =="With Leave") {
                          attendancecat="LA";
                        }else if (SelectedAttendanceStatus =="Without Leave") {
                          attendancecat="NLP";
                        }

                        if (widget.MenuName == MenuNameConst.AttendanceReport){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendanceReportPage(startDate,endDate,selectedEmployee == null ? AppData.current.user.RefUserNo : selectedEmployee.UserName == "ALL"? 0 : selectedEmployee.RefUserNo,selectedbranch == null ? AppData.current.user.Brcode : selectedbranch.brcode, selectedReportType,attendancecat),
                            ),
                          );
                        }else if (widget.MenuName == MenuNameConst.VisitReport){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VisitReportPage(startDate,endDate,selectedEmployee == null ? AppData.current.user.UserNo : selectedEmployee.UserName == "ALL"? 0 : selectedEmployee.UserNo ,selectedbranch == null ? AppData.current.user.Brcode : selectedbranch.brcode,selectedPurposeCat),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      color: Colors.blue[100],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Text(
                            "Submit",
                            style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  String getValidationMessage() {
    if(AppData.current.user.RoleNo == 1){
      if (selectedbranch == null || selectedbranch =='')
        return "Please Select Branch";
    }

    if (AppData.current.user.RoleNo == 1 || AppData.current.user.RoleNo == 3){
      if (selectedEmployee == null || selectedEmployee =='')
        return "Please Select Employee";
    }
    return '';
  }
void showClientbranches() {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      message: CustomCupertinoActionMessage(
        message: "Select Branch Name",
      ),
      actions: List<Widget>.generate(
        branches.length,
            (i) => CustomCupertinoActionSheetAction(
          actionText: branches[i].BranchName,
          actionIndex: i,
          onActionPressed: () {
            setState(() {
              selectedbranch = branches[i];
              String brcode = selectedbranch.brcode;
              this.isLoading = true;
              fetchEmployee(brcode).then((result) {
                setState(() {
                  _employee = result;
                  if (_employee != null && _employee.length != 0 &&_employee.length > 1 ) {
                    _employee.insert(0, new Employee(UserNo: 0, UserName: "ALL"));
                    selectedEmployee = _employee[0];
                  }else if(_employee != null && _employee.length != 0) {
                    selectedEmployee = _employee[0];
                  }
                });
              });
            });
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}
  void showReportType() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Report Type",
        ),
        actions: List<Widget>.generate(
          reportType.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: reportType[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedReportType = reportType[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void showPurposeCategory() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Purpose Category",
        ),
        actions: List<Widget>.generate(
          purposeCategory.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: purposeCategory[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedPurposeCat = purposeCategory[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void showAttendanceStatus() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Attendance Status",
        ),
        actions: List<Widget>.generate(
          attendanceStatus.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: attendanceStatus[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                SelectedAttendanceStatus = attendanceStatus[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  Future<List<Employee>> fetchEmployee(String brcode) async {
    List<Employee> employee = [];

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
              EmployeeUrls.GET_EMPLOYEE_FOR_REPORT,
        ).replace(
          queryParameters: {
            "UserNo" : AppData.current.user.UserNo.toString(),
            "ClientId": AppData.current.user.ClientId.toString(),
            "Brcode": brcode,
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
            _SelectDateKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          employee = responseData
              .map(
                (item) => Employee.fromJson(item),
          )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _SelectDateKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _SelectDateKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      isLoading = false;
    });

    return employee;
  }
  void showEmployee() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) =>
          Wrap(
            children: <Widget>[
              CupertinoActionSheet(
                message: CustomCupertinoActionMessage(
                  message: "Select Employee",
                ),
                actions: List<Widget>.generate(
                  _employee == null ? 0 : _employee.length,
                      (index) =>
                          CustomCupertinoActionSheetAction(
                            actionText: _employee[index].UserName ?? "",
                            actionIndex: index,
                            onActionPressed: () {
                              setState(() {
                                selectedEmployee = _employee[index];
                              });
                              Navigator.pop(context);
                            },
                          )
                ),
              ),
            ],
          ),
    );
  }
  void _settingModalBottomSheet(context){
    showModalBottomSheet(
      backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
    topRight: Radius.circular(20.0),
    topLeft: Radius.circular(20.0),
    ),
    ),
        context: context,
        builder: (BuildContext bc){
          return Column(
            children: <Widget>[
              ListFilterBar(
                searchFieldController: filterController,
                onCloseButtonTap: () {
                  setState(() {
                    filterController.text = '';
                  });
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CupertinoActionSheet(
                    message: CustomCupertinoActionMessage(
                      message: "Select Employee",
                    ),
                    actions: List<Widget>.generate(
                        _filteredList == null ? 0 : _filteredList.length,
                            (index) =>
                            CustomCupertinoActionSheetAction(
                              actionText: _filteredList[index].UserName ?? "",
                              actionIndex: index,
                              onActionPressed: () {
                                setState(() {
                                  selectedEmployee = _filteredList[index];
                                });
                                Navigator.pop(context);
                              },
                            )
                    ),
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
  Future<List<Branch>> fetchBranches() async {
    List<Branch> branch;
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {

        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                BranchUrls.GET_BRANCH,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          selectedbranch = null;
          UserMessageHandler.showMessage(
            _SelectDateKey,
            response.body,
            MessageTypes.error,
          );
          branch = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            branch = responseData.map((item) => Branch.fromJson(item)).toList();
            AppData.current.client_No = branch[0].client_no;
            AppData.current.Domain = branch[0].Domain;
            int clientno = AppData.current.client_No;
          });
        }
      } else {
        UserMessageHandler.showMessage(
          _SelectDateKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        branch = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _SelectDateKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );

      branch = null;
    }
    setState(() {
      isLoading = false;
    });
    return branch;
  }

}
