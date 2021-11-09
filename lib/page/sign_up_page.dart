
import 'dart:convert';
import 'package:digitalgeolocater/components/custom_gradient_button.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/components/custom_textfield.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:digitalgeolocater/page/SmsAutoFill.dart';
import 'package:digitalgeolocater/page/confirm_otp_page.dart';
import 'package:digitalgeolocater/page/login_page.dart';
import 'package:digitalgeolocater/page/signup_by_userid_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  double _height, _width, _pixelRatio;
  bool _large, _medium;
  bool _isLoading;
  String _loadingText;
  String deviceId ="",  appSignature;
  String smsAutoId,contactNo;
  TextEditingController userIDController = TextEditingController();
  FocusNode _userIDFocusNode = FocusNode();
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _signupscaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Future<void> initState(){
    // TODO: implement initState
    super.initState();
    _isLoading = false;
    _loadingText = 'Loading . . .';

    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature!= null? signature:"";
        print("App signature: " + appSignature);
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
          //resizeToAvoidBottomPadding: true,
          key: _signupscaffoldKey,
          body:   SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(children: <Widget>[
                  Container(
                    // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                    child: Image.asset(
                      'assets/images/banner.png',
                      height: _height/4.0,
                      fit: BoxFit.fill,
                      // fit: BoxFit.fill,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topRight,
                          // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                          child:  Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Sign up",
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
                //welcomeTextRow(),
                welcomeTextRow(),
                StepOneTextRow(),
                StepOneTextDesc(),
                StepTwoTextRow(),
                StepTwoTextDesc(),
                form(),
                SizedBox(height: _height / 30),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 15, bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: CustomGradientButton(
                            caption: 'Proceed',
                            onPressed: (){
                              String valMsg = getValidationMessage();

                              if (valMsg != '') {
                                UserMessageHandler.showMessage(
                                  _signupscaffoldKey,
                                  valMsg,
                                  MessageTypes.warning,
                                );
                              } else {
                                fetchConfigation();
                              }
                            }
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: CustomGradientButton(
                            caption: 'Cancel',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _height / 30),
              ],
            ),
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
          Expanded(
            child: Text(
              "Sign In to your account.",
              style: Theme.of(context)
                  .textTheme
                  .body2
                  .copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: _large ? 30 : (_medium ? 20 : 16),
              ),
            ),
          ),
        ],
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
  Widget UserTextFormField() {
    return PhoneFieldHint(
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone, color: Colors.lightBlue[200], size: 20),
          hintText: "Mobile No",
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
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
        cursorColor: Colors.lightBlue[200],
        controller: userIDController,
        focusNode: _userIDFocusNode,
        onSubmitted: (value) {
          this._userIDFocusNode.unfocus();
        },
        style: Theme.of(context).textTheme.body2.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16
        ),
      ),
    )  /*CustomTextField(
      focusNode: _userIDFocusNode,
      autofoucus: false,
      keyboardType: TextInputType.number,
      textEditingController: userIDController,
      icon: Icons.phone,
      hint: " Mobile Number",
      onFieldSubmitted: (value) {
        this._userIDFocusNode.unfocus();
      },
    )*/;
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
                "कृपया आपल्या यूजरआयडी आणि मोबाइल क्रमांक नोंदणीसाठी प्रशासकाशी संपर्क साधा.",
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
               // " ओटीपी पाठविण्यासाठी"
                    " आपला नोंदणीकृत मोबाइल क्र. एंटर करा."
                //आणि तुमचा Unique आयडी रजिस्टर करण्यासाठी रजिस्टर बटणावर क्लिक करा. (तुम्ही फक्त त्यास एकदाच रजिस्टर करू शकता.)
                // "Enter your User ID and Click on Register Button for registered your Unique ID.(You can Register it only ones.)"
                ,
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
            // UniqueIDFormField(),
            SizedBox(height: _height / 30.0),
            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: UserTextFormField()),
          ],
        ),
      ),
    );
  }
  Future<void> _sendOTP(String contNO) async {

    try {
      setState(() {
        _isLoading = true;
        _loadingText = 'Processing . .';

      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postGenerateOtpUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.GENERATE_OTP,
          {
            "UserId": contNO,
            'TransactionType': "Registration",
            'appSignature': appSignature,
            'RegenerateSMS': 'false',
            //'OldSMSAutoID': null,

          },
        );
        this._userIDFocusNode.unfocus();
        http.Response response = await http.post(postGenerateOtpUri);
        setState(() {
          _isLoading = false;
          _loadingText = '';
        });

        if (response.statusCode == HttpStatusCodes.CREATED) {
          //TODO: Call login
          var sSmsAutoID = json.decode(response.body);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmOTPPage(
                smsAutoID: sSmsAutoID,
                UserId: contNO,
                TrasactionType: "Registration",
              ),
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
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }
  String getValidationMessage() {
    if (userIDController.text.toString().contains("+91")) {
      if (userIDController.text.toString().length != 13) {
        return "Enter Valid Mobile Number.";
      }
    }
    if (!userIDController.text.toString().contains("+91")) {
      if (userIDController.text.toString().length != 10) {
        return "Enter Valid Mobile Number.";
      }
    }

    return '';
  }
  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
  Future<void> fetchConfigation() async {
    try {
      setState(() {
        _isLoading = true;
        _loadingText = 'Processing . .';
      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {

        contactNo = userIDController.text.toString().replaceAll(" ", "");
        if (contactNo.startsWith("+91")) {
          contactNo = contactNo.replaceFirst("+91", '');
        }
        if (contactNo.startsWith("0", 0)) {
          contactNo = contactNo.replaceFirst("0", '');
        }
        contactNo = contactNo.replaceAll("-", '');

        Uri postGenerateOtpUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.GET_REGISTRATION_CONFIG,
          {
            "UserId": contactNo,

          },
        );
        this._userIDFocusNode.unfocus();
        http.Response response = await http.get(postGenerateOtpUri);
        setState(() {
          _isLoading = false;
          _loadingText = '';
        });
//kishore
        if (response.statusCode == HttpStatusCodes.OK) {
          //TODO: Call login
          var configName = json.decode(response.body);
            var configvalue = configName[0]['Evalue'];
            if (configvalue == 'Y'){
              _sendOTP(contactNo);

          }else{
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpbyUserIDPage(
                  contactNo
              ),
            ),
          );
          }

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
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
