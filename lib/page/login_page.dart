import 'dart:convert';
import 'dart:io';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_gradient_button.dart';
import 'package:digitalgeolocater/components/custom_password.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/custom_textfield.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/dashboard_page.dart';
import 'package:digitalgeolocater/page/forgot_password_page.dart';
import 'package:digitalgeolocater/page/sign_up_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _height, _width, _pixelRatio,bottom1;
  bool _large, _medium;
  bool _isLoading;
  String _loadingText;
  DBHandler _dbHandler;
  String smsAutoId;
  TextEditingController userIDController ;
  TextEditingController passwordController;
  FocusNode _userIDFocusNode ;
  FocusNode _passwordFocusNode ;
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String deviceId="";
  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    userIDController = TextEditingController();
    passwordController = TextEditingController();
    _userIDFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _isLoading = false;
    _loadingText = 'Loading . . .';
    _dbHandler = DBHandler();
    _getId().then((res){
      setState(() {
           deviceId = res;
      });

    });

  }

  @override
  Widget build(BuildContext context) {
    bottom1 = MediaQuery.of(context).viewInsets.bottom;
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
       // resizeToAvoidBottomPadding: true,
        key: _scaffoldKey,
        body:  SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/images/banner.png',
                      height: _height/4.0,
                      fit: BoxFit.fill,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: _height/3.5,
                      width: _width/4.0,
                    ),
                  ),

                ),

              ],),
              welcomeTextRow(),
              signInTextRow(),
              form(),
              forgetPassTextRow(),
              SizedBox(height: _height / 15),
              Padding(
                padding: const EdgeInsets.only(left: 80, right: 80),
                child: CustomGradientButton(
                    caption: 'Login',
                    onPressed: (){
                      _login();
                    }
                ),
              ),
              signUpTextRow(),

            ],
          ),
        ),
      ),

    );
  }

  Widget welcomeTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            StringHandlers.capitalizeWords("Employee Attendance"),
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: _large ? 30 : (_medium ? 25 : 20),
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0, right: _width / 12.0, top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            UserTextFormField(),
            SizedBox(
              height: 10.0,
            ),
            passwordTextFormField(),
            SizedBox(height: _height / 40.0),
          ],
        ),
      ),
    );
  }
  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0,top: _width / 40.0),
      child: Row(
        children: <Widget>[
          Text(
            "Sign in to your account..",
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: _large? 20 : (_medium? 17.5 : 15),
            ),
          ),
        ],
      ),
    );
  }
  Widget UserTextFormField() {
    return  CustomTextField(
      keyboardType: TextInputType.text,
      autofoucus: true,
      textEditingController: userIDController,
      focusNode: _userIDFocusNode,
      onFieldSubmitted: (value) {
        this._userIDFocusNode.unfocus();
        FocusScope.of(context)
            .requestFocus(this._passwordFocusNode);
      },
      icon: Icons.phone,
      hint: "User ID",
      validation: (value) {
        if (value.isEmpty) {
          return 'Kindly enter User ID..!';
        }
        return null;
      },
    );
  }
  Widget passwordTextFormField() {
    return CustomPasswordField(
      keyboardType: TextInputType.text,
      textEditingController: passwordController,
      obscureText: true,
      icon: Icons.lock,
      hint: "Password",

      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        this._passwordFocusNode.unfocus();
      },
      validation: (value) {
        if (value.isEmpty) {
          return 'Kindly enter User password..!';
        }
        return null;
      },
    );
  }
  Widget forgetPassTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Forgot password ?",
            style: TextStyle(fontWeight: FontWeight.w400,fontSize: _large? 14: (_medium? 12: 10)),
          ),
          SizedBox(
            width: 5,
          ),
          RawMaterialButton(
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForgotPasswordPage(),
                    // builder: (_) => SubjectsPage(),
                  ),
                );
              },
              constraints: BoxConstraints(),
              padding: EdgeInsets.all(5.0), // optional, in order to add additional space around text if needed
              child: Text(
                "Recover",
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.blue),
              )
          )
        ],
      ),
    );
  }
  Widget signUpTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 120.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Don't have an account ? ",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 14 : (_medium ? 12 : 10)),
          ),
          RawMaterialButton(
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>  SignUpPage(),
                ),
              );
            },
              constraints: BoxConstraints(),
              padding: EdgeInsets.all(5.0), // optional, in order to add additional space around text if needed
              child: Text(
                "Sign up",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                    fontSize: _large ? 19 : (_medium ? 17 : 15)),
              )
          )
        ],
      ),
    );
  }
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _loadingText = 'Validating . . .';
    });

    try {
      String retMsg = await _validateLoginForm(
        userIDController.text,
        passwordController.text,
      );

      if (retMsg == '') {
        User user = await getLocalUser(
          userIDController.text,
          passwordController.text,
        );
        if (user != null) {
          setState(() {
            _isLoading = false;
          });
          user = await _dbHandler.login(user);
          AppData.current.user = await _dbHandler.login(user);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(),
              // builder: (_) => SubjectsPage(),
            ),
          );
        } else {
          _loginUser();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        UserMessageHandler.showMessage(
          _scaffoldKey,
          retMsg,
          MessageTypes.warning,
        );
      }
    } on SocketException {
      UserMessageHandler.showMessage(
        _scaffoldKey,
        'Connection Time Out..! Please try again.',
        MessageTypes.warning,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      UserMessageHandler.showMessage(
        _scaffoldKey,
        'Unable to do login, please check whether your internet connection is active!',
        MessageTypes.warning,
      );
    }
  }
  Future<String> _validateLoginForm(String userID, String userPassword) async {
    if (userID.length == 0) {
      return  "Kindly enter User ID";
    }
    /*if (userID.length != 10 || userID.length < 10) {
      return "Enter Valid Mobile Number.";
    }*/

    if (userPassword.length == 0) {
      return  "Kindly enter User Password";
    }
    if(deviceId == '' ||deviceId == null)
      return "Failed to get Unique Identifier, please contact Software Provider!";

    return "";
  }
  Future<User> getLocalUser(String userID, String userPassword) async {
    try {
      User user;

      await _dbHandler.getUser(userID, userPassword).then(
            (result) {
          user = result;
        },
      );

      return user;
    } catch (e) {
      return null;
    }
  }
  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _loadingText = 'Validating Online . . .';
    });
    try {
      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri getUserDetailsUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.GET_USER,
        ).replace(
          queryParameters: {
          "user_id": userIDController.text,
           "user_pwd": passwordController.text,
            "deviceId" : '50a2049c17e6a01f'//deviceId
          },
        );
        http.Response response = await http.get(getUserDetailsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _scaffoldKey,
            response.body,
            MessageTypes.error,
          );
        } else {
          var data = json.decode(response.body);
          User user = User.fromJson(data);
          user = await _dbHandler.saveUser(user);
          user = await _dbHandler.login(user);
          AppData.current.user = await _dbHandler.login(user);
          AppData.current.user = user;
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(),
            ),
          );
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } on SocketException {
      UserMessageHandler.showMessage(
        _scaffoldKey,
        'Connection Time Out..! Please try again.',
        MessageTypes.warning,
      );
    } catch (e) {
      print(e);
      UserMessageHandler.showMessage(
        _scaffoldKey,
        e.toString(),
        // "Not able to login!",
        MessageTypes.warning,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }
  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

}
