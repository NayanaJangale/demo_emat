import 'dart:convert';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/custom_updated_location_item.dart';
import 'package:digitalgeolocater/components/overlay_for_select_page.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/UpdateLocation.dart';
import 'package:digitalgeolocater/page/add_client_location.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class UpdatedLocationPage extends StatefulWidget {
  @override
  _EmployeeLeavesPageState createState() => _EmployeeLeavesPageState();
}

class _EmployeeLeavesPageState extends State<UpdatedLocationPage> {
  bool isLoading;
  String loadingText;
  GlobalKey<ScaffoldState> _updatedLocationPageGlobalKey;
  List<UpdatedLocation> _updatedLocation = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updatedLocationPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading ...';
    fetchUpdatedLocation().then((result) {
      setState(() {
        _updatedLocation = result;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _updatedLocationPageGlobalKey,
        appBar: NewGradientAppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddClientLocationPage()),
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
            title:"Updated Location",
            subtitle: "Let' see your branch updated location",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(3.0),
          child: getBranchUpdatedLocation(),
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
  Widget getBranchUpdatedLocation() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchUpdatedLocation().then((result) {
          setState(() {
            _updatedLocation = result;
          });
        });
      },
      child: _updatedLocation != null && _updatedLocation.length != 0
          ? ListView.builder(
              itemCount: _updatedLocation.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomUpdatedLocationItem(
                  branchName: _updatedLocation[index].BranchName,
                  floorNo: _updatedLocation[index].FloorNo,
                  Redius: _updatedLocation[index].Radius,
                );
              },
            )
          : Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return CustomDataNotFound(
                    description: "It seems, you didn't add any Branch Location.",
                  );
                },
              ),
            ),
    );
  }

  Future<List<UpdatedLocation>> fetchUpdatedLocation() async {
    List<UpdatedLocation> updatedLocation = [];

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
                UpdatedLocationUrls.GET_UPDATED_LOCATION,
            params);

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _updatedLocationPageGlobalKey,
            response.body.toString(),
            MessageTypes.warning,
          );
          bool locationOverlay = AppData.current.preferences.getBool('location_overlay') ?? false;
          if (!locationOverlay) {
            AppData.current
                .preferences
                .setBool("location_overlay", true);
            _showOverlay(context);
          }

        } else {
          List responseData = json.decode(response.body);
          updatedLocation = responseData
              .map(
                (item) => UpdatedLocation.fromJson(item),
              )
              .toList();

          bool locationOverlay = AppData.current.preferences.getBool('location_overlay') ?? false;
          if (!locationOverlay) {
            AppData.current
                .preferences
                .setBool("location_overlay", true);
            _showOverlay(context);
          }
        }

      } else {
        UserMessageHandler.showMessage(
          _updatedLocationPageGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _updatedLocationPageGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });

    return updatedLocation;
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
         "Update Branch Location from here."),
    );
  }
}
