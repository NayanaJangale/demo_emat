import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:contacts_service/contacts_service.dart';
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
import 'package:digitalgeolocater/models/client.dart';
import 'package:digitalgeolocater/models/purpose.dart';
import 'package:digitalgeolocater/models/attendance.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/menu_help_page.dart';
import 'package:digitalgeolocater/page/my_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:digitalgeolocater/app_data.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AddVisitPage extends StatefulWidget {
  @override
  _AddVisitPageState createState() => _AddVisitPageState();
}

class _AddVisitPageState extends State<AddVisitPage> {
  List<String> menus = ['Camera'];
  String selectedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  GlobalKey<ScaffoldState> _addVisitPageGlobalKey;
  bool isLoading,islocLoading;
  String
      mobNo,
      hintPersonName,
      loadingText,
      selectedVisit = "",
      subtitle,
      entryType,
      selectedItem = "Visit In",
      latitude = "",
      longitude = "",
      address = "",
      selectedVisitType = "Organization",
      selectedPurposeCategory = "Official",altitude;
  FocusNode clientFocusNode,
      remarkFocusNode,
      contactPersonFocusNode,
      contactNoFocusNode;
  TextEditingController ClientController;
  TextEditingController remarkController;
  TextEditingController contactPersonController;
  TextEditingController contactNoController;
  File imgFile;
  List<Purpose> purpose = [];
  List<Client> clients = [];
  Client selectedClient;
  Purpose selectedPurpose;
  Contact _contact;
  int timer = 120;
  bool canceltimer = false;
  Attendance attendance;
  static const iOSLocalizedLabels = false;
  DateTime selectedTodayDate = DateTime.now();
  List<String> attendanceType = [
    'Visit In',
    'Visit Out',
    'Break In',
    'Break Out'
  ];
  List<String> visitType = [
    'Organization',
    'Other',
  ];
  List<String> purposeCategory = [
    'Official',
    'Private',
  ];
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  dynamic firstCamera;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _contact = null;
    this.isLoading = true;
    this.islocLoading = true;
    this.loadingText = 'Searching Location  . . .';
    _addVisitPageGlobalKey = GlobalKey<ScaffoldState>();
    ClientController = TextEditingController();
    remarkController = TextEditingController();
    contactPersonController = TextEditingController();
    contactNoController = TextEditingController();

