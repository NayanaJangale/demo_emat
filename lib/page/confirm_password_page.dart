
import 'dart:convert';
import 'dart:io';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_alert_dialog.dart';
import 'package:digitalgeolocater/components/custom_clipshape.dart';
import 'package:digitalgeolocater/components/custom_gradient_button.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/custom_textfield.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/forms/change_password_form.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:http/http.dart';

class ConfirmPasswordPage extends StatefulWidget {
  final String smsAutoId,userID,TransactionType;

  ConfirmPasswordPage({
    this.smsAutoId,
    this.userID,
    this.TransactionType
  });
  @override
  _ConfirmPasswordPageState createState() => _ConfirmPasswordPageState();
}

class _ConfirmPasswordPageState extends State<ConfirmPasswordPage> {
  double _height, _width, _pixelRatio;
  bool _large, _medium;
  bool _isLoading;
  String _loadingText;
  String deviceId ="";
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController userIDController = TextEditingController();

  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode userIDFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _signupscaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Future<void> initState(){
    // TODO: implement initState
    super.initState();
    _isLoading = false;
    _loadingText = 'Loading . . .';
    _getId().then((res){
      setState(() {
        deviceId = res;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: CustomProgressHandler(
          isLoading: this._isLoading,
          loadingText: this._loadingText,
        child: Scaffold(
          backgroundColor: Colors.white,
         // resizeToAvoidBottomPadding: true,
          key: _signupscaffoldKey,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(children: <Widget>[
                  Container(
                    // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                    child: Image.asset(
                      'assets/images/banner.png',
                      height: _height/4.0,
                      fit: BoxFit.fill,
                      //fit: BoxFit.fill,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child:   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topRight,
                          // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                          child:  Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Confirm Password",
                              //"Log in to get started",
                              style: Theme.of(context)
                                  .textTheme
                                  .body2
                                  .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: _large ? 30 : (_medium ? 18 : 20),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: _height/3.5,
                            width: _width/4.0,
                          ),
                        ),
                      ],
                    ),
                  )
                ],),
                StepFourTextRow(),
                SizedBox(height: _height / 100),
                StepFourTextDescRow(),
                Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 30,
                    top: 0,
                  ),
                  child: ChangePasswordForm(
                    TransactionType : widget.TransactionType,
                    userIDCaption: "Device ID -" + deviceId,
                    userIDInputAction: TextInputAction.next,
                    userIDFocusNode: this.userIDFocusNode,
                    userIDController: this.userIDController,

                    passwordCaption: "Password",
                    passwordInputAction: TextInputAction.next,
                    passwordFocusNode: this.passwordFocusNode,
                    passwordController: this.passwordController,
                    onPasswordSubmitted: (value) {
                      this.passwordFocusNode.unfocus();
                      FocusScope.of(context)
                          .requestFocus(this.confirmPasswordFocusNode);
                    },
                    confirmPasswordCaption: "Confirm Password",
                    confirmPasswordInputAction: TextInputAction.done,
                    confirmPasswordFocusNode: this.confirmPasswordFocusNode,
                    confirmPasswordController: this.confirmPasswordController,
                    changeButtonCaption: "Confirm",
                    cancelButtonCaption:"Cancel",
                    onChangeButtonPressed: () {
                      userIDController.text = deviceId;
                      String valMessage = getValidationMessage();
                      if (valMessage != '') {
                        UserMessageHandler.showMessage(
                          _signupscaffoldKey,
                          valMessage,
                          MessageTypes.warning,
                        );
                      } else {
                        if(widget.TransactionType =='Registration'){
                          _registerUser();
                        }else{
                          _resetPassword();
                        }
                      }
                    },
                    onCancelButtonPressed: () {
                      _clearData();
                    },
                  ),
                ),
                infoTextRow(),
              ],
            ),
          )
        ),

      ),
    );
  }
  Widget StepFourTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Step 4: ",
            //"Log in to get started",
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: _large ? 30 : (_medium ? 20 : 16),
            ),
          ),
        ],
      ),
    );
  }
  Widget StepFourTextDescRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.only(left: _width / 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "संकेतशब्द प्रविष्ट करा आणि नोंदणीसाठी संकेतशब्द पुष्टी करा",
                //"Now, You are Ready For Login, Let's Go!",
                style: Theme.of(context).textTheme.body2.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  fontSize: _large ? 20 : (_medium ? 18 : 16),),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTextRow() {
    return GestureDetector(
      onTap: (){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: _height / 40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Back to Login Page!",
              style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w400, fontSize: _large? 20: (_medium? 18: 16)),
            ),
          ],
        ),
      ),
    );
  }

  getValidationMessage() {
    if (passwordController.text.length == 0 || confirmPasswordController.text.length==0){
      return "Password and confirm password should be mandatory";

    }
    Pattern pattern = r'^(?=.{6,}$)(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?\W).*$';
    RegExp regex = new RegExp(pattern);

    if (!regex.hasMatch(passwordController.text))
      return 'A password containing at least 1 uppercase, 1 lowercase, 1 digit, 1 special character and have a length of at least of 6';


    if (passwordController.text != confirmPasswordController.text) {
      return 'Password and Confirm Password must be same.';
    }
    return "";
  }
  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _loadingText = "Processing..";
    });
    try {

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postChangePasswordUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.POST_PASSWORD,
          {
            "Password": confirmPasswordController.text.toString(),
            "deviceId": deviceId.toString(),
            'UserId': widget.userID.toString(),
            'SMSAutoID': widget.smsAutoId.toString(),

          },
        );

        Response response = await post(postChangePasswordUri);
        setState(() {
          _isLoading = false;
        });

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
                    Navigator.pop(context,
                        true); // It worked for me instead of above line
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                )
              ],
            ),
          );

        } else {
          UserMessageHandler.showMessage(
            _signupscaffoldKey,
            response.body,
            MessageTypes.error,
          );
        }
      } else {
        UserMessageHandler.showMessage(
          _signupscaffoldKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _signupscaffoldKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _loadingText = "Processing..";
    });
    try {

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postChangePasswordUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.RESET_PASSWORD,
          {
            "NewPassword": confirmPasswordController.text.toString(),
            'UserId': widget.userID.toString(),
            'SMSAutoID': widget.smsAutoId.toString(),

          },
        );

        Response response = await post(postChangePasswordUri);
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == HttpStatusCodes.OK) {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
               response.body,
                style: TextStyle(fontSize: 16),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context,
                        true); // It worked for me instead of above line
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                )
              ],
            ),
          );

        } else {
          UserMessageHandler.showMessage(
            _signupscaffoldKey,
            response.body,
            MessageTypes.error,
          );
        }
      } else {
        UserMessageHandler.showMessage(
          _signupscaffoldKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _signupscaffoldKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }
  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
  _clearData(){
    userIDController.text='';
    passwordController.text ='';
    confirmPasswordController.text='';
  }

}
