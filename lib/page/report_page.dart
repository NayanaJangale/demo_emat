
import 'dart:convert';
import 'dart:math';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/bottomNavigation.dart';
import 'package:digitalgeolocater/components/custom_alert_dialog.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/menu_constants.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/location_handler.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/branch.dart';
import 'package:digitalgeolocater/models/menu.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/select_date_for_leave_page.dart';
import 'package:digitalgeolocater/page/select_date_page.dart';
import 'package:digitalgeolocater/page/login_page.dart';
import 'package:digitalgeolocater/page/self_tracking_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportPage extends StatefulWidget {


  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  double _height, _width, _pixelRatio;
  bool _large, _medium;
  List<Menu> menus = [];
  bool isLoading = false;
  String loadingText = 'Loding..';
  String smsAutoId;
  Random random = new Random();
  List<Branch> branches = [];

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
  final GlobalKey<ScaffoldState> _scaffoldReportKey =
      new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    fetchMenus().then((result) {
      menus = result;
    });
  }

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
      child: Scaffold(
        backgroundColor: Colors.white,
       // resizeToAvoidBottomPadding: false,
        key: _scaffoldReportKey,
        body: Column(
          children: <Widget>[
            Stack(children: <Widget>[
              Image.asset(
                'assets/images/banner.png',
                height: _height/4.0,
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
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                              );},
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: _width / 20),
                                child: Text(
                                  AppData. current.user != null? "Hi "+ AppData.current.user.UserName: '',
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
                              onTap: (){
                                _logout();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15,bottom: 8),
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
                                  AppData. current.user != null?  AppData.current.user.BranchName: '',
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
            ],),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  RefreshIndicator(
                    onRefresh: () async {
                      fetchMenus().then((result) {
                        menus = result;
                      });
                    },
                    child: getListMenu() ,
                  )
                ],
              ),
            ),

          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar:
        BottomNavigationBarApp(context, 2),
      ),
    );
  }

  Widget getListMenu() {
    var list = new List<int>.generate(menuColors.length, (int i) => i);
    list.shuffle();

    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: menus.length,
        itemBuilder: (BuildContext context, int index) {
          int i = random.nextInt(menuColors.length);
          Color mBg = menuColors[list[i]];
          mBg = mBg.withOpacity(0.2);
          // String str = menus[index].MenuName.replaceAll(' ', ' ');
          return Card(
            //shadowColor: Color.fromRGBO(207, 207, 207, 1),
            color: Colors.white,
            /*shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(3.0),
                topLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(3.0),
                bottomLeft: Radius.circular(30.0),
              ),
            ),*/
            elevation: 5.0,
            child: ListTile(
              contentPadding: EdgeInsets.all(5.0),
              onTap: () {
                openMenu(index);
              },
              leading: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                ),
                child: CircleAvatar(
                  backgroundColor: mBg,
                  child: Image.asset(
                    "assets/images/${getIconImage(menus[index].MenuName)}",
                    color: menuColors[list[i]],
                  ),
                ),
              ),
              title: Text(
                menus[index].MenuName,
                style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              trailing: Icon(
                Icons.navigate_next,
                color: Colors.black45,
              ),
            ),
          );
        },
      ),
    );
  }
  openMenu(int index) {

     if (menus[index].MenuName == MenuNameConst.AttendanceReport) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectDatePage(MenuName: MenuNameConst.AttendanceReport),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.VisitReport) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectDatePage(MenuName: MenuNameConst.VisitReport),
        ),
      );
    } else if (menus[index].MenuName == MenuNameConst.SelfTracking) {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => SelfTrackingPage(),
         ),
       );
     }else if (menus[index].MenuName == MenuNameConst.LeaveReport) {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => SelectDateForLeavePage(MenuName: MenuNameConst.LeaveReport),
         ),
       );
     }else if (menus[index].MenuName == MenuNameConst.LateComers) {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => SelectDateForLeavePage(MenuName: MenuNameConst.LateComers),
         ),
       );
     }else if (menus[index].MenuName == MenuNameConst.EarlyOut) {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => SelectDateForLeavePage(MenuName: MenuNameConst.EarlyOut),
         ),
       );
     }
  }

  String getIconImage(String menu) {
    switch (menu) {
      case MenuNameConst.AttendanceReport:
      return MenuIconConst.AttendanceIcon;
      break;
      case MenuNameConst.VisitReport:
        return MenuIconConst.VisitIcon;
        break;
      case MenuNameConst.SelfTracking:
        return MenuIconConst.SelftrackingIcon;
        break;
      case MenuNameConst.LeaveReport:
        return MenuIconConst.LeaveIcon;
        break;
      case MenuNameConst.LateComers:
        return MenuIconConst.LateComersIcon;
        break;
      case MenuNameConst.EarlyOut:
        return MenuIconConst.LateComersIcon;
        break;
      default:
        return MenuIconConst.DefaultIcon;
    }
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

  Future<List<Menu>> fetchMenus() async {
    List<Menu> menus;
    try {
      setState(() {
        this.isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "ParentId": "6"
        };
        Uri fetchSchoolsUri = NetworkHandler.getUri(
          connectionServerMsg + ProjectSettings.rootUrl + MenuUrls.GET_MENU,
          params,
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _scaffoldReportKey,
            response.body,
            MessageTypes.warning,
          );

          menus = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            menus = responseData
                .map(
                  (item) => Menu.fromMap(item),
            )
                .toList();
          });

          await DBHandler().deleteMenu(AppData.current.user.UserNo,6);
          await DBHandler().saveMenu(menus, AppData.current.user.UserNo);
        }
      } else {
        menus = null;
        await DBHandler().getMenus(AppData.current.user.UserNo, 6).then((res) {
          setState(() {
            menus = res;
          });
        });
        print(menus);
      }
    } catch (e) {
      menus = null;
      await DBHandler().getMenus(AppData.current.user.UserNo, 6).then((res) {
        setState(() {
          menus = res;
        });
      });
      UserMessageHandler.showMessage(
        _scaffoldReportKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
      menus = null;
    }

    setState(() {
      this.isLoading = false;
    });

    return menus != null ? menus : [];
  }
}
