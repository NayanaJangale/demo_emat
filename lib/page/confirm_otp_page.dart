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
import 'package:digitalgeolocater/page/confirm_password_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConfirmOTPPage extends StatefulWidget {
  final String  smsAutoID, UserId, TrasactionType;

  ConfirmOTPPage({
    this.smsAutoID,
    this.UserId,
    this.TrasactionType
  });

  @override
  _ConfirmOTPPageState createState() => _ConfirmOTPPageState();
}

class _ConfirmOTPPageState extends  State<ConfirmOTPPage> with CodeAutoFill  {
  bool isLoading = false;
  String loadingText;
  String smsAutoID,appSignature;
  int cnt = 1;

  TextEditingController otpController;
  FocusNode otpFocusNode;
  double _height, _width, _pixelRatio;
  bool _large, _medium;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String otpCode = " ";

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature!= null ? signature:"";
      });
    });
    listenForCode();
    listning();
    otpController = TextEditingController();
    otpFocusNode = FocusNode();
    smsAutoID = widget.smsAutoID;
  }
  Future<void> listning() async {
    await SmsAutoFill().listenForCode;
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
         backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(children: <Widget>[
                Container(
                  // margin: EdgeInsets.only(top: _large? _height/20 : (_medium? _height/20 : _height/15)),
                  child: Image.asset(
                    'assets/images/banner.png',
                    height: _height/3.5,
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
                            "Confirm OTP",
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
              StepThreeTextRow(),
              SizedBox(height: _height / 50),
              signInTextRow(),
              form(),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 15, bottom: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomGradientButton(
                        caption: 'Verify',
                        onPressed: ()/* {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmPasswordPage(
                                    smsAutoId: smsAutoID,
                                  ),
                                ),
                              );
                            }*/async {
                          String val = getValidation();
                          if(val==""){
                            await _validateOtp();
                          }else{
                            UserMessageHandler.showMessage(
                              _scaffoldKey,
                              val,
                              MessageTypes.warning,
                            );
                          }

                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: CustomGradientButton(
                          caption: 'Resend',
                          onPressed: () {
                            _resendOTP();
                          }
                      ),
                    ),
                  ],
                ),
              ),
              //forgetPassTextRow(),
            ],
          ),
        )
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
              "Looks like you're new here!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _large ? 25 : (_medium ? 20 : 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "नोंदणीकृत मोबाइल नंबरवर पाठविलेला ओटीपी प्रविष्ट करा .ओटीपी 10 मिनिटांसाठी वैध आहे.",
              style:  Theme.of(context).textTheme.body2.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w400,
                fontSize: _large ? 20 : (_medium ? 18 : 16),)
            ),
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
        child: Column(
          children: <Widget>[
            otpTextFormField(),
            SizedBox(height: _height / 40.0),
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
  Widget otpTextFormField() {
    return /*PinFieldAutoFill(
      autofocus: true,
      decoration: BoxLooseDecoration(
        strokeColorBuilder:
        PinListenColorBuilder(Colors.cyan, Colors.green),
      ),
      currentCode: otpCode,
      otpController: otpController,
    );*/CustomTextField(
      autofoucus: true,
      keyboardType: TextInputType.number,
      textEditingController: otpController,
      icon: Icons.refresh,
      hint: "OTP",
      validation: (value) {
        if (value.isEmpty) {
          return 'Enter OTP';
        }
        return null;
      },
    );
  }


  Future<void> _resendOTP() async {
    if (cnt < 3) {
      setState(() {
        isLoading = true;
        loadingText = 'Resending OTP..';
        otpController.text = '';
      });

      try {
        String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
        if (connectionServerMsg != "key_check_internet") {
          Uri postResendOTPUri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                UserUrls.GENERATE_OTP,
          ).replace(
            queryParameters: {
              "UserId": widget.UserId.toString(),
              'TransactionType': widget.TrasactionType,
              'appSignature': appSignature,
              'RegenerateSMS': 'true',
            },
          );

          http.Response response = await http.post(postResendOTPUri);
          if (response.statusCode != HttpStatusCodes.CREATED) {
            UserMessageHandler.showMessage(
              _scaffoldKey,
              response.body.toString(),
              MessageTypes.error,
            );
          } else {
            setState(() {
              cnt++;
              smsAutoID = json.decode(response.body);
            });
            UserMessageHandler.showMessage(
              _scaffoldKey,
              'Please enter the OTP sent to your Mobile No.',
              MessageTypes.error,
            );
          }
        } else {
          UserMessageHandler.showMessage(
            _scaffoldKey,
            'Please check your Internet Connection!',
            MessageTypes.warning,
          );
        }
      } catch (e) {
        UserMessageHandler.showMessage(
          _scaffoldKey,
          'Not able to fetch data, please contact Software Provider!',
          MessageTypes.warning,
        );
      }
    } else {
      UserMessageHandler.showMessage(
        _scaffoldKey,
        'Frequent OTP requests detected. Cannot send OTP. Please try after sometime.',
        MessageTypes.error,
      );
    }

    setState(() {
      isLoading = false;
    });
  }
  Future<void> _validateOtp() async {
    try {
      if (otpController.text.length == 6) {
        setState(() {
          isLoading = true;
          loadingText = 'Validating OTP . .';
        });

        String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
        if (connectionServerMsg != "key_check_internet") {
          Uri postValidateOtpUri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                UserUrls.VALIDATE_OTP,
          ).replace(
            queryParameters: {
              'SMSAutoID': smsAutoID.toString(),
              'OTP': otpController.text.toString(),
              'UserId':widget.UserId
            },
          );

          http.Response response = await http.post(postValidateOtpUri);
          setState(() {
            isLoading = false;
            loadingText = '';
          });

          if (response.statusCode != HttpStatusCodes.CREATED) {
            UserMessageHandler.showMessage(
              _scaffoldKey,
              response.body.toString(),
              MessageTypes.error,
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmPasswordPage(
                  smsAutoId: smsAutoID,
                  userID: widget.UserId,
                  TransactionType: widget.TrasactionType,
                ),
              ),
            );
          }
        } else {
          UserMessageHandler.showMessage(
            _scaffoldKey,
            'Please check your Internet Connection!',
            MessageTypes.warning,
          );
        }
      } else {
        UserMessageHandler.showMessage(
          _scaffoldKey,
          'Please enter the OTP received on your Mobile No.',
          MessageTypes.error,
        );
      }
    } catch (e) {
      print(e);
      UserMessageHandler.showMessage(
        _scaffoldKey,
        'Not able to fetch data, please contact Software Provider!',
        MessageTypes.warning,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  String getValidation(){
    if(otpController.text=="")
      return "Enter OTP";
    return "";
  }
}
