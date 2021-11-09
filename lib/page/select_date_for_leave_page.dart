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
import 'package:digitalgeolocater/page/Leave_report_page.dart';
import 'package:digitalgeolocater/page/late_comers_report.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';


class SelectDateForLeavePage extends StatefulWidget {
  String MenuName;
  SelectDateForLeavePage({this.MenuName});

  @override
  _SelectDateForLeavePageState createState() => _SelectDateForLeavePageState();
}

class _SelectDateForLeavePageState extends State<SelectDateForLeavePage> {
  bool isLoading;
  String loadingText,filter ;
  Branch selectedbranch;
  final GlobalKey<ScaffoldState> _SelectForLeaveDateKey = new GlobalKey<ScaffoldState>();
  List<Branch> branches = [];
  List<String> reportType = [] ;
  TextEditingController filterController, timeController ;
  List<String> LeaveType = [
    'All',
    'Approve',
    'Not Approve',
  ];
  FocusNode timeNode;

  String selectedLeaveType = "All";
  String selectedReportType = "Details";

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2030, 8),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });

    }
  }
  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2030, 8),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });

    }
  }
  List<Employee> _employee = [];
  List<Employee> _filteredList = [];
  Employee selectedEmployee;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    reportType = [
      'Details',
      'Summary',
    ];
    timeController = TextEditingController();
    timeNode = FocusNode();
    String brcode;
    if( AppData.current.user.RoleNo == 1 || AppData.current.user.RoleNo==3){
      fetchBranches().then((result) {
        setState(() {
          this.branches = result;
          if (branches != null && branches.length != 0) {
            if(AppData.current.user.RoleNo == 3){
              selectedbranch = null;
              brcode = AppData.current.user.Brcode;
            }else{
              selectedbranch = branches[0];
              brcode = selectedbranch.brcode;
            }
          }
        });
      });
      filterController = new TextEditingController();
      filterController.addListener(() {
        setState(() {
          filter = filterController.text;
        });
      });
      if( AppData.current.user.RoleNo == 1 ||  AppData.current.user.RoleNo==3){
        String brcode;
        fetchBranches().then((result) {
          setState(() {
            this.branches = result;
            if (branches != null && branches.length != 0) {
            //  branches.insert(0, new Branch(BranchName: "ALL",brcode: "%",client_no: 0,ClientId: 0));
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
        key: _SelectForLeaveDateKey,
        //resizeToAvoidBottomPadding: false,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: AppData. current.user != null? "Hi "+ AppData.current.user.UserName: '',
            subtitle: "Select Date For Report..",
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getInputWidgets(context),
            ],
          ),
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
                    visible: AppData.current.user.RoleNo == 1 ,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  Visibility(
                    visible: AppData.current.user.RoleNo ==1 ,
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
                                _SelectForLeaveDateKey,
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
                                      selectedbranch!=null?selectedbranch.BranchName:'',
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
                    visible: widget.MenuName == MenuNameConst.LeaveReport,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0,
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
                  Visibility(
                    visible: selectedReportType == "Details" &&  widget.MenuName == MenuNameConst.LeaveReport ,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          bottom: 0.0
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showLeaveType();
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
                                      "Leave Type",
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
                                    selectedLeaveType,
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
                    visible: AppData.current.user.RoleNo == 1 ||AppData.current.user.RoleNo == 3,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  Visibility(
                    visible: AppData.current.user.RoleNo == 1 || AppData.current.user.RoleNo == 3,
                    child: Container(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (_employee == null) {
                            UserMessageHandler.showMessage(
                              _SelectForLeaveDateKey,
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
                  Visibility(
                    visible: widget.MenuName != MenuNameConst.LeaveReport,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: new TextField(
                         focusNode: timeNode,
                         controller: timeController,
                         decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          //icon: Icon(Icons.tit),
                          hintText: "Enter Time in Min. (e.g. 15)",
                          hintStyle:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.grey[700],
                          ),
                          labelStyle:
                          Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {

                      String valMsg = getValidationMessage();
                      if (valMsg != '') {
                        UserMessageHandler.showMessage(
                          _SelectForLeaveDateKey,
                          valMsg,
                          MessageTypes.warning,
                        );
                      } else {
                        String leaveType ="";
                        if(selectedLeaveType=="All"){
                          setState(() {
                            leaveType ="O";
                          });

                        }else if (selectedLeaveType== "Approve"){
                          setState(() {
                            leaveType ="A";
                          });

                        }else{
                          setState(() {
                            leaveType ="N";
                          });

                        }
                        if(widget.MenuName == MenuNameConst.LeaveReport){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LeaveApplicationReportPage(startDate,endDate,selectedbranch == null ? AppData.current.user.Brcode : selectedbranch.brcode,leaveType,selectedReportType,selectedEmployee == null ? AppData.current.user.UserNo : selectedEmployee.UserName == "ALL"? 0 : selectedEmployee.UserNo),
                            ),
                          );
                        }else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LateComersReportPage(startDate,endDate,selectedbranch == null ? AppData.current.user.Brcode : selectedbranch.brcode,timeController.text.toString(),selectedEmployee == null ? AppData.current.user.UserNo : selectedEmployee.UserName == "ALL"? 0 : selectedEmployee.UserNo,widget.MenuName),
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
    if (AppData.current.user.RoleNo == 1){
      if (selectedbranch == null || selectedbranch =='')
        return "Please Select Branch";
    }
    if(widget.MenuName != MenuNameConst.LeaveReport){
      if(timeController.text == ''){
        timeController.text="15";

      }
      if (timeController.text == 0 ) return "Please Enter Time .";
    }


    return '';
  }
  void showLeaveType() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Leave Type",
        ),
        actions: List<Widget>.generate(
          LeaveType.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: LeaveType[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedLeaveType = LeaveType[i];
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
            _SelectForLeaveDateKey,
            response.body,
            MessageTypes.error,
          );
          branch = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            branch = responseData.map((item) => Branch.fromJson(item)).toList();
            AppData.current.client_No = branch[0].client_no;
            int clientno = AppData.current.client_No;
          });
        }
      } else {
        UserMessageHandler.showMessage(
          _SelectForLeaveDateKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        branch = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _SelectForLeaveDateKey,
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
                fetchEmployee(selectedbranch.brcode).then((result) {
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
                //this.isLoading = true;
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
            _SelectForLeaveDateKey,
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
          _SelectForLeaveDateKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _SelectForLeaveDateKey,
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
}
