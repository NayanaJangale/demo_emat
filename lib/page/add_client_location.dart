import 'dart:async';
import 'dart:convert';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action_message.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/menu_constants.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/branch.dart';
import 'package:digitalgeolocater/models/leave_type.dart';
import 'package:digitalgeolocater/models/updated_location.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/menu_help_page.dart';
import 'package:digitalgeolocater/page/updated_location_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class AddClientLocationPage extends StatefulWidget {
  @override
  _AddClientLocationPage createState() => _AddClientLocationPage();
}

class _AddClientLocationPage extends State<AddClientLocationPage> {
  GlobalKey<ScaffoldState> _addLocationPageGlobalKey;
  bool isLoading;
  bool islocLoading;
  String loadingText,
      latitude = "",
      longitude = "",altitude;
  FocusNode floorNoFocusNode, rediusFocusNode;
  TextEditingController floorNoController, rediusController;
  LeavesType selectedLeaves;
  List<Branch> clients = [];
  Branch selectedClient;
  Position currentPosition;
  int timer = 120;
  bool canceltimer = false;
  DateTime selectedTodayDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.loadingText = 'Searching Location . . .';
    _addLocationPageGlobalKey = GlobalKey<ScaffoldState>();
    floorNoFocusNode = FocusNode();
    rediusFocusNode = FocusNode();
    floorNoController = TextEditingController();
    rediusController = TextEditingController();
    this.isLoading = true;
    this.islocLoading = true;
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((res){
      latitude = res.latitude.toString();
      longitude = res.longitude.toString();
      altitude=res.altitude.toString();
      this.islocLoading = false;
    });
    fetchClient().then((result) {
      setState(() {
        this.clients = result;
        if (clients != null && clients.length != 0) {
          selectedClient = clients[0];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading || this.islocLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addLocationPageGlobalKey,
        appBar: NewGradientAppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MenuHelpPage(MenuNameConst.UpdateLocation)),
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
            title: "Add Location" ,
            subtitle: "Let\' Update your Branch Location..",
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
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Text(
                              "Select Branch",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .body2
                                  .copyWith(
                                color: Colors.blue[700],
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
                            if(clients==null){
                              UserMessageHandler.showMessage(
                                _addLocationPageGlobalKey,
                                "branches not available",
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
                                      selectedClient!=null?selectedClient.BranchName:'',
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new TextField(
                        focusNode: floorNoFocusNode,
                        controller: floorNoController,
                        maxLength: 1,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Enter Floor No ",
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
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new TextField(
                        focusNode: rediusFocusNode,
                        controller: rediusController,
                        maxLength: 4,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Enter radius of your building Area in Meter.",
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
                        keyboardType: TextInputType.number,
                        maxLines: 1,
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
                                      "Longitude",
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
                                    longitude,
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
                                  /* Icon(
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
                          onTap: () {},
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
                                      "Latitude",
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
                                    latitude,
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
                                  /* Icon(
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
                    _addLocationPageGlobalKey,
                    valMsg,
                    MessageTypes.warning,
                  );
                } else {
                  postBranchLocation();
                }
              },
              child: Container(
                color: Colors.blue[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      "Upload Location",
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
    );
  }
  String getValidationMessage() {
    if (selectedClient == '' || selectedClient == null)
      return "Please Select Branch";

    if (floorNoController.text == '' || floorNoController.text == null)
      return "Please Enter Floor No";

    if (rediusController.text == '' || rediusController.text == null)
      return "Please Enter Redius of your building area.";

    if (longitude == '' || longitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    if (latitude == '' || latitude == null)
      return "Not able to detect your location, Please refresh or enable the location.";

    return '';
  }

  Future<void> postBranchLocation() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Saving . . .';
      });

      UpdateLocation location = UpdateLocation(
          ClientId: selectedClient.ClientId,
          Brcode: selectedClient.brcode,
          FloorNo: int.parse(floorNoController.text.toString()),
          Latitude: latitude,
          Longitude: longitude,
          Altitude: "",
          UserId: AppData.current.user.UserID,
          EntDateTime: selectedTodayDate,
          Radius: int.parse(rediusController.text.toString())
      );

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.current.user;

        Map<String, dynamic> params = {
        };

        Uri saveemployeeleaveUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                LocationUrls.POST_LOCATION,
            params);
        String jsonBody = json.encode(location);

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
            _addLocationPageGlobalKey,
            response.body.toString(),
            MessageTypes.information,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UpdatedLocationPage(),
              // builder: (_) => UpdateClientLocationPage(),
            ),
          );
          _clearData();
        } else {
          UserMessageHandler.showMessage(
            _addLocationPageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
        }
      } else {
        UserMessageHandler.showMessage(
          _addLocationPageGlobalKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _addLocationPageGlobalKey,
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
    floorNoController.text = '';
    rediusController.text = '';
  }

  Future<List<Branch>> fetchClient() async {
    this.loadingText = 'Loading . . .';
    List<Branch> client;
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
          UserMessageHandler.showMessage(
            _addLocationPageGlobalKey,
            response.body,
            MessageTypes.error,
          );

          client = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            client =
                responseData.map((item) => Branch.fromJson(item)).toList();
          });
        }
      } else {
        UserMessageHandler.showMessage(
          _addLocationPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        client = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _addLocationPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );

      client = null;
    }
    setState(() {
      isLoading = false;
    });
    return client;
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

  void showClientbranches() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: "Select Branch",
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

  void finishPage() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) =>
      WillPopScope(
        onWillPop: _onBackPressed,
        child: new CupertinoAlertDialog(
          title: new Text("Alert"),
          content: new Text("Location Timeout.."),
          actions: [
            CupertinoDialogAction(
                 onPressed: (){
                   Navigator.pushReplacement(
                     context,
                     MaterialPageRoute(
                         builder: (context) => HomePage()),
                   );
                 },
                isDefaultAction: true, child: new Text("Close"))

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
}
