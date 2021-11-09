import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_alert_dialog.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action_message.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/custom_take_picture.dart';
import 'package:digitalgeolocater/constants/http_request_methods.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/menu_constants.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/attendancConfigration.dart';
import 'package:digitalgeolocater/models/attendance.dart';
import 'package:digitalgeolocater/models/branch.dart';
import 'package:digitalgeolocater/models/client.dart';
import 'package:digitalgeolocater/models/selfy_flag.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/menu_help_page.dart';
import 'package:digitalgeolocater/page/my_location.dart';
import 'package:digitalgeolocater/page/selfie_attendance_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool isLoading,islocLoading;
  bool attendanceFlag;
  bool islocationLoading;
  bool isSearchingLoading ;
  bool loadingSearchingText ;
  String loadingText, entryType, latitude = "", longitude = "",altitude;
  String selectedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  String selectedItem = "InTime";
  List<String> attendanceType = ['InTime', 'OutTime'];
  List<Client> branches = [];
  Client selectedClient;
  GlobalKey<ScaffoldState> _AttendancePageGlobalKey;
  DateTime selectedTodayDate = DateTime.now();
  List<SelfyFlagAttendance> _selfyFlag = [];
  List<AttendanceConfiguration> _attendanceConfig = [];
  List<AttendanceConfiguration> _SelfieConfig = [];
  List<String> menus = ['Camera'];
  File imgFile;
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath, address = "", attendConfig = "Y", selfieConfigration = "N",time;
  dynamic firstCamera;
  int timer = 120, SelfyFlag = 0;
  bool canceltimer = false;
  Attendance attendance;
  Branch selectedbranch;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _AttendancePageGlobalKey = GlobalKey<ScaffoldState>();
    this.loadingText = 'Searching Location . . .';
    this.isLoading = true;
    this.islocLoading = true;
    this.attendanceFlag = false;
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      firstCamera = cameras[1];
      bool attendanceOverlay = AppData.current.preferences.getBool('attendance_overlay') ?? false;
      if (!attendanceOverlay) {
        AppData.current
            .preferences
            .setBool("attendance_overlay", true);
        _showOverlay(context);
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
    fetchAttendanceConfig().then((result) {
      setState(() {
        this.isLoading = true;
        _attendanceConfig = result;
        _getLocation();
        fetchSelfyFlag().then((result) {
          setState(() {
            _selfyFlag = result;
            fetchSelfieConfig().then((result) {
              setState(() {
                _SelfieConfig = result;
              });
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
        isLoading: this.isLoading || islocLoading,
        loadingText: this.loadingText,
        child: Scaffold(
            key: _AttendancePageGlobalKey,
            appBar: NewGradientAppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MenuHelpPage(MenuNameConst.Attendance)),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyLocationPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.phone_in_talk,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              gradient: LinearGradient(
                  colors: [Colors.green[500], Colors.lightBlueAccent]),
              title: CustomAppBar(
                title: AppData.current.user != null
                    ? " Hi " + AppData.current.user.UserName
                    : '',
                subtitle: "Mark Your Daily Attendance",
              ),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
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
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Text(
                                        "Select Date",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                            color: Colors.blue[800],
                                            fontSize: 15),
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
                                          "Date",
                                          style: Theme.of(context)
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
                                                selectedDate,
                                                style: Theme.of(context)
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
                                            onTap: () {
                                              // _selectDateFrom(context);
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
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Text(
                                        "Select Current Location",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                            color: Colors.blue[800],
                                            fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                                selectedClient != null
                                                    ? selectedClient.BranchName
                                                    : '',
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Text(
                                        "Select EntryType",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                            color: Colors.blue[800],
                                            fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                      showAttendanceType();
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
                                                "Entry Type",
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
                                              selectedItem,
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
                              Visibility(
                                visible: attendanceFlag,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: imgFile == null
                                            ? Container(
                                          color: Colors.lightGreen[50],
                                          child: Center(
                                            child: Text(
                                              "Add Attendance Selfie",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body1
                                                  .copyWith(
                                                color: Colors.grey[700],
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                            : Image.file(
                                          imgFile,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0.0,
                                        bottom: 0.0,
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: Divider(
                                        height: 0.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: Container(
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder:
                                              (BuildContext context, int index) {
                                            return ListTile(
                                              leading: Icon(
                                                Icons.camera_alt,
                                                color: Colors.grey[700],
                                              ),
                                              title: Text(
                                                menus[index],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1
                                                    .copyWith(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => CustomTakePicture(
                                                      camera: firstCamera,
                                                    ),
                                                  ),
                                                ).then((res) {
                                                  setState(() {
                                                    imgFile = File(res);
                                                  });
                                                });
                                              },
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                0.0,
                                              ),
                                              child: Divider(
                                                height: 0.0,
                                              ),
                                            );
                                          },
                                          itemCount: menus.length,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0.0,
                                        bottom: 0.0,
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: Divider(
                                        height: 0.0,
                                      ),
                                    ),
                                  ],
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
                              _AttendancePageGlobalKey,
                              valMsg,
                              MessageTypes.warning,
                            );
                          } else {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) => CustomActionDialog(
                                actionName: "Yes",
                                onActionTapped: () {
                                  Navigator.pop(context);
                                  postAttendance();
                                },
                                actionColor: Colors.red,
                                message:
                                "Do you want to mark your Daily Attendance?",
                                onCancelTapped: () {
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }
                        },
                        child: Container(
                          color: Colors.blue[100],
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Center(
                              child: Text(
                                "MARK ATTENDANCE",
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
                Positioned(
                  right: 20.0,
                  bottom: 20.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: new FloatingActionButton(
                            elevation: 0.0,
                            heroTag: null,
                            child: new Icon(Icons.refresh),
                            backgroundColor: Colors.lightBlue,
                            onPressed: () {
                              if(latitude== null || latitude=='' ||longitude==null||longitude==''){
                                _getLocation();
                              }else{
                                fetchCurrentLocation().then((result) {
                                  setState(() {
                                    this.branches = result;
                                    this.isLoading = false;
                                    if (branches != null && branches.length != 0) {
                                      selectedClient = branches[0];
                                    } else {
                                     // getOfflineCurrentBranch();
                                    }
                                  });
                                });
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Visibility(
                          visible: selfieConfigration == 'Y',
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: new FloatingActionButton(
                                elevation: 0.0,
                                heroTag: null,
                                child: new Icon(Icons.phone_android),
                                backgroundColor: Colors.lightBlue,
                                onPressed: () {
                                  selfyAttendanceInstructions();
                                }),
                          ),
                        ),
                      )
                    ],
                  ),
                )

              ],
            ),
            backgroundColor: Colors.grey[200],
        ));
  }

  void showAttendanceType() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Entry Type",
        ),
        actions: List<Widget>.generate(
          attendanceType.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: attendanceType[i] == 'InTime' ? 'InTime' : 'OutTime',
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedItem =
                attendanceType[i] == 'InTime' ? 'InTime' : 'OutTime';
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  String getValidationMessage() {
    /*if (selectedbranch == null || selectedbranch == '')
      return "Please Select Branch where you visited.";*/

    if (selectedClient == null || selectedClient == '')
      return "Please Select Your current location";

    if (longitude == '' || longitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    if (latitude == '' || latitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    if (attendanceFlag == true) {
      if (this.imgFile == null) {
        return "Selfy is Mandatory.";
      }
    }
    ;

    return '';
  }
  Future<List<Client>> fetchCurrentLocation() async {
    List<Client> client;
    try {
      setState(() {
        isLoading = true;
        this.loadingText = 'Loading . . .';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          //"latitude": "19.3059153",
          //"longitude": "75.4433945" ,
          "latitude": latitude,
          "longitude": longitude,
          "BrCode": AppData.current.user.Brcode
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ClientUrls.GET_CLIENT,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _AttendancePageGlobalKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          // print(client);
          setState(() {
            List responseData = json.decode(response.body);
            client = responseData.map((item) => Client.fromJson(item)).toList();
          });
          await DBHandler().deleteCurrentBranch(client[0].Brcode);
          await DBHandler().saveBranch(client);
        }
      } else {
        UserMessageHandler.showMessage(
          _AttendancePageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
        client = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _AttendancePageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
      client = null;
    }
    setState(() {
      // isLoading = false;
    });
    return client;
  }
  void selfyAttendanceInstructions() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return new CupertinoAlertDialog(
            title: new Text(
              "Selfie Base Attendance ",
              style: TextStyle(fontSize: 16),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  "जर तुम्हाला लोकेशन डिटेक्ट होत नसेल तर तुम्ही सेल्फी पॉईंट वापरून अट्टेण्डन्स लावू इच्छिता का?,  \n\n "
                      "( जोपयंत ऍडमिन अट्टेण्डन्स अँप्रोव्ह करत नाहीत तोपर्यंत तुमची अट्टेण्डन्स रिपोर्ट मध्ये दिसणार नाही. )"),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Yes "),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelfieAttendancePage(),
                    ),
                  );
                  //Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("No "),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  Future<void> postAttendance() async {
    var formatter = new DateFormat('yyyy-MM-dd');
    if (selectedItem != null) {
      if (selectedItem == "InTime") {
        entryType = 'I';
      } else {
        entryType = 'O';
      }
      try {
        setState(() {
          isLoading = true;
          loadingText = "Saving..";
        });
        String netAvailablility="Y";
        String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
        if (connectionServerMsg != "key_check_internet") {
          netAvailablility = "Y";
        }else{
          netAvailablility = "N";
        }
        attendance = Attendance(
            UserNo: AppData.current.user.UserNo != 0
                ? AppData.current.user.UserNo
                : 0,
            EntDate: DateTime.parse(formatter.format(selectedTodayDate)),
            EntType: entryType,
            ClientId: AppData.current.user.ClientId,
            Brcode: AppData.current.user.Brcode,
            EntClientId: selectedClient != null ? selectedClient.ClientId : 0,
            EntBrcode: selectedClient != null ? selectedClient.Brcode : "0",
            longitude: longitude,
            latitude: latitude,
            EntTime: selectedTodayDate,
            EntDateTime: selectedTodayDate,
            Address: address != '' || address != null ? address : null,
            UserId: AppData.current.user.UserID,
            IsNet: netAvailablility,
            PassStatus: "P",
            Selfy: null
        );
        if(imgFile!=null){
          await compressAndGetFile(imgFile).then((value) {
            imgFile = value;
          });
        }

        if (connectionServerMsg != "key_check _internet") {
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
            if (imgFile != null) {
              await postVisitImage(int.parse(response.body.toString()));
            } else {
              Pattern pattern = r'^[0-9]+$';
              RegExp regex = new RegExp(pattern);
              if (!regex.hasMatch(response.body.toString())) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    message: Text(
                      response.body.toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        child: Text(
                          "Ok",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          _clearData();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                    //      Navigator.pop(context, true); // It worked for me instead of above line
                        },
                      )
                    ],
                  ),
                );
              } else {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    message: Text(
                      "Attendance mark successfully!",
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        child: Text(
                          "Ok",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          _clearData();
                         // Navigator.pop(context, true);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                      )
                    ],
                  ),
                );
              }
            }
          } else {
            UserMessageHandler.showMessage(
              _AttendancePageGlobalKey,
              response.body.toString(),
              MessageTypes.error,
            );
          }
        } else {
         // SaveAttendance();
          UserMessageHandler.showMessage(
            _AttendancePageGlobalKey,
            "Please check your wifi or mobile data is active.",
            MessageTypes.warning,
          );
        }
      } catch (e) {
       // SaveAttendance();
         UserMessageHandler.showMessage(
          _AttendancePageGlobalKey,
          "Not able to fetch data, please contact Software Provider!",
          MessageTypes.warning,
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<List<SelfyFlagAttendance>> fetchSelfyFlag() async {
    List<SelfyFlagAttendance> selfyFlag = [];

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
                SelfyFlagUrls.GET_SELFIE_FLAG,
            params);

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _AttendancePageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
        } else {
          List responseData = json.decode(response.body);
          selfyFlag = responseData
              .map(
                (item) => SelfyFlagAttendance.fromJson(item),
          )
              .toList();
          attendanceFlag = selfyFlag[0].SelfyFlag ?? false;
          await DBHandler().deleteUserSelfyFlag();
          await DBHandler().saveUserSelfyFlag(selfyFlag[0]).then((res) {
            var temp = res;
            print(temp);
          });
        }
      } else {
        await DBHandler().getUserSelfyFlag().then((res) {
          attendanceFlag = res.SelfyFlag;
        });

        UserMessageHandler.showMessage(
          _AttendancePageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      await DBHandler().getUserSelfyFlag().then((res) {
        attendanceFlag = res.SelfyFlag;
      });
      /*UserMessageHandler.showMessage(
        _AttendancePageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );*/
    }

    setState(() {
      // isLoading = false;
    });

    return selfyFlag;
  }
  Future<void> postVisitImage(int visitNo) async {
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
          UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":AppData.current.user.RoleNo == 3?"Manager":"Employee",
          UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
          UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
          UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString(),
          UserFieldNames.UserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
        },
      );

      final mimeTypeData =
      lookupMimeType(imgFile.path, headerBytes: [0xFF, 0xD8]).split('/');
      final imageUploadRequest =
      http.MultipartRequest(HttpRequestMethods.POST, postUri);
      final file = await http.MultipartFile.fromPath(
        'image',
        imgFile.path,
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
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              response.body.toString(),
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
              //    Navigator.pop(context, true);
                  _clearData();// It worked for me instead of above line
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              )
            ],
          ),
        );
      } else {
        UserMessageHandler.showMessage(
          _AttendancePageGlobalKey,
          response.body,
          MessageTypes.warning,
        );
      }
    } else {
      UserMessageHandler.showMessage(
        _AttendancePageGlobalKey,
        "Please check your wifi or mobile data is active.",
        MessageTypes.warning,
      );
    }
  }
  void _clearData() {
    setState(() {
      imgFile = null;
    });
  }
  void starttimer() async {
    const onesec = Duration(seconds: 1);
    Timer.periodic(onesec, (Timer t) {
      setState(() {
        if (timer < 1) {
          t.cancel();
        } else if (canceltimer == true) {
          t.cancel();
        } else {
          timer = timer - 1;
        }
        if (timer <= 1) {
          t.cancel();
          finishPage();
        }
      });
    });
  }
  void finishPage() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: _onBackPressed,
        child: new CupertinoAlertDialog(
          title: new Text("Alert"),
          content: new Text("Location Timeout.."),
          actions: [
            CupertinoDialogAction(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                isDefaultAction: true,
                child: new Text("Close"))
          ],
        ),
      ),
    );
  }
  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
  void showCurrentlocation() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Select Current Location",
        ),
        actions: List<Widget>.generate(
          branches.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: branches[i].BranchName,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedClient = branches[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  _getLocation() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.featureName} : ${first.addressLine}");
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    altitude =  position.altitude.toString();
    address= first.addressLine;
    this.islocLoading = false;
    if (longitude == '' || longitude == null || latitude == '' || latitude == null){
      UserMessageHandler.showMessage(
        _AttendancePageGlobalKey,
        "Not able to detect your location, Please refresh or enable the location.",
        MessageTypes.warning,
      );
    }else{
      fetchCurrentLocation().then((result) {
        setState(() {
          this.branches = result;
          this.isLoading = false;
          if (branches != null && branches.length != 0) {
            selectedClient = branches[0];
          } else {
          }
        });
      });
    }
  }
  Future<List<AttendanceConfiguration>> fetchAttendanceConfig() async {
    List<AttendanceConfiguration> attendanceConfig = [];

    try {
      setState(() {
        isLoading = true;
        this.loadingText = 'Loading . . .';
      });
      Map<String, dynamic> params = {
        // "user_id": user != null ? user.user_id : "",
      };

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AttendanceConfigurationUrls.GET_CONFIGURATION,
            params);

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _AttendancePageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
        } else {
          List responseData = json.decode(response.body);
          attendanceConfig = responseData
              .map(
                (item) => AttendanceConfiguration.fromJson(item),
          )
              .toList();
          attendConfig = attendanceConfig[0].Evalue ?? "Y";
          await DBHandler().deleteAttendanceConfig();
          await DBHandler().saveAttendanceConfig(attendanceConfig);
        }
      } else {
        await DBHandler().getAttendanceConfig().then((res) {
          attendanceConfig = res;
          attendConfig = attendanceConfig[0].Evalue ?? "Y";
        });

        UserMessageHandler.showMessage(
          _AttendancePageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      await DBHandler().getAttendanceConfig().then((res) {
        attendanceConfig = res;
        attendConfig = attendanceConfig[0].Evalue ?? "Y";
      });
      await DBHandler().getUserSelfyFlag().then((res) {
        attendanceFlag = res.SelfyFlag;
      });
      /*UserMessageHandler.showMessage(
        _AttendancePageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );*/
    }

    /*setState(() {
      isLoading = false;
    });*/

    return attendanceConfig;
  }
  Future<List<AttendanceConfiguration>> fetchSelfieConfig() async {
    List<AttendanceConfiguration> selfieConfig = [];

    try {
      setState(() {
        isLoading = true;
        this.loadingText = 'Loading . . .';
      });
      Map<String, dynamic> params = {
        // "user_id": user != null ? user.user_id : "",
      };

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                AttendanceConfigurationUrls.GET_SELFIE_CONFIGURATION,
            params);

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _AttendancePageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
        } else {
          List responseData = json.decode(response.body);
          selfieConfig = responseData
              .map(
                (item) => AttendanceConfiguration.fromJson(item),
          )
              .toList();
          selfieConfigration = selfieConfig[0].Evalue ?? "N";
          //  await DBHandler().deleteAttendanceConfig();
          // await DBHandler().saveAttendanceConfig(attendanceConfig);
        }
      } else {
        UserMessageHandler.showMessage(
          _AttendancePageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _AttendancePageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
     // isLoading = false;
      if (latitude==null ||latitude==''||longitude==null ||longitude==''){
        isLoading = true;
      }else{
        isLoading = false;
      }

    });

    return selfieConfig;
  }
  void _showOverlay(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return new CupertinoAlertDialog(
            title: new Text(
              "माहिती",
              style: TextStyle(fontSize: 16),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  "कृपया शक्य असेल तर अट्टेण्डन्स मार्क करताना स्वतःचे नेट वापरावे ,काही वेळेस  लोकल वायफाय लोकेशन देण्यास रेस्ट्रिक्ट करते त्यामुळे तुमचे लोकेशन डिटेक्ट होण्यासाठी वेळ लागू शकतो."),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("ok "),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  Future<File> compressAndGetFile(File file) async {
    final dir = await path_provider.getTemporaryDirectory();

    final targetPath=dir.absolute.path + "/temp.jpg";
    var result=await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 70,
      rotate: 0,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }


}
