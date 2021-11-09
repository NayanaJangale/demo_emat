import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:io' as Io;
import 'package:device_info/device_info.dart';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/bottomNavigation.dart';
import 'package:digitalgeolocater/components/custom_alert_dialog.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action_message.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_request_methods.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/handlers/notification_handler.dart';
import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:digitalgeolocater/models/attendance.dart';
import 'package:digitalgeolocater/models/attendanceReport.dart';
import 'package:digitalgeolocater/models/attendanceSummary.dart';
import 'package:digitalgeolocater/models/branch.dart';
import 'package:digitalgeolocater/models/configration.dart';
import 'package:digitalgeolocater/models/dashboardSummary.dart';
import 'package:digitalgeolocater/models/menu.dart';
import 'package:digitalgeolocater/models/notification.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/models/visit_count.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

enum LegendShape { Circle, Rectangle }

class _DashboardState extends State<DashboardPage> {
  double _height, _width, _pixelRatio;
  bool _large, _medium;
  List<Menu> menus = [];
  bool isLoading = false;
  String loadingText = 'Loading..';
  String smsAutoId;
  Random random = new Random();
  List<Configuration> _Config = [];
  StreamSubscription _subscription;
  List<Attendance> _attendance = [];
  List<AttendanceReport> employee = [];
  List<AttendanceReport> attendancePresent = [];
  List<AttendanceReport> attendanceAbsent = [];
  List<AttendanceReport> attendanceLateMark = [];
  List<Branch> branches = [];
  File imgFile;
  Branch selectedbranch;
  String deviceId = "";
  List<AttendanceSummary> summaryReports = [];
  List<DashboardSummary> dashboradSummary = [];
  List<VisitCount> totalVisit = [];
  DateTime today, yesterday, onemonthAgo;

  Map<String, double> dataMap = {
    "Present": 0,
    "Leave With App.": 0,
    "Leave Without App": 0,
    "Late Mark": 0,
    "Half Day": 0,
  };
  Map<String, double> dataMapadmin = {
    // "Total Employee": 0,
    "Present": 0,
    "Absent/Leave": 0,
    "Late Mark": 0,
  };

