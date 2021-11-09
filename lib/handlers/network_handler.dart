import 'dart:convert';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/internet_connection.dart';
import 'package:digitalgeolocater/models/live_server_urls.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:http/http.dart';
import 'package:connectivity/connectivity.dart';

class NetworkHandler {
  static Uri getUri(String url, Map<String, dynamic> params) {
    try {
      params.addAll({
        UserFieldNames.UserNo: AppData.current.user != null ? AppData.current.user.UserNo.toString() : '',
        UserFieldNames.ClientId :AppData.current.user == null ? "" : AppData.current.user.ClientId.toString(),
        UserFieldNames.Brcode:AppData.current.user == null ? "" : AppData.current.user.Brcode.toString(),
        UserFieldNames.Domain:AppData.current.Domain == null ? "" : AppData.current.Domain.toString(),
        UserFieldNames.userType:AppData.current.user == null  ? "" : AppData.current.user.RoleNo == 1?"Admin":AppData.current.user.RoleNo == 3?"Manager":"Employee",
        UserFieldNames.macAddress :AppData.current.deviceId == null  ?  "" :  AppData.current.deviceId.toString(),
        UserFieldNames.SessionUserNo :AppData.current.user == null  ?  "" :  AppData.current.user.UserNo.toString(),
        UserFieldNames.UserID:AppData.current.user == null ? "" : AppData.current.user.UserID.toString()
      });
      Uri uri = Uri.parse(url);
      return uri.replace(queryParameters: params);
    } catch (e) {
      return null;
    }
  }

  static Future<String> checkInternetConnection() async {
    String status;
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a mobile network.
        status = InternetConnection.CONNECTED;
      } else {
        // I am connected to no network.
        status = InternetConnection.NOT_CONNECTED;
      }
    } catch (e) {
      status = InternetConnection.NOT_CONNECTED;
      status = 'Exception: ' + e.toString();
    }
    return status;
  }
  static Future<String> getServerWorkingUrl() async {
    List<LiveServer> liveServers = [];

    String connectionStatus = await NetworkHandler.checkInternetConnection();
    if (connectionStatus == InternetConnection.CONNECTED) {
      //Uncomment following to test local api
      /* return ProjectSettings.apiUrl;*/

      //Code to get live working api url
      Uri getLiveUrlsUri = Uri.parse(
        LiveServerUrls.serviceUrl,
      );

      Response response = await get(getLiveUrlsUri);
      if (response.statusCode == HttpStatusCodes.OK) {
        var data = json.decode(response.body);
        var parsedJson = data["Data"];

        List responseData = parsedJson;
        liveServers = responseData.map((item) => LiveServer.fromMap(item)).toList();
        if (liveServers.length != 0 && liveServers.isNotEmpty) {
          for (var server in liveServers) {
            Uri checkUrl = Uri.parse(
              server.ipurl,
            );
            Response checkResponse = await get(checkUrl);
            if (checkResponse.statusCode ==  HttpStatusCodes.OK) {
              //return "http://103.19.18.101:81/";
               return server.ipurl;
            }
          }
        }
      } else {
        return "key_check_internet";
      }
    } else {
      return "key_check_internet";
    }
  }
}