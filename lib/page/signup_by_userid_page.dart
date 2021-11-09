
import 'dart:io';
import 'package:digitalgeolocater/components/custom_alert_dialog.dart';
import 'package:digitalgeolocater/components/custom_gradient_button.dart';
import 'package:digitalgeolocater/components/custom_password.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/custom_textfield.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';

class SignUpbyUserIDPage extends StatefulWidget {
  String userID ;

  SignUpbyUserIDPage(this.userID);

  @override
  _SignUpbyUserIDPageState createState() => _SignUpbyUserIDPageState();
}

class _SignUpbyUserIDPageState extends State<SignUpbyUserIDPage> {
  double _height, _width, _pixelRatio,bottom1;
  bool _large, _medium;
  bool _isLoading;
  String _loadingText;
  String deviceId ="";
  String smsAutoId;
  TextEditingController uniqueIDController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode _passwordFocusNode= FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _signupbyUseridscaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Future<void> initState(){
    // TODO: implement initState
    super.initState();
    _getId().then((res){
      setState(() {
        deviceId = res;
      });

    });
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
        //resizeToAvoidBottomPadding: false,
        key: _signupbyUseridscaffoldKey,
        body:  SingleChildScrollView(
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
                            "Sign UP",
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
              // StepOneTextRow(),
              // StepOneTextDesc(),
              StepTwoTextRow(),
              StepTwoTextDesc(),
              form(),
              SizedBox(height: _height / 30),
              Padding(
                padding: const EdgeInsets.only(left: 80, right: 80),
                child: CustomGradientButton(
                    caption: 'Register',
                    onPressed: (){
                      String valMsg = getValidationMessage();
                      if (valMsg != '') {
                        UserMessageHandler.showMessage(
                          _signupbyUseridscaffoldKey,
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
                              UpdateUniqueID();
                            },
                            actionColor: Colors.red,
                            message: "Do you Really want to Registered?",
                            onCancelTapped: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }

                    }
                ),
              ),
              StepThreeTextRow(),
              StepThreeTextDesc(),
              infoTextRow(),
              SizedBox(height: _height / 30),
            ],
          ),
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
  Widget confirmPasswordTextFormField() {
    return CustomPasswordField(
      keyboardType: TextInputType.text,
      textEditingController: confirmPasswordController,
      obscureText: true,
      icon: Icons.lock,
      hint: "Confirm Password",

      focusNode: confirmPasswordFocusNode,
      onFieldSubmitted: (value) {
        this.confirmPasswordFocusNode.unfocus();
      },
      validation: (value) {
        if (value.isEmpty) {
          return 'Kindly enter User password..!';
        }
        return null;
      },
    );
  }


  Widget StepOneTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Step 1: ",
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
  Widget StepOneTextDesc() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.only(left: _width / 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "कृपया आपल्या यूजरआयडी आणि मोबाइल नंबर नोंदणीसाठी प्रशासकाशी संपर्क साधा.",
                //"Please contact to Administrator for Your UserID and Password Registration.",
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
  Widget StepTwoTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Step 2: ",
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
  Widget StepTwoTextDesc() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.only(left: _width / 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                " तुमचा Unique आयडी आणि संकेतशब्द रजिस्टर करण्यासाठी, तुमचा संकेतशब्द  एंटर करा आणि रजिस्टर बटणावर क्लिक करा."
                // "Enter your User ID and Click on Register Button for registered your Unique ID.(You can Register it only ones.)"
                , style: Theme.of(context).textTheme.body2.copyWith(
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
  Widget StepThreeTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Step 3: ",
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
  Widget StepThreeTextDesc() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.only(left: _width / 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "आता, आपण लॉगिनसाठी तयार आहात, चला लॉगिन करूया !",
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
  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0, right: _width / 12.0, top: _height / 30.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
             /*   Padding(
                  padding: const EdgeInsets.only(
                      left: 3.0, right: 3.0),
                  child: UserTextFormField(),
                ),
                SizedBox(height: _height / 30.0),*/
                Padding(
                  padding: const EdgeInsets.only(
                      left: 3.0, right: 3.0),
                  child:  UniqueIDFormField(),
                ),
                SizedBox(height: _height / 30.0),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 3.0, right: 3.0),
                  child: passwordTextFormField(),
                ),
                SizedBox(height: _height / 30.0),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 3.0, right: 3.0),
                  child: confirmPasswordTextFormField(),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget UniqueIDFormField() {
    return  CustomTextField(
      enable: false,
      autofoucus: false,
      textEditingController: uniqueIDController,
      icon: Icons.phone_android,
      hint: deviceId,
    );
  }

  Future<void> UpdateUniqueID() async {
    try {
      setState(() {
        _isLoading = true;
        _loadingText = 'Processing . .';

      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postChangePasswordUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.POST_UNIQUE_ID,
          {

            "UserId": widget.userID.toString() ,
            "deviceId": deviceId,
            "user_pwd" : confirmPasswordController.text.toString()
          },
        );

        http.Response response = await http.post(postChangePasswordUri);
        setState(() {
          _isLoading = false;
          _loadingText = '';
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
                    "Ok",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context,
                        true); //
                    // It worked for me instead of above line
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                )
              ],
            ),
          );
          //TODO: Call login
          UserMessageHandler.showMessage(
            _signupbyUseridscaffoldKey,
            "Unique ID Registerd Successfully..",
            MessageTypes.information,
          );

        } else {
          UserMessageHandler.showMessage(
            _signupbyUseridscaffoldKey,
            response.body,
            MessageTypes.error,
          );
        }
      } else {
        UserMessageHandler.showMessage(
          _signupbyUseridscaffoldKey,
          "Please check your Internet Connection!",
          MessageTypes.warning,
        );
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _signupbyUseridscaffoldKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  String getValidationMessage() {

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

    if( deviceId == '' ||deviceId == null)
      return "Failed to get Unique Identifier, please contact Software Provider!";
    return '';
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
}