  List menuColors = [
    Colors.brown[800],
    Colors.deepPurple[800],
    Colors.orange[800],
    Colors.lightBlue[800],
    Colors.amber[800],
    Colors.grey[800],
    Colors.lime[800],
    Colors.lightGreen[800],
    Colors.red[800],
    Colors.green[800],
    Colors.yellow[800],
    Colors.teal[800],
    Colors.deepOrange[800],
    Colors.cyan[800],
    Colors.blue[800],
    Colors.indigo[800],
    Colors.purple[800],
    Colors.pink[800],
    Colors.blueGrey[800],
  ];
  final GlobalKey<ScaffoldState> _scaffoldDashbordKey =
      new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    fetchAttendanceRecord();
    today = new DateTime.now();
    yesterday = today.subtract(new Duration(days: 1));
    onemonthAgo = today.subtract(new Duration(days: 30));
    _getId().then((res) {
      setState(() {
        deviceId = res;
        AppData.current.deviceId = deviceId;
      });
    });
    initNotifications();
    fetchBranches().then((result) {
      branches = result;
      if (AppData.current.user.RoleNo == 1 || AppData.current.user.RoleNo == 3) {
        fetchDashboardAttendance(AppData.current.user.Brcode).then((result) {
          setState(() {
            dashboradSummary = result;
            if (dashboradSummary.length > 0) {
              dataMapadmin = {
                //  "Total Employee": double.parse(dashboradSummary[0].TotalEmp.toString()),
                "Present":
                    double.parse(dashboradSummary[0].PresentCount.toString()),
                "Absent/Leave":
                    double.parse(dashboradSummary[0].AbsentCount.toString()),
                "Late Mark":
                    double.parse(dashboradSummary[0].LateCount.toString()),
              };
            }
          });
        });
        fetchDashboardDetailReport("%").then((result) {
          setState(() {
            employee = result;
          });
        });
        fetchDashboardDetailReport("P").then((result) {
          setState(() {
            attendancePresent = result;
          });
        });
        fetchDashboardDetailReport("A").then((result) {
          setState(() {
            attendanceAbsent = result;
          });
        });
        fetchDashboardDetailReport("LM").then((result) {
          setState(() {
            attendanceLateMark = result;
          });
        });
      } else {
        fetchVisitCount(AppData.current.user.Brcode).then((result) {
          setState(() {
            totalVisit = result;
          });
        });
        fetchAttendaceSummaryReport().then((result) {
          setState(() {
            summaryReports = result;
            if (summaryReports.length > 0) {
              dataMap = {
                "Present":
                    double.parse(summaryReports[0].PresentCount.toString()),
                "Leave With App. ":
                    double.parse(summaryReports[0].LeaveCountWithAppn.toString()),
                "Leave Without App":
                double.parse(summaryReports[0].LeaveCountWithoutAppn.toString()),
                "Late Mark":
                    double.parse(summaryReports[0].LateMarkCount.toString()),
                "Half Day":
                    double.parse(summaryReports[0].HalfDayCount.toString()),
              };
            }
          });
        });
      }
    });
  }
  initNotifications() async {
    try {
      NotificationHandler.subscribeTopics(FirebaseMessaging.instance);

      NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
        announcement: true,
        carPlay: true,
        criticalAlert: true,
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.instance.getToken().then((token) {
        print(token);
        saveUserToken(token);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        NotificationHandler.processMessage(message.data);
      });
    } catch (e) {
      print(e);
    }
  }


  List<Color> colorList = [
    Colors.green,
    Colors.red,
    Colors.cyan,
    Colors.blue,
    Colors.yellow,
  ];
  List<Color> colorListAdmin = [
    //  Colors.blue,
    Colors.green,
    Colors.red,
    Colors.yellow,
  ];
  ChartType _chartType = ChartType.ring;
  bool _showCenterText = false;
  double _ringStrokeWidth = 25;
  double _chartLegendSpacing = 32;
  bool _showLegendsInRow = false;
  bool _showLegends = true;

  bool _showChartValueBackground = true;
  bool _showChartValues = true;
  bool _showChartValuesInPercentage = true;
  bool _showChartValuesOutside = true;

  LegendShape _legendShape = LegendShape.Circle;
  LegendPosition _legendPosition = LegendPosition.right;
  int key = 0;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Colors.white,
          //resizeToAvoidBottomPadding: false,
          key: _scaffoldDashbordKey,
          body: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Image.asset(
                    'assets/images/banner.png',
                    height: _height / 4.0,
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: _large
                            ? _height / 20
                            : (_medium ? _height / 20 : _height / 15),
                        left: _width / 20),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
                                    );
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: _width / 20),
                                    child: Text(
                                      AppData.current.user != null
                                          ? "Hi" +
                                              " " +
                                              AppData.current.user.UserName
                                          : '',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _logout();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, bottom: 8),
                                    child: Icon(
                                      Icons.settings_power,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: _width / 9),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      AppData.current.user != null
                                          ? AppData.current.user.BranchName
                                          : '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
              Visibility(
                visible: AppData.current.user.RoleNo == 1,
                child: GestureDetector(
                  onTap: () {
                    showClientbranches();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, top: 5),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        child: Text(
                          "Select Branch",
                          style: TextStyle(
                              //   decoration: TextDecoration.underline,
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AppData.current.user.RoleNo != 1
                  ? getAtendanceSummaryReport()
                  : getDashboardReport(),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: customFab(context),
          bottomNavigationBar: BottomNavigationBarApp(context, 0),
        ),
      ),
    );
  }
  Widget getAtendanceSummaryReport() {
    int count = 0;
    return summaryReports != null &&
            summaryReports.length != 0 &&
            totalVisit != null &&
            totalVisit.length != 0
        ? Expanded(
            child: Container(
              color: Colors.white,
              child: StaggeredGridView.count(
                shrinkWrap: true,
                primary: true,
                crossAxisCount: 4,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(child: mychart1Items("Monthly Summary")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: myTextItems(
                        " Present", summaryReports[0].PresentCount.toString(),""),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: myTextItems(
                        "Leave", summaryReports[0].LeaveCountWithAppn.toString()," With App."),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: myTextItems(
                        "Leave", summaryReports[0].LeaveCountWithoutAppn.toString(), "Without App"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: myTextItems(" Late Mark",
                        summaryReports[0].LateMarkCount.toString(),""),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: myTextItems(
                        "Half Day", summaryReports[0].HalfDayCount.toString(),""),
                  ),
                  Padding(
                    padding: const EdgeInsets.only( right: 10),
                    child: myTextItems(
                        "Total Visit", totalVisit[0].TotalVisits.toString(),""),
                  ),
                ],
                staggeredTiles: [
                  StaggeredTile.extent(4, 220.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                ],
              ),
            ),
          )
        : Expanded(
            child: Container(
              color: Colors.white,
              child: StaggeredGridView.count(
                shrinkWrap: true,
                primary: true,
                crossAxisCount: 4,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(child: mychart1Items("Monthly Summary")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: myTextItems(" Present", "0",""),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: myTextItems("Leave","0","With App." ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: myTextItems("Leave","0","Without App."),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: myTextItems("Late Mark", "0",""),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: myTextItems("Half Day", "0",""),
                  ),
                  Padding(
                    padding: const EdgeInsets.only( right: 10),
                    child: myTextItems("Total Visit", "0",""),
                  ),
                ],
                staggeredTiles: [
                  StaggeredTile.extent(4, 220.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                  StaggeredTile.extent(2, 80.0),
                ],
              ),
            ),
          );
  }
  Widget getDashboardReport() {
    return dashboradSummary != null && dashboradSummary.length != 0
        ? Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 5),
                    child: Text(
                      "Todays Attendance",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                      height: 120,
                      child: PieChart(
                        key: ValueKey(key),
                        dataMap: dataMapadmin,
                        animationDuration: Duration(milliseconds: 800),
                        chartLegendSpacing: _chartLegendSpacing,
                        chartRadius:
                            MediaQuery.of(context).size.width / 3.2 > 250
                                ? 180
                                : MediaQuery.of(context).size.width / 5.0,
                        colorList: colorListAdmin,
                        initialAngleInDegree: 0,
                        chartType: _chartType,
                        centerText: _showCenterText ? "HYBRID" : null,
                        legendOptions: LegendOptions(
                          showLegendsInRow: _showLegendsInRow,
                          legendPosition: _legendPosition,
                          showLegends: _showLegends,
                          legendShape: _legendShape == LegendShape.Circle
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          legendTextStyle: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        chartValuesOptions: ChartValuesOptions(
                          showChartValueBackground: _showChartValueBackground,
                          showChartValues: _showChartValues,
                          showChartValuesInPercentage:
                              _showChartValuesInPercentage,
                          showChartValuesOutside: _showChartValuesOutside,
                        ),
                        ringStrokeWidth: _ringStrokeWidth,
                      )),
                  Expanded(
                    child: DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          Container(
                            color: Theme.of(context).secondaryHeaderColor,
                            child: TabBar(
                              tabs: [
                                Tab(
                                  child: Text(
                                    "Total Emp.",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Tab(
                                  child: Text("Present",
                                      style: TextStyle(fontSize: 12)),
                                ),
                                Tab(
                                  child: Text("Absent",
                                      style: TextStyle(fontSize: 12)),
                                ),
                                Tab(
                                  child: Text("Late Emp",
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ), // create widgets for each tab bar here
                          Expanded(
                            child: TabBarView(
                              children: [
                                // first tab bar view widget
                                Container(
                                    color: Colors.white,
                                    child: getEmplyeeTab()),
                                // second tab bar viiew widget
                                Container(
                                    color: Colors.white,
                                    child: getPresentEmplyeeTab()),
                                Container(
                                    color: Colors.white,
                                    child: getAbsentEmplyeeTab()),
                                Container(
                                    color: Colors.white,
                                    child: getLateMarkEmplyeeTab()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 5),
                    child: Text(
                      "Todays Attendance",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                      height: 120,
                      child: PieChart(
                        key: ValueKey(key),
                        dataMap: dataMapadmin,
                        animationDuration: Duration(milliseconds: 800),
                        chartLegendSpacing: _chartLegendSpacing,
                        chartRadius:
                            MediaQuery.of(context).size.width / 3.2 > 250
                                ? 180
                                : MediaQuery.of(context).size.width / 5.0,
                        colorList: colorListAdmin,
                        initialAngleInDegree: 0,
                        chartType: _chartType,
                        centerText: _showCenterText ? "HYBRID" : null,
                        legendOptions: LegendOptions(
                          showLegendsInRow: _showLegendsInRow,
                          legendPosition: _legendPosition,
                          showLegends: _showLegends,
                          legendShape: _legendShape == LegendShape.Circle
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          legendTextStyle: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        chartValuesOptions: ChartValuesOptions(
                          showChartValueBackground: _showChartValueBackground,
                          showChartValues: _showChartValues,
                          showChartValuesInPercentage:
                              _showChartValuesInPercentage,
                          showChartValuesOutside: _showChartValuesOutside,
                        ),
                        ringStrokeWidth: _ringStrokeWidth,
                      )),
                  Expanded(
                    child: DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          Container(
                            color: Theme.of(context).secondaryHeaderColor,
                            child: TabBar(
                              tabs: [
                                Tab(
                                  child: Text(
                                    "Total Emp.",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Tab(
                                  child: Text("Present",
                                      style: TextStyle(fontSize: 12)),
                                ),
                                Tab(
                                  child: Text("Absent",
                                      style: TextStyle(fontSize: 12)),
                                ),
                                Tab(
                                  child: Text("Late Emp",
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ), // create widgets for each tab bar here
                          Expanded(
                            child: TabBarView(
                              children: [
                                // first tab bar view widget
                                Container(
                                    color: Colors.white,
                                    child: getEmplyeeTab()),
                                // second tab bar viiew widget
                                Container(
                                    color: Colors.white,
                                    child: getPresentEmplyeeTab()),
                                Container(
                                    color: Colors.white,
                                    child: getAbsentEmplyeeTab()),
                                Container(
                                    color: Colors.white,
                                    child: getLateMarkEmplyeeTab()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
  Material mychart1Items(String title) {
    return Material(
        color: Colors.white,
        elevation: 14.0,
        borderRadius: BorderRadius.circular(24.0),
        shadowColor: Color(0x802196F3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                StringHandlers.capitalizeWords(
                    "${onemonthAgo != null ? DateFormat('dd MMM yy ').format(onemonthAgo) : ""} - ${yesterday != null ? DateFormat('dd MMM yy ').format(yesterday) : ""}"),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.blue[800],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: PieChart(
                key: ValueKey(key),
                dataMap: dataMap,
                animationDuration: Duration(milliseconds: 800),
                chartLegendSpacing: _chartLegendSpacing,
                chartRadius: MediaQuery.of(context).size.width / 3.2 > 300
                    ? 300
                    : MediaQuery.of(context).size.width / 3.2,
                colorList: colorList,
                initialAngleInDegree: 0,
                chartType: _chartType,
                centerText: _showCenterText ? "HYBRID" : null,
                legendOptions: LegendOptions(
                  showLegendsInRow: _showLegendsInRow,
                  legendPosition: _legendPosition,
                  showLegends: _showLegends,
                  legendShape: _legendShape == LegendShape.Circle
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  legendTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValueBackground: _showChartValueBackground,
                  showChartValues: _showChartValues,
                  showChartValuesInPercentage: _showChartValuesInPercentage,
                  showChartValuesOutside: _showChartValuesOutside,
                ),
                ringStrokeWidth: _ringStrokeWidth,
              ),
            ),
          ],
        ));
  }
  Material myTextItems(String title, String subtitle,String middleTitle) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                      middleTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget getEmplyeeTab() {
    int count = 0;
    return employee != null && employee.length != 0
        ? ListView(
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
                        "In Time",
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  rows: new List<DataRow>.generate(
                    employee.length,
                    (int index) {
                      count++;
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              count.toString(),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              StringHandlers.capitalizeWords(
                                  employee[index].UserName),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          DataCell(
                            Text(
                              employee[index].Ent_IN != null
                                  ? DateFormat('hh:mm aaa')
                                      .format(employee[index].Ent_IN)
                                  : '-',
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: "Employee Not available",
                );
              },
            ),
          );
  }
  Widget getPresentEmplyeeTab() {
    int count = 0;
    return attendancePresent != null && attendancePresent.length != 0
        ? ListView(
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
                        "In Time",
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  rows: new List<DataRow>.generate(
                    attendancePresent.length,
                    (int index) {
                      count++;
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              count.toString(),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              StringHandlers.capitalizeWords(
                                  attendancePresent[index].UserName),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          DataCell(
                            Text(
                              attendancePresent[index].Ent_IN != null
                                  ? DateFormat('hh:mm aaa')
                                      .format(attendancePresent[index].Ent_IN)
                                  : '-',
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: "Employee Not available",
                );
              },
            ),
          );
  }
  Widget getAbsentEmplyeeTab() {
    int count = 0;
    return attendanceAbsent != null && attendanceAbsent.length != 0
        ? ListView(
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
                        "In Time",
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  rows: new List<DataRow>.generate(
                    attendanceAbsent.length,
                    (int index) {
                      count++;
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              count.toString(),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              StringHandlers.capitalizeWords(
                                  attendanceAbsent[index].UserName),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          DataCell(
                            Text(
                              attendanceAbsent[index].Ent_IN != null
                                  ? DateFormat('hh:mm aaa')
                                      .format(attendanceAbsent[index].Ent_IN)
                                  : '-',
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: "Employee Not available",
                );
              },
            ),
          );
  }
  Widget getLateMarkEmplyeeTab() {
    int count = 0;
    return attendanceLateMark != null && attendanceLateMark.length != 0
        ? ListView(
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
                        "In Time",
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  rows: new List<DataRow>.generate(
                    attendanceLateMark.length,
                    (int index) {
                      count++;
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              count.toString(),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              StringHandlers.capitalizeWords(
                                  attendanceLateMark[index].UserName),
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          DataCell(
                            Text(
                              attendanceLateMark[index].Ent_IN != null
                                  ? DateFormat('hh:mm aaa')
                                      .format(attendanceLateMark[index].Ent_IN)
                                  : '-',
                              style: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return CustomDataNotFound(
                description: "Employee Not available",
              );
            },
          );
  }
  void _logout() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: "Yes",
        onActionTapped: () {
          DBHandler().logout(AppData.current.user);
          AppData.current.user = null;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (Route<dynamic> route) => false,
          );
        },
        actionColor: Colors.red,
        message: "Do you really want to logout?",
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  Future<List<Configuration>> fetchConfiguration() async {
    List<Configuration> softCampusConfigList = [];
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Loading . . .';
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchSchoolsUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              ConfigurationUrls.GET_CONFIGURATION,
        ).replace(
          queryParameters: {
            'ConfigurationName': 'Attendance App Version',
            'ConfigurationGroup': 'Auto Update For Android',
            UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":"Employee",
            UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
            UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
            UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()
          },
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          bool whatsNewOverlay =
              AppData.current.preferences.getBool('whatsNew_overlay') ?? false;
          if (!whatsNewOverlay) {
            AppData.current.preferences.setBool("whatsNew_overlay", true);
            _showOverlay(context);
          }
          softCampusConfigList = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            softCampusConfigList = responseData
                .map(
                  (item) => Configuration.fromJson(item),
                )
                .toList();
          });
          bool whatsNewOverlay =
              AppData.current.preferences.getBool('whatsNew_overlay') ?? false;
          if (!whatsNewOverlay) {
            AppData.current.preferences.setBool("whatsNew_overlay", true);
            _showOverlay(context);
          }
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      isLoading = false;
    });

    return softCampusConfigList;
  }
  Future<bool> _onBackPressed() {
    exit(1);
  }
  Future<void> saveUserToken(String token) async {
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          'ApplicationType': 'Employee Attendance',
          'AppVersion': '1',
          'MacAddress': 'xxxxxx',
          "ClientCode": AppData.current.user.ClientId.toString(),
          "UserNo": AppData.current.user.UserNo.toString(),
          "PackageName": "com.demo.emat",
          'UserType': 'Parent',
          "RegistrationToken": token,
          UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":"Employee",
          UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
          UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
          UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()
        };

        Uri saveMessageUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              NotificationUrls.GET_SAVEUSERTOKEN,
        ).replace(
          queryParameters: params,
        );

        http.Response response = await http.post(
          saveMessageUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: '',
          encoding: Encoding.getByName("utf-8"),
        );
        if (response.statusCode == HttpStatusCodes.ACCEPTED) {
          bool whatsNewOverlay =
              AppData.current.preferences.getBool('whatsNew_overlay') ?? false;
          if (!whatsNewOverlay) {
            AppData.current.preferences.setBool("whatsNew_overlay", true);
            _showOverlay(context);
          }
        } else {
          bool whatsNewOverlay =
              AppData.current.preferences.getBool('whatsNew_overlay') ?? false;
          if (!whatsNewOverlay) {
            AppData.current.preferences.setBool("whatsNew_overlay", true);
            _showOverlay(context);
          }
          /*UserMessageHandler.showMessage(
            _scaffoldHomeKey,
            response.body.toString(),
            MessageTypes.warning,
          );*/
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
  }
  fetchAttendanceRecord() async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      isLoading = true;
      loadingText = "Loading Data..";

      List<Attendance> attendance = [];
      try {
        DBHandler().getAttendanceRecord().then((res) {
          attendance = res;
          if (attendance.length > 0) {
            for (int i = 0; i < attendance.length; i++) {
              postAttendance(attendance[i]);
            }
          }
        });
      } catch (e) {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          e.toString(),
          MessageTypes.warning,
        );
      }
    }
  }
  Future<void> postAttendance(Attendance attendance) async {
    var formatter = new DateFormat('yyyy-MM-dd');
    try {
      setState(() {
        isLoading = true;
        loadingText = "Saving..";
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.current.user;
        Map<String, dynamic> params = {};
        Uri saveCircularUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AttendanceUrls.POST_ATTENDANCE,
            params);

        String jsonBody = json.encode(attendance);
        http.Response response = await http.post(
          saveCircularUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"),
        );
        if (response.statusCode == HttpStatusCodes.CREATED) {
          if (attendance.Selfy != null) {
            await postVisitImage(
                int.parse(response.body.toString()), attendance);
          } else {
            Pattern pattern = r'^[0-9]+$';
            RegExp regex = new RegExp(pattern);
            if (!regex.hasMatch(response.body.toString())) {
              //its Return  error  then print this
              UserMessageHandler.showMessage(
                _scaffoldDashbordKey,
                response.body.toString(),
                MessageTypes.information,
              );
            } else {
              //its Return Number then print this
              await DBHandler().deleteAttendance(attendance.entNo);
              UserMessageHandler.showMessage(
                _scaffoldDashbordKey,
                "Offline Attendance/Visit Mark Successfully!",
                MessageTypes.information,
              );
            }
          }
          //  _clearData();
        } else {
          if(response.statusCode == HttpStatusCodes.NOT_ACCEPTABLE){
            await DBHandler().deleteAttendance(attendance.entNo);
            UserMessageHandler.showMessage(
              _scaffoldDashbordKey,
              response.body.toString(),
              MessageTypes.error,
            );
          }else{
            UserMessageHandler.showMessage(
              _scaffoldDashbordKey,
              response.body.toString(),
              MessageTypes.error,
            );
          }

        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      isLoading = false;
    });
  }
  Future<void> postVisitImage(int visitNo, Attendance attendance) async {
    final decodedBytes = base64Decode(attendance.Selfy);
    String date = DateFormat('ddMMYYYYhhmm').format(DateTime.now());
    var filepath = Io.File("/storage/emulated/0/" + date + ".png");
    filepath.writeAsBytesSync(decodedBytes);

    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Attendance/PostVisitSelfy',
      ).replace(
        queryParameters: {
          'LocEntNo': visitNo.toString(),
          'ClientId': AppData.current.user.ClientId.toString(),
          'Brcode': AppData.current.user.Brcode.toString(),
          UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":"Employee",
          UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
          UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
          UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString(),
          UserFieldNames.UserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
        },
      );

      final mimeTypeData =
          lookupMimeType(filepath.path, headerBytes: [0xFF, 0xD8]).split('/');
      final imageUploadRequest =
          http.MultipartRequest(HttpRequestMethods.POST, postUri);
      final file = await http.MultipartFile.fromPath(
        'image',
        filepath.path,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ),
      );
      imageUploadRequest.fields['ext'] = mimeTypeData[1];
      imageUploadRequest.files.add(file);
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == HttpStatusCodes.CREATED) {
        await DBHandler().deleteAttendance(attendance.entNo);
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          "Offline Attendance/Visit Mark Successfully!",
          MessageTypes.information,
        );
      } else {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          response.body,
          MessageTypes.warning,
        );
      }
    } else {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Please check your wifi or mobile data is active.",
        MessageTypes.warning,
      );
    }
  }
  void _showOverlay(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return new CupertinoAlertDialog(
            title: new Text("What's New "),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, top: 5),
                  child: new Text(" 1.Maintain Leave hierarchy. "),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: new Text("2.Add Column Leave With Application and Leave Without Application in Attendance Report."),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: new Text("3.Add Same Filters in Attendance Report."),
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
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
            "sdt": formatter.format(onemonthAgo),
            "edt": formatter.format(yesterday),
            UserFieldNames.UserNo:  AppData.current.user.UserNo.toString(),
            UserFieldNames.RefUserNo : AppData.current.user.UserNo.toString(),
            "Brcode": AppData.current.user.Brcode,
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
          /*UserMessageHandler.showMessage(
            _scaffoldDashbordKey,
            response.body,
            MessageTypes.error,
          );*/
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
          _scaffoldDashbordKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return attendacesummary;
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
                fetchDashboardAttendance(selectedbranch.brcode).then((result) {
                  setState(() {
                    dashboradSummary = result;
                    if (dashboradSummary.length > 0) {
                      dataMapadmin = {
                        // "Total Employee.": double.parse(dashboradSummary[0].TotalEmp.toString()),
                        "Present": double.parse(
                            dashboradSummary[0].PresentCount.toString()),
                        "Absent/Leave": double.parse(
                            dashboradSummary[0].AbsentCount.toString()),
                        "Late Mark": double.parse(
                            dashboradSummary[0].LateCount.toString()),
                      };
                    }
                  });
                });
                fetchDashboardDetailReport("%").then((result) {
                  setState(() {
                    employee = result;
                  });
                });
                fetchDashboardDetailReport("P").then((result) {
                  setState(() {
                    attendancePresent = result;
                  });
                });
                fetchDashboardDetailReport("A").then((result) {
                  setState(() {
                    attendanceAbsent = result;
                  });
                });
                fetchDashboardDetailReport("LM").then((result) {
                  setState(() {
                    attendanceLateMark = result;
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
  Future<List<Branch>> fetchBranches() async {
    List<Branch> branch;
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {};

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                BranchUrls.GET_BRANCH,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _scaffoldDashbordKey,
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
            // int clientno = AppData.current.client_No;
          });
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        branch = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
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
  Future<List<VisitCount>> fetchVisitCount(String brcode) async {
    List<VisitCount> VisitSummary = [];
    try {
      setState(() {
        isLoading = true;
      });
      DateTime today = new DateTime.now();
      DateTime onemonthAgo = AppData.current.user.RoleNo == 1
          ? new DateTime.now()
          : today.subtract(new Duration(days: 30));
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        var formatter = new DateFormat('yyyy-MM-dd');
        Uri fetchStudentAttendanceReportUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              VisitCountConstUrls.GET_DASHBOARD_VISIT,
        ).replace(
          queryParameters: {
            "sdt": formatter.format(onemonthAgo),
            "edt": formatter.format(today),
            "UserNo": AppData.current.user.UserNo.toString(),
            "Brcode": brcode,
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
            _scaffoldDashbordKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          List responseData = json.decode(response.body);
          int cnt = 0;
          VisitSummary = responseData
              .map(
                (item) => VisitCount.fromJson(item),
              )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return VisitSummary;
  }
  Future<List<AttendanceReport>> fetchDashboardDetailReport(String atStatus) async {
    List<AttendanceReport> attendace = [];
    try {
      setState(() {
        isLoading = true;
      });
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        var formatter = new DateFormat('yyyy-MM-dd');
        DateTime today = new DateTime.now();
        Uri fetchStudentAttendanceReportUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              AttendanceReportUrls.DASHBOARD_DETAIL,
        ).replace(
          queryParameters: {
            "Client_No": AppData.current.client_No.toString(),
            "sdt": formatter.format(today),
            "edt": formatter.format(today),
            "UserNo": "0",
            "Brcode": selectedbranch != null
                ? selectedbranch.brcode
                : AppData.current.user.Brcode,
            "AtStatus": atStatus,
            "Domain": AppData.current.Domain.toString(),
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
          /* UserMessageHandler.showMessage(
            _scaffoldDashbordKey,
            response.body,
            MessageTypes.error,
          );*/
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
          _scaffoldDashbordKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return attendace;
  }
  Future<List<DashboardSummary>> fetchDashboardAttendance(String brcode) async {
    List<DashboardSummary> dashboardsummary = [];

    try {
      setState(() {
        isLoading = true;
      });
      DateTime today = new DateTime.now();
      DateTime onemonthAgo = today.subtract(new Duration(days: 30));
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        var formatter = new DateFormat('yyyy-MM-dd');
        Uri fetchStudentAttendanceReportUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              DashboardSummaryUrls.GET_DASHBOARD_ATTENDANCE,
        ).replace(
          queryParameters: {
            /*"sdt": formatter.format(onemonthAgo),
            "edt": formatter.format(today),*/
            "UserNo": "0",
            "Brcode": brcode,
            "Client_No": AppData.current.client_No.toString(),
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
          /*UserMessageHandler.showMessage(
            _scaffoldDashbordKey,
            response.body,
            MessageTypes.error,
          );*/
        } else {
          List responseData = json.decode(response.body);
          int cnt = 0;
          dashboardsummary = responseData
              .map(
                (item) => DashboardSummary.fromJson(item),
              )
              .toList();
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldDashbordKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldDashbordKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return dashboardsummary;
  }
  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}

enum PermissionCheck {
  /// Permission to access the requested feature is denied by the user.
  denied,

  /// The feature is disabled (or not available) on the device.
  disabled,

  /// Permission to access the requested feature is granted by the user.
  granted,

  /// The user granted restricted access to the requested feature (only on iOS).
  restricted,

  /// Permission is in an unknown state
  unknown
}
