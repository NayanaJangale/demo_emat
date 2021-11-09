
import 'dart:io';

import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/forms/reset_password_form.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  double _height, _width, _pixelRatio;
  bool _large, _medium;
  bool _isLoading;
  String _loadingText;
  String deviceId ="";
  String smsAutoId;
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController userIDController = TextEditingController();

  FocusNode oldPasswordFocusNode = FocusNode();
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
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return CustomProgressHandler(
      isLoading: this._isLoading,
      loadingText: this._loadingText,
      child: Scaffold(
          backgroundColor: Colors.white,
      //    resizeToAvoidBottomPadding: false,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: 5,
                        ),
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
                        Container(
                          alignment: Alignment.topRight,
                          // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                          child:  Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: Text(
                              "Change Password",
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

                Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 30,
                    top: 20,
                  ),
                  child: ResetPasswordForm(
                    oldPasswordCaption: "Current Password",
                    oldPasswordInputAction: TextInputAction.next,
                    oldPasswordFocusNode: this.oldPasswordFocusNode,
                    oldPasswordController: this.oldPasswordController,
                    onOldPasswordSubmitted: (value) {
                      this.oldPasswordFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(this.passwordFocusNode);
                    },
                    passwordCaption: "New Password",
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
                    changeButtonCaption: "Change",
                    cancelButtonCaption:"Cancel",
                    onChangeButtonPressed: () {
                      String valMessage = getValidationMessage();
                      if (valMessage != '') {
                        UserMessageHandler.showMessage(
                          _signupscaffoldKey,
                          valMessage,
                          MessageTypes.warning,
                        );
                      } else {
                        changePassword();
                      }
                    },
                    onCancelButtonPressed: () {
                      _clearData();
                    },
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
  getValidationMessage() {

    if (this.oldPasswordController.text == null || this.oldPasswordController.text == '')
      return "Current Password is mandatory";

    if (this.passwordController.text == null || this.passwordController.text == '') return "New Password is mandatory";

    if (this.confirmPasswordController.text == null || this.confirmPasswordController.text == '')
      return " Confirm  Password is mandatory";

    Pattern pattern = r'^(?=.{6,}$)(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?\W).*$';
    RegExp regex = new RegExp(pattern);

    if (!regex.hasMatch(passwordController.text))
      return "A password containing at least 1 uppercase, 1 lowercase, 1 digit, 1 special character and have a length of at least of 6";

    if (this.oldPasswordController.text == this.passwordController.text)
      return "Old Password and New Password must be different.";

    if (this.passwordController.text != this.confirmPasswordController.text)
      return "New Password and Confirm Password must be different.";

    return '';
  }
  Future<void> changePassword() async {
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
              UserUrls.CHANGE_PARENT_PASSWORD,
          {
            "old_pwd": oldPasswordController.text.toString(),
            "new_pwd": confirmPasswordController.text.toString(),
            "UserNo": AppData.current.user.UserNo.toString(),

          },
        );

        Response response = await post(postChangePasswordUri);
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == HttpStatusCodes.ACCEPTED) {
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
  _clearData(){
    userIDController.text='';
    passwordController.text ='';
    confirmPasswordController.text='';
    oldPasswordController.text='';
  }

}
