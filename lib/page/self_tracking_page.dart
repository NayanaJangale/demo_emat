import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/location.dart';
import 'package:digitalgeolocater/models/location_time.dart';
import 'package:digitalgeolocater/models/tracking_status.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:workmanager/workmanager.dart';
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      Position _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      debugPrint('location: ${_position.latitude}');
      final coordinates = new Coordinates(_position.latitude, _position.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;

      print("${first.featureName} : ${first.addressLine}");
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      User user = await DBHandler().getLoggedInUser();
      LocationTrack location = LocationTrack(
          longitude: _position.longitude,
          latitude: _position.latitude,
          altitude: _position.altitude,
          Entdate: DateTime.now(),
          EntDateTime: DateTime.now(),
          ClientId: user.ClientId,
          UserNo: user.UserNo,
          Brcode: user.Brcode,
          UserId: user.UserID,
          address: first.addressLine
      );
      Map<String, dynamic> params = {

      };
      Uri fetchStudentAttendanceReportUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            LocationUrls.POST_LOCATION,
      ).replace(
        queryParameters: {
          UserFieldNames.UserNo: user.UserNo.toString(),
          "Brcode": user.Brcode,
          "ClientId": user.ClientId.toString(),
          UserFieldNames.userType:  user.RoleNo == 1? "Admin":user.RoleNo == 3?"Manager":"Employee",
          UserFieldNames.macAddress :  "xxxxx",
          UserFieldNames.SessionUserNo : user.UserNo.toString(),
          UserFieldNames.UserID: user.UserID.toString()
        },
      );

      String jsonBody = json.encode(location);
      http.Response response = await http.post(
        fetchStudentAttendanceReportUri,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
        body: jsonBody,
        encoding: Encoding.getByName("utf-8"),
      );
      //  print(jsonBody);
      if (response.statusCode == HttpStatusCodes.CREATED) {
        /*  UserMessageHandler.showMessage(
              _selfTrackingPageGlobalKey,
              response.body.toString(),
              MessageTypes.information,
            );*/
      } else {
        /* UserMessageHandler.showMessage(
              _selfTrackingPageGlobalKey,
              response.body.toString(),
              MessageTypes.error,
            );*/
      }
    } catch (e) {
      print(e);
    }
    return Future.value(true);
  });
}


class SelfTrackingPage extends StatefulWidget {
  @override
  _SelfTrackingPageState createState() => _SelfTrackingPageState();
}
class _SelfTrackingPageState extends State<SelfTrackingPage> {
  bool isLoading;
  String loadingText;
  DBHandler _dbHandler;
  GlobalKey<ScaffoldState> _selfTrackingPageGlobalKey;
  bool _isTracking = false, isRunning = false;
  int currentTime;
  int previousTime;
  DateTime endDate = DateTime.now();
  DateFormat dateFormat = new DateFormat.Hm();
  List<LocationTime> locationtime = [];
  LocationTime locTime;
  TrackingStatus trackstatus;
  List<LocationTrack> _locationTrack = [];
  int status = 0 ;

