import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/auto_update_dialog.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/configration.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/dashboard_page.dart';
import 'package:digitalgeolocater/page/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashPage extends StatefulWidget {

  @override
  SplashPageState createState() => new SplashPageState();
}

class SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {

  double _height, _width, _pixelRatio,bottom1;
  bool _large, _medium;
  List<Configuration> _Config = [];
  var _visible = true;
  bool isLoading = false;
  String loadingText = 'Loading..';
  AnimationController animationController;
  Animation<double> animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    Duration threeSeconds = Duration(seconds: 3);
    Future.delayed(threeSeconds, () {
     // checkCurrentLogin(context);
      fetchConfiguration().then((result) {
        _Config = result;
        if (_Config != null && _Config.length > 0) {
          if (double.parse(_Config[0].ConfigurationValue) > ProjectSettings.AppVersion && _Config[0].ConfigurationName == 'Attendance App Version') {
            showDialog(
                barrierDismissible: false,
                context: this.context,
                builder: (_) {
                  return WillPopScope(
                    onWillPop: _onBackPressed,
                    child: AutoUpdateDialog(
                      message:
                      "This app is outdated. Please uninstall it and download latest version.",
                      onOkayPressed: () {
                        LaunchReview.launch(
                          androidAppId: "com.demo.emat",
                          iOSAppId: "",
                        );
                        exit(0);
                      },
                    ),
                  );
                });
          }else{
            checkCurrentLogin(context);
          }
        }else{
          checkCurrentLogin(context);
        }
      });
    });
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation =
    new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
  }
  Future<bool> _onBackPressed() {
    exit(1);
  }
  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((preferences) {
      AppData.current.preferences = preferences;
    });
    // AppData.current.preferences = this.preferences;
    bottom1 = MediaQuery.of(context).viewInsets.bottom;
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      //resizeToAvoidBottomPadding: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/loc_bg.png',
                width: animation.value * 100,
                height: animation.value * 100,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "Attendance From Anywhere, Anyhow..",
                  style: Theme.of(context).textTheme.body2.copyWith(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: _large? 18 : (_medium? 18 : 16)
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "4 way check - UserID + Time + Selfie + Location",
                  style: Theme.of(context).textTheme.body2.copyWith(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                      fontSize: _large? 16 : (_medium? 16 : 14)
                  ),
                ),
              ),
            ],
          ),
        ],
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
            UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin": AppData.current.user.RoleNo == 3?"Manager":"Employee",
            UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
            UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
            UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()

          },
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          /* bool whatsNewOverlay =
              AppData.current.preferences.getBool('whatsNew_overlay') ?? false;
          if (!whatsNewOverlay) {
            AppData.current.preferences.setBool("whatsNew_overlay", true);
            _showOverlay(context);
          }*/

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
          /*bool whatsNewOverlay =
              AppData.current.preferences.getBool('whatsNew_overlay') ?? false;
          if (!whatsNewOverlay) {
            AppData.current.preferences.setBool("whatsNew_overlay", true);
            _showOverlay(context);
          }*/
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } on SocketException {
      checkCurrentLogin(context);
      UserMessageHandler.showMessage(
        _scaffoldKey,
        'Connection Time Out..! Please try again.',
        MessageTypes.warning,
      );
    }catch (e) {
      UserMessageHandler.showMessage(
        _scaffoldKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      isLoading = false;
    });

    return softCampusConfigList;
  }

  Future<void> checkCurrentLogin(BuildContext context) async {
    try {
      User user = await DBHandler().getLoggedInUser();
      //User user = AppData.current.user;
      if (user != null) {
        AppData.current.user = user;
        Navigator.push(
          context, MaterialPageRoute(
          builder: (_) => DashboardPage(),
          // builder: (_) => SubjectsPage(),
        ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(),
          ),
        );
      }
    } catch (e) {}
  }
}
