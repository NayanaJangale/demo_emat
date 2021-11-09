import 'dart:convert';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_leaves_application_item.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/overlay_for_select_page.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/employee_leaves.dart';
import 'package:digitalgeolocater/page/add_emplyee_leaves.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class EmployeeLeavesPage extends StatefulWidget {
  @override
  _EmployeeLeavesPageState createState() => _EmployeeLeavesPageState();
}

class _EmployeeLeavesPageState extends State<EmployeeLeavesPage> {
  bool isLoading;
  String loadingText;
  GlobalKey<ScaffoldState> _employeeLeavesPageGlobalKey;
  List<EmployeeLeave> _employeeLeaves = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _employeeLeavesPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchEmpAppliedLeaves().then((result) {
      setState(() {
        _employeeLeaves = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _employeeLeavesPageGlobalKey,
        appBar: NewGradientAppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEmployeeLeavesPage()),
                );
              },
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title:  "Leave Application",
            subtitle: "Let' see your applied Leaves",
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
                return CustomLeaveApplicationItem(
                  leave_type: _employeeLeaves[index].LeaveTypeName,
                  reason: _employeeLeaves[index].Reason,
                  leaveCategory: _employeeLeaves[index].LeaveCategory,
                  start_date: _employeeLeaves[index].FromDate != null
                      ? DateFormat('dd MMM yyyy')
                          .format(_employeeLeaves[index].FromDate)
                      : "",
                  end_date: _employeeLeaves[index].UptoDate != null
                      ? DateFormat('dd MMM yyyy')
                          .format(_employeeLeaves[index].UptoDate)
                      : "",
                  apply_date: _employeeLeaves[index].EntDateTime != null
                      ? DateFormat('dd MMM yyyy')
                          .format(_employeeLeaves[index].EntDateTime)
                      : "",
                  status: _employeeLeaves[index].LeaveStatus=='N'?
                  "Not Approved": _employeeLeaves[index].LeaveStatus=='A'? "Approved" : _employeeLeaves[index].LeaveStatus=='R'? "Rejected" :"Partial Approved",
                  assign_from_date:
                      _employeeLeaves[index].AssignFromDate != null
                          ? DateFormat('dd MMM yyyy')
                              .format(_employeeLeaves[index].AssignFromDate)
                          : "",
                  assign_to_date: _employeeLeaves[index].AssignUptoDate != null
                      ? DateFormat('dd MMM yyyy')
                          .format(_employeeLeaves[index].AssignUptoDate)
                      : "",
                );
              },
            )
          :Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return CustomDataNotFound(
                    description: "Applied Leaves Not Available.",
                  );
                },
              ),
            ),
    );
  }

  Future<List<EmployeeLeave>> fetchEmpAppliedLeaves() async {
    List<EmployeeLeave> employeeLeave = [];

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
                EmployeeLeaveUrls.GET_EMPLOYEE_LEAVES,
            params);

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _employeeLeavesPageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
          bool leaveOverlay = AppData.current.preferences.getBool('leave_overlay') ?? false;
          if (!leaveOverlay) {
            AppData.current
                .preferences
                .setBool("leave_overlay", true);
            _showOverlay(context);
          }
        } else {
          List responseData = json.decode(response.body);
          employeeLeave = responseData
              .map(
                (item) => EmployeeLeave.fromJson(item),
              )
              .toList();
          bool leaveOverlay = AppData.current.preferences.getBool('leave_overlay') ?? false;
          if (!leaveOverlay) {
            AppData.current
                .preferences
                .setBool("leave_overlay", true);
            _showOverlay(context);
          }

        }
      } else {
        UserMessageHandler.showMessage(
          _employeeLeavesPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _employeeLeavesPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return employeeLeave;
  }
  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          "Add New Leave from here."),
    );
  }
}