  @override
  Future<void> initState()  {
    // TODO: implement initState
    super.initState();
    _selfTrackingPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _dbHandler = DBHandler();
    fetchLocation().then((result) {
      setState(() {
        _locationTrack = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String msgStatus = "-";
    if (isRunning != null) {
      if (isRunning) {
        msgStatus = 'Is running';
      } else {
        msgStatus = 'Is not running';
      }
    }
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _selfTrackingPageGlobalKey,
        appBar: NewGradientAppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: AppData.current.user != null
                ? " Hi " + AppData.current.user.UserName
                : '',
            subtitle: "Let's see your Daily Tracking",
          ),
        ),
        body: _locationTrack != null && _locationTrack.length != 0
            ? ListView.builder(
          itemCount: _locationTrack.length,
          itemBuilder: (BuildContext context, int index) {
            String text =
                'Lat: ${_locationTrack[index].latitude} - Lng: ${_locationTrack[index].longitude}';
            return Container(
              color: Colors.white,
              child: new SizedBox(
                height: 56.0,
                child: new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Expanded(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            new SizedBox(
                              height: 3.0,
                            ),
                            Text(
                              'Time:  ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_locationTrack[index].EntDateTime)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .body2
                                  .copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: new BoxDecoration(
                          color: Colors.green,
                          borderRadius: new BorderRadius.circular(6.0),
                        ),
                        child: new Text(
                          "success",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
            : Padding(
          padding: const EdgeInsets.only(top: 30),
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return CustomDataNotFound(
                description:
                "Click on Green Icon to Start Your Tracking.",
              );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.gps_fixed),
                        onPressed: () {},
                      ),
                      Text("Status: $msgStatus"),
                      MaterialButton(
                          minWidth: 50.0,
                          child: Icon(
                              (_isTracking) ? Icons.pause : Icons.play_arrow,
                              color: Colors.white),
                          color: (_isTracking) ? Colors.red : Colors.green,
                          onPressed: () async {
                            if (_isTracking) {
                              setState(()  {
                                _isTracking = false;
                                isRunning = false;
                                DBHandler().deleteTrackingStatus().then((value) {
                                  trackstatus = TrackingStatus(Status: 0);
                                  _dbHandler.saveTrackingStatus(trackstatus);
                                });
                              });
                              await Workmanager().cancelAll();
                            } else {
                              _showPopUp();

                            }

                            // needed if you intend to initialize in the `main` function
                          })
                    ]))),
        backgroundColor: Colors.white,
      ),
    );
  }
  Future<bool> _showPopUp() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return new CupertinoAlertDialog(
            title: new Text(
              "माहिती ",
              style: TextStyle(fontSize: 16),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  " ट्रॅकिंग सुरु असताना तुम्हाला मोबाइलला चालू ठेवावा लागेल अथवा बॅकग्राऊंड ला ओपन ठेवावा लागेल."),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("ok "),
                onPressed: () {
                  Navigator.pop(context);
                  setState(()  {
                    _isTracking = true;
                    isRunning = true;
                    DBHandler().deleteTrackingStatus().then((value) {
                      trackstatus = TrackingStatus(Status: 1);
                      _dbHandler.saveTrackingStatus(trackstatus);
                    });

                  });
                  Workmanager().initialize(
                    callbackDispatcher,
                    isInDebugMode: true,
                  );
                  // Periodic task registration
                  Workmanager().registerPeriodicTask(
                    "1",
                    "New Location Detected.",
                    frequency: Duration(minutes: 25),
                  );
                },
              ),
            ],
          );
        }) ;
  }

  Future<List<LocationTrack>> fetchLocation() async {
    List<LocationTrack> tracking;
    try {
      setState(() {
        isLoading = true;
        this.loadingText = 'Loading . . .';
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      var dateformatter = new DateFormat('yyyy-MM-dd');
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "EntDate": dateformatter.format(DateTime.now()),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                LocationUrls.GET_LOCATION_TRACK,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _selfTrackingPageGlobalKey,
            response.body,
            MessageTypes.error,
          );
          _dbHandler.getTrackingStatus().then((res) {
            if(res!=null){
              status = res.Status;
            }
            if (status==0){
              setState(() {
                _isTracking = false;
                isRunning = false;
              });

            }else{
              setState(() {
                _isTracking = true;
                isRunning = true;
              });

            }
          });
        } else {
          // print(client);
          setState(() {
            List responseData = json.decode(response.body);
            tracking = responseData
                .map((item) => LocationTrack.fromJson(item))
                .toList();
          });
          _dbHandler.getTrackingStatus().then((res) {
           if(res!=null){
             status = res.Status;
           }
            if (status==0){
              setState(() {
                _isTracking = false;
                isRunning = false;
              });
            }else{
              setState(() {
                _isTracking = true;
                isRunning = true;
              });
            }
          });
        }
      } else {
        UserMessageHandler.showMessage(
          _selfTrackingPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
        tracking = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _selfTrackingPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
      tracking = null;
    }
    setState(() {
      isLoading = false;
    });
    return tracking;
  }
}
