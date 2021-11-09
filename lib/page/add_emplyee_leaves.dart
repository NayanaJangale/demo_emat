import 'dart:convert';
import 'dart:io';

import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action_message.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/calender.dart';
import 'package:digitalgeolocater/models/employee_leaves.dart';
import 'package:digitalgeolocater/models/leave_type.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/date_picker_page.dart';
import 'package:digitalgeolocater/page/employee_leaves_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddEmployeeLeavesPage extends StatefulWidget {
  @override
  _AddEmployeeLeavesPage createState() => _AddEmployeeLeavesPage();
}

class _AddEmployeeLeavesPage extends State<AddEmployeeLeavesPage> {
  List<LeavesType> leavetype = [];
  List<Calender> calender = [];
  GlobalKey<ScaffoldState> _addLeavesPageGlobalKey;
  bool isLoading;
  String loadingText;
  FocusNode remarkFocusNode;
  TextEditingController remarkController;
  File imgFile;
  String subtitle,strSelectedUpto,strSelectedFrom;
  LeavesType selectedLeaves;
  DateTime selectedTodayDate = DateTime.now();
  String _leavetype = '', selectedLeaveCategory = 'Full Day';
  double cHeight;
  List<String> leaveCategory = [
    'Full Day',
    'Half Day',
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    strSelectedUpto =  DateFormat('yyyy-MM-dd').format(DateTime.now());
    strSelectedFrom= DateFormat('yyyy-MM-dd').format(DateTime.now());
    fetchLeaveType().then((result) {
      setState(() {
        this.leavetype = result;
        if (leavetype != null && leavetype.length != 0) {
          selectedLeaves = leavetype[0];
        }
      });
    });
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _addLeavesPageGlobalKey = GlobalKey<ScaffoldState>();
    remarkFocusNode = FocusNode();
    remarkController = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    cHeight = MediaQuery.of(context).size.height;
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          key: _addLeavesPageGlobalKey,
          appBar: NewGradientAppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            gradient: LinearGradient(
                colors: [Colors.green[500], Colors.lightBlueAccent]),
            title: CustomAppBar(
              title: "Add Leave Application",
              subtitle: "Let\' apply for Leave..",
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            left: 10.0,
                            right: 10.0,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (leavetype == null) {
                                UserMessageHandler.showMessage(
                                  _addLeavesPageGlobalKey,
                                  "Leave Type Not Available.",
                                  MessageTypes.warning,
                                );
                              } else {
                                showLeavesTypes();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.0,
                                  color: Colors.lightBlue[100],
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
                                        "Select Leave Type",
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
                                      selectedLeaves != null ? selectedLeaves
                                          .Type : '',
                                      // selectedLeaves!=null ? selectedLeaves.l_desc : '',
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
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          top: 10.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Colors.lightBlue[100],
                            ),
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Leave from",
                                  style:
                                  Theme
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
                                    child: Center(
                                      child: Text(
                                        strSelectedFrom,
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                          color: Colors.black45,
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
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        // Create the SelectionScreen in the next step.
                                        MaterialPageRoute(builder: (context) => DatePickerPage()),
                                      );
                                      setState(() {
                                        strSelectedFrom =result;
                                      });

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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          top: 10.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Colors.lightBlue[100],
                            ),
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Leave Upto",
                                  style:
                                  Theme
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
                                    child: Center(
                                      child: Text(strSelectedUpto
                                       /* DateFormat('dd-MMM-yyyy')
                                            .format(selectedUpto)*/,
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                          color: Colors.black45,
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
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        // Create the SelectionScreen in the next step.
                                        MaterialPageRoute(builder: (context) => DatePickerPage()),
                                      );
                                      setState(() {
                                        strSelectedUpto = result;
                                      });
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
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                      ),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                showLeaveCategory();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.0,
                                      color: Colors.lightBlue[100]
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
                                          "Leave Category",
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
                                        selectedLeaveCategory,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new TextField(
                          focusNode: remarkFocusNode,
                          controller: remarkController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Remark or Reson",
                            hintStyle: Theme
                                .of(context)
                                .textTheme
                                .body2
                                .copyWith(
                              color: Colors.grey[700],
                            ),
                            labelStyle:
                            Theme
                                .of(context)
                                .textTheme
                                .body2
                                .copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  String valMsg = getValidationMessage();
                  if (valMsg != '') {
                    UserMessageHandler.showMessage(
                      _addLeavesPageGlobalKey,
                      valMsg,
                      MessageTypes.warning,
                    );
                  } else {
                    postEmployeeLeaves();
                  }
                },
                child: Container(
                  color: Colors.blue[100],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        "POST LEAVE",
                        style: Theme
                            .of(context)
                            .textTheme
                            .body1
                            .copyWith(
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
      ),
    );
  }
  void showLeavesTypes() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) =>
          CupertinoActionSheet(
            message: CustomCupertinoActionMessage(
              message: "Select Leave Type",
            ),
            actions: List<Widget>.generate(
              leavetype == null ? 0 : leavetype.length,
              //leavetype.length ,
                  (index) =>
                  CustomCupertinoActionSheetAction(
                    actionText: leavetype[index].Type ?? "",
                    actionIndex: index,
                    onActionPressed: () {
                      setState(() {
                        selectedLeaves = leavetype[index];
                        _leavetype = selectedLeaves.Type;
                      });
                      Navigator.pop(context);
                    },
                  ),
            ),
          ),
    );
  }
  String getValidationMessage() {
    if (remarkController.text == '') return "Remark is mandatory";

    if (selectedLeaves == null) {
      return "Select Leave Type";
    }
    if (DateTime.parse(strSelectedUpto).isBefore(DateTime.parse(strSelectedFrom))) {
      return "Date not valid For Leave.";
    }

    return '';
  }
  Future<List<LeavesType>> fetchLeaveType() async {
    List<LeavesType> leavetype;
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
                LeaveTypeUrls.GET_LEAVES_TYPE,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _addLeavesPageGlobalKey,
            response.body,
            MessageTypes.error,
          );

          leavetype = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            leavetype =
                responseData.map((item) => LeavesType.fromJson(item)).toList();
          });
        }
      } else {
        UserMessageHandler.showMessage(
          _addLeavesPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        leavetype = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _addLeavesPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );

      leavetype = null;
    }
    setState(() {
      isLoading = false;
    });
    return leavetype;
  }
  Future<void> postEmployeeLeaves() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Saving . . .';
      });

      EmployeeLeave empLeave = EmployeeLeave(
        LeaveType: selectedLeaves.Id,
        FromDate: DateTime.parse(strSelectedFrom) ,
        UptoDate: DateTime.parse(strSelectedUpto),
        LeaveStatus: "N",
        Reason: remarkController.text.toString(),
        UserID: AppData.current.user.UserID,
        EntDateTime:selectedTodayDate,
        UserNo: AppData.current.user.UserNo ,
        Brcode: AppData.current.user.Brcode ,
        ClientId: AppData.current.user.ClientId,
        LeaveCat: selectedLeaveCategory == 'Full Day' ? 1 : 2,
      );

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.current.user;

        Map<String, dynamic> params = {
        };
        Uri saveemployeeleaveUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                LeaveTypeUrls.POST_EMPLOYEE_LEAVES,
            params);
        String jsonBody = json.encode(empLeave);

        http.Response response = await http.post(
          saveemployeeleaveUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          UserMessageHandler.showMessage(
            _addLeavesPageGlobalKey,
            response.body.toString(),
            MessageTypes.information,
          );
          _clearData();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeLeavesPage(),
              // builder: (_) => SubjectsPage(),
            ),
          );
        } else {
          UserMessageHandler.showMessage(
            _addLeavesPageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );

        }
      } else {
        UserMessageHandler.showMessage(
          _addLeavesPageGlobalKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _addLeavesPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      isLoading = false;
      loadingText = 'Loading..';
    });
  }
  void _clearData() {
    remarkController.text = '';
  }
  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EmployeeLeavesPage()),
    );
  }
  void showLeaveCategory() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Select Category",
        ),
        actions: List<Widget>.generate(
          leaveCategory.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: leaveCategory[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedLeaveCategory = leaveCategory[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
