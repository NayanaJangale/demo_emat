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
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/attendancConfigration.dart';
import 'package:digitalgeolocater/models/attendance.dart';
import 'package:digitalgeolocater/models/branch.dart';
import 'package:digitalgeolocater/models/selfy_flag.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/menu_help_page.dart';
import 'package:digitalgeolocater/page/my_location.dart';
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


class SelfieAttendancePage extends StatefulWidget {
  @override
  _SelfieAttendancePageState createState() => _SelfieAttendancePageState();
}

class _SelfieAttendancePageState extends State<SelfieAttendancePage> {
  bool isLoading,islocLoading,attendanceFlag = true;
  String loadingText, entryType, latitude = "", longitude = "",altitude;
  String selectedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  String selectedItem = "InTime";
  List<String> attendanceType = ['InTime', 'OutTime'];
  List<Branch> branches = [];
  GlobalKey<ScaffoldState> _SelfieAttendancePageGlobalKey;
  DateTime selectedTodayDate = DateTime.now();
  List<SelfyFlagAttendance> _selfyFlag = [];
  List<AttendanceConfiguration> _attendanceConfig = [];
  List<String> menus = ['Camera'];
  File imgFile;
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath, address = "",attendConfig="Y";
  dynamic firstCamera;
  int timer = 120 ,SelfyFlag=0;
  bool canceltimer = false;
  Attendance attendance;
  Branch selectedbranch ;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _SelfieAttendancePageGlobalKey = GlobalKey<ScaffoldState>();
    this.loadingText = 'Loading . . .';
    this.isLoading = true;
    this.islocLoading = true;
    this.attendanceFlag = true;
    _getLocation();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      firstCamera = cameras[1];
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });

  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
        isLoading: this.isLoading || this.islocLoading,
        loadingText: this.loadingText,
        child: WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            key: _SelfieAttendancePageGlobalKey,
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
            body: Padding(
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
                                right: 10.0, left: 10,top: 10
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
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  if(branches == null){
                                    UserMessageHandler.showMessage(
                                      _SelfieAttendancePageGlobalKey,
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
                            visible: true,
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
                                            fontWeight: FontWeight.w500,
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
                    behavior : HitTestBehavior.translucent,
                    onTap: () {
                      String valMsg = getValidationMessage();
                      if (valMsg != '') {
                        UserMessageHandler.showMessage(
                          _SelfieAttendancePageGlobalKey,
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
                            message: "Do you want to mark your Daily Attendance?",
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
            backgroundColor: Colors.grey[200],
          ),
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

    if (selectedbranch == null || selectedbranch == '')
      return "Please Select Your current location";

    if (longitude == '' || longitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    if (latitude == '' || latitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    if (attendanceFlag == true) {
      if (this.imgFile == null || this.imgFile == "") {
        return "Selfy is Mandatory.";
      }
    };

    return '';
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
          EntClientId: selectedbranch != null ? selectedbranch.ClientId : 0,
          EntBrcode: selectedbranch != null ? selectedbranch.brcode : "0",
          longitude: longitude,
          latitude: latitude,
          EntTime: selectedTodayDate,
          EntDateTime: selectedTodayDate,
          Address: address != '' || address != null ? address : null,
          UserId: AppData.current.user.UserID,
          IsNet: netAvailablility,
          PassStatus: "U",
          Selfy: null
        );
        if(imgFile!=null){
          await compressAndGetFile(imgFile).then((value) {
            imgFile = value;
          });
        }

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
                          Navigator.pop(context,
                              true); // It worked for me instead of above line

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
                          Navigator.pop(context, true);
                        },
                      )
                    ],
                  ),
                );
              }
            }
          } else {
            UserMessageHandler.showMessage(
              _SelfieAttendancePageGlobalKey,
              response.body.toString(),
              MessageTypes.error,
            );
          }
        } else {
          UserMessageHandler.showMessage(
            _SelfieAttendancePageGlobalKey,
            "Please check your wifi or mobile data is active.",
            MessageTypes.warning,
          );
         // SaveAttendance();
        }
      } catch (e) {
      //  SaveAttendance();
         UserMessageHandler.showMessage(
          _SelfieAttendancePageGlobalKey,
          "Not able to fetch data, please contact Software Provider!",
          MessageTypes.warning,
        );
      }
      setState(() {
        isLoading = false;
      });
    }
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
  /*Future<void> SaveAttendance () async {
    if(attendance.Selfy!=null){
      String strimg64;
      final bytes = imgFile.readAsBytesSync();
      strimg64 = base64Encode(bytes);
      attendance.Selfy = strimg64;
    }
    DBHandler().getCount().then((res){
      res = res+1;
      attendance.entNo = res ;
      attendance.PassStatus = "U" ;
      DBHandler().saveAttendance(attendance).then((res){
        if (res != null ){
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                "Offline Attendance mark successfully!",
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
                    Navigator.pop(context, true);
                  },
                )
              ],
            ),
          );
        }

      });

    });
  }*/
  
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

      final mimeTypeData = lookupMimeType(imgFile.path, headerBytes: [0xFF, 0xD8]).split('/');
      final imageUploadRequest = http.MultipartRequest(HttpRequestMethods.POST, postUri);
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                  // It worked for me instead of above line
                },
              )
            ],
          ),
        );
      } else {
        UserMessageHandler.showMessage(
          _SelfieAttendancePageGlobalKey,
          response.body,
          MessageTypes.warning,
        );
      }
    } else {
      UserMessageHandler.showMessage(
        _SelfieAttendancePageGlobalKey,
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
            _SelfieAttendancePageGlobalKey,
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
          _SelfieAttendancePageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        branch = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _SelfieAttendancePageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );

      branch = null;
    }
    setState(() {
      //isLoading = false;
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
                this.isLoading = false;
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
        _SelfieAttendancePageGlobalKey,
        "Not able to detect your location, Please refresh or enable the location.",
        MessageTypes.warning,
      );
    }else{
      fetchBranches().then((result) {
        setState(() {
          this.branches = result;
          if (branches != null && branches.length != 0) {
            selectedbranch = branches[0];
            String brcode = selectedbranch.brcode;
            this.isLoading = false;
          }
        });
      });
    }

  }
}