    clientFocusNode = FocusNode();
    remarkFocusNode = FocusNode();
    contactPersonFocusNode = FocusNode();
    contactNoFocusNode = FocusNode();
    fetchPurpose().then((result) {
      setState(() async {
        this.purpose = result;
        if (purpose != null && purpose.length != 0) {
          selectedPurpose = purpose[0];
        }else{
          await DBHandler()
              .getPurpose()
              .then((res) {
            setState(() {
              purpose= res;
              selectedPurpose = purpose[0];
            });
          });
        }
      });
    });
    _askPermissions(null);
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
    _contact == null;
    return CustomProgressHandler(
      isLoading: this.isLoading || this.islocLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addVisitPageGlobalKey,
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
                          MenuHelpPage(MenuNameConst.DailyVisits)),
                );
              },
            ),
            GestureDetector(
              onTap: (){
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
                ? "Hi " + AppData.current.user.UserName
                : '',
            subtitle: "Add Your Daily Visit..",
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
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
                                    style:
                                        Theme.of(context).textTheme.body2.copyWith(
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
                                      onTap: () {},
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
                                      /*Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                      ),*/
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
                              onTap: () {
                                showVisitType();
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
                                          "Visit Type",
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
                                        selectedVisitType,
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
                          visible: selectedVisitType == "Organization",
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
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
                                      "Select Current location",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                              color: Colors.blue[800],
                                              fontSize: 15),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: selectedVisitType == "Organization",
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                left: 10.0,
                                right: 10.0,
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                 /* if (clients == null) {
                                    UserMessageHandler.showMessage(
                                      _addVisitPageGlobalKey,
                                      "Current location not available",
                                      MessageTypes.warning,
                                    );
                                  } else {
                                    showClientbranches();
                                  }*/
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
                          visible: selectedVisitType == "Other",
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: new TextField(
                              focusNode: clientFocusNode,
                              controller: ClientController,
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
                                hintText: "Enter Client Name/Place",
                                hintStyle:
                                Theme.of(context).textTheme.body2.copyWith(
                                  color: Colors.grey[700],
                                ),
                                labelStyle:
                                Theme.of(context).textTheme.body2.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                              keyboardType: TextInputType.text,
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
                                showPurposeCategory();
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
                                        selectedPurposeCategory,
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
                          visible: selectedPurposeCategory == 'Official',
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                left: 10.0,
                                right: 10.0,
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  if (purpose == null) {
                                    UserMessageHandler.showMessage(
                                      _addVisitPageGlobalKey,
                                      "Purpose List Not Available.",
                                      MessageTypes.warning,
                                    );
                                  } else {
                                    showPurpose();
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
                                            "Purpose Type",
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
                                          selectedPurpose != null
                                              ? selectedPurpose.SysRemark
                                              : '',
                                          //selectedPurpose.SysRemark,
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
                            autofocus: false,
                            focusNode: remarkFocusNode,
                            controller: remarkController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              //icon: Icon(Icons.tit),
                              hintText: "Remark",
                              hintStyle: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.grey[700],
                                  ),
                              labelStyle:
                                  Theme.of(context).textTheme.body2.copyWith(
                                        color: Colors.grey[700],
                                      ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new TextField(
                            autofocus: false,
                            focusNode: contactNoFocusNode,
                            controller: contactNoController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              //icon: Icon(Icons.tit),
                              hintText: "Contact Person No.(Click on icon) ",
                              hintStyle: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.grey[700],
                                  ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _contact = null;
                                  contactPersonController.text = '';
                                  contactNoController.text = '';
                                  _pickContact();
                                  /* if(_contact != null){
                                    setState(() {
                                      contactNoController.text =_contact.phones.elementAt(0).value.replaceAll(" ", "");
                                      contactPersonController.text =_contact.displayName;
                                    });
                                  }*/
                                },
                                icon: Icon(Icons.contact_phone,
                                    color: Colors.grey[700], size: 25),
                              ),
                              labelStyle:
                                  Theme.of(context).textTheme.body2.copyWith(
                                        color: Colors.grey[700],
                                      ),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new TextField(
                            autofocus: false,
                            focusNode: contactPersonFocusNode,
                            controller: contactPersonController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              //icon: Icon(Icons.tit),
                              hintText: _contact != null
                                  ? _contact.displayName
                                  : "Contact Person Name ",
                              hintStyle: Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.grey[700],
                                  ),
                              labelStyle:
                                  Theme.of(context).textTheme.body2.copyWith(
                                        color: Colors.grey[700],
                                      ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: imgFile == null
                                ? Container(
                                    color: Colors.lightGreen[50],
                                    child: Center(
                                      child: Text(
                                        "Add Visit Selfie",
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
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey[700],
                                  ),
                                  title: Text(
                                    menus[index],
                                    style:
                                        Theme.of(context).textTheme.body1.copyWith(
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
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    String valMsg = getValidationMessage();
                    if (valMsg != '') {
                      UserMessageHandler.showMessage(
                        _addVisitPageGlobalKey,
                        valMsg,
                        MessageTypes.warning,
                      );
                    } else {
                      postVisit();
                    }
                  },
                  child: Container(
                    color: Colors.blue[100],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          "ADD VISIT",
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
            Positioned(
              right: 20.0,
              bottom: 20.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: SizedBox(
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
                              fetchClient().then((result) {
                                setState(() async {
                                  this.clients = result;
                                  this.isLoading = false;
                                  if (clients != null && clients.length != 0) {
                                    selectedClient = clients[0];
                                  }else{
                                   // getOfflineCurrentBranch();
                                  }
                                });
                              });
                            }
                          }),
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Future<void> _pickContact() async {
    try {
      final Contact contact = await ContactsService.openDeviceContactPicker(
          iOSLocalizedLabels: iOSLocalizedLabels);
      setState(() {
        _contact = contact;
        String contactNo =_contact.phones.elementAt(0).value.replaceAll(" ", "");

        if (contactNo.startsWith("+91")) {
          contactNo = contactNo.replaceFirst("+91", '');
        }
        if (contactNo.startsWith("0", 0)) {
          contactNo = contactNo.replaceFirst("0", '');
        }
        contactNo = contactNo.replaceAll("-", '');
        contactNoController.text = contactNo;
        contactPersonController.text = _contact.displayName;
      });
    } catch (e) {
      print(e.toString());
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
  String getValidationMessage() {
    if (selectedVisitType == 'Other') {
      if (ClientController.text == '') return "Client Name is Mandatory.";
    } else {
      if (selectedClient == null || selectedClient == '')
        return "Please Select Client Name";
    }
    if (selectedPurposeCategory == 'Official') {
      if (selectedPurpose == null) return "Purpose is Mandatory.";
    }
    if (contactNoController.text != null && contactNoController.text != '') {
      if (contactNoController.text.length != 10) {
        return "Enter Valid Mobile Number.";
      }
      Pattern pattern = r'^[0-9]+$';
      RegExp regex = new RegExp(pattern);

      if (!regex.hasMatch(contactNoController.text))
        return "Enter Valid Mobile Number.";
    }
    if (longitude == '' || longitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    if (latitude == '' || latitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    if (this.imgFile == null) {
      return "Selfy is Mandatory.";
    }
    return '';
  }
  Future<void> postVisit() async {
    try {
      if (selectedItem != null) {
        if (selectedItem == "Visit In") {
          entryType = 'VI';
        } else if (selectedItem == "Visit Out") {
          entryType = 'VO';
        } else if (selectedItem == "Break In") {
          entryType = 'BI';
        } else {
          entryType = 'BO';
        }
      }
      setState(() {
        isLoading = true;
        loadingText = "Saving..";
      });
      DateTime entTime;
      String netAvailablility="Y";
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        netAvailablility = "Y";
      }else{
        netAvailablility = "N";
      }
      var formatter = new DateFormat('yyyy-MM-dd');
       attendance = Attendance(
        UserNo:
            AppData.current.user.UserNo != 0 ? AppData.current.user.UserNo : 0,
        EntDate: DateTime.parse(formatter.format(selectedTodayDate)),
        EntType: entryType,
        ClientId: AppData.current.user.ClientId,
        EntClientId: selectedVisitType == "Other"
            ? 0
            : selectedClient != null ? selectedClient.ClientId : 0,
        Brcode: AppData.current.user.Brcode,
        EntBrcode: selectedVisitType == "Other" ? "0": selectedClient != null ? selectedClient.Brcode : "0",
        PlaceDesc: ClientController.text!=''?ClientController.text:null,
        CPersonName: contactPersonController.text!= ''? contactPersonController.text : null,
        ContactNo:contactNoController.text!=''?  contactNoController.text: null,
        longitude: longitude,
        latitude: latitude,
        EntTime: selectedTodayDate,
        SysRemark: selectedPurpose.EntNo == null ? 0 : selectedPurpose.EntNo,
        UserRemark:  remarkController.text!=''? remarkController.text:null,
        EntDateTime: selectedTodayDate,
        Address: address != '' || address != null ? address : null,
        UserId: AppData.current.user.UserID,
        IsNet: netAvailablility,
        Selfy: null,
        PassStatus: "U"
       );
      if(imgFile!=null){
        await compressAndGetFile(imgFile).then((value) {
          imgFile = value;
        });
      }
       if (connectionServerMsg != "key_check_internet") {
        User user = AppData.current.user;
        Map<String, dynamic> params = {
          // "user_id": user != null ? user.user_id : "",
        };

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
          // post Circular Image
          if (imgFile != null) {
            await postVisitImage(int.parse(response.body.toString()));
          } else {
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
          }
        } else {
          UserMessageHandler.showMessage(
            _addVisitPageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
          _clearData();
        }
      } else {
      //  SaveAttendance();
        UserMessageHandler.showMessage(
          _addVisitPageGlobalKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } catch (e) {
    //  SaveAttendance();
      UserMessageHandler.showMessage(
        _addVisitPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      isLoading = false;
    });
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
          'ClientId': selectedClient.ClientId.toString(),
          'Brcode': selectedClient.Brcode.toString(),
          UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin": AppData.current.user.RoleNo == 3?"Manager":"Employee",
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
              "Visit successfully saved!",
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
                    MaterialPageRoute(
                      builder: (_) => HomePage(),
                    ),
                  );

                },
              )
            ],
          ),
        );
      } else {
        UserMessageHandler.showMessage(
          _addVisitPageGlobalKey,
          response.body,
          MessageTypes.warning,
        );
      }
    } else {
      UserMessageHandler.showMessage(
        _addVisitPageGlobalKey,
        "Please check your wifi or mobile data is active.",
        MessageTypes.warning,
      );
    }
  }
  void _clearData() {
    setState(() {
      ClientController.text = '';
      contactPersonController.text = '';
      contactNoController.text = '';
      remarkController.text = '';
      _contact = null;
      imgFile = null;
    });
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
            actionText: attendanceType[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedItem = attendanceType[i];
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
                selectedPurposeCategory = purposeCategory[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void showVisitType() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Visit Type",
        ),
        actions: List<Widget>.generate(
          visitType.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: visitType[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedVisitType = visitType[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void showPurpose() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Select Purpose",
        ),
        actions: List<Widget>.generate(
          purpose == null ? 0 : purpose.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: purpose[i].SysRemark ?? "",
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedPurpose = purpose[i];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  Future<List<Purpose>> fetchPurpose() async {
    List<Purpose> purpose;
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
                PurposeUrls.GET_PURPOSE,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _addVisitPageGlobalKey,
            response.body,
            MessageTypes.error,
          );
          purpose = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            purpose = responseData.map((item) => Purpose.fromJson(item)).toList();
          });
          await DBHandler().deletePurpose();
          await DBHandler().savePurpose(purpose);
        }
      } else {
        UserMessageHandler.showMessage(
          _addVisitPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
        purpose = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _addVisitPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );

      purpose = null;
    }
    setState(() {
     // isLoading = false;
    });

    return purpose;
  }
  Future<List<Client>> fetchClient() async {
    List<Client> client;
    try {
      setState(() {
        this.isLoading = true;
        this.loadingText = 'Seaching Location . . .';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          //"latitude": "20.997336",
          // "longitude": "75.555964"
          "latitude": latitude,
          "longitude": longitude,
          "BrCode": AppData.current.user.Brcode
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ClientUrls.GET_VISIT_CLIENT,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _addVisitPageGlobalKey,
            response.body,
            MessageTypes.warning,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            client = responseData.map((item) => Client.fromJson(item)).toList();
          });
          await DBHandler().deleteCurrentBranch(client[0].Brcode);
          await DBHandler().saveBranch(client);
        }
      } else {
        UserMessageHandler.showMessage(
          _addVisitPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        client = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _addVisitPageGlobalKey,
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
  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) {
        Navigator.of(context).pushNamed(routeName);
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
  void showClientbranches() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Select Current Location",
        ),
        actions: List<Widget>.generate(
          clients.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: clients[i].BranchName,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedClient = clients[i];
              });
              Navigator.pop(context);
            },
          ),
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
        _addVisitPageGlobalKey,
        "Not able to detect your location, Please refresh or enable the location.",
        MessageTypes.warning,
      );
    }else{
      fetchClient().then((result) {
        setState(() async {
          this.clients = result;
          this.isLoading = false;
          if (clients != null && clients.length != 0) {
            selectedClient = clients[0];
          }else{
            //  getOfflineCurrentBranch();
          }
        });
      });
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
