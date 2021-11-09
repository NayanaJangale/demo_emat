import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class MyLocationPage extends StatefulWidget {
  @override
  _MyLocationPage createState() => _MyLocationPage();
}

class _MyLocationPage extends State<MyLocationPage> {
  GlobalKey<ScaffoldState> _myLocationPageGlobalKey;
  bool isLoading;
  bool islocLoading;
  String loadingText,address ="",altitude,
      latitude = "",
      longitude = "";
  Position currentPosition;
  int timer = 120;
  bool canceltimer = false;
  DateTime selectedTodayDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.loadingText = 'Loading . . .';
    _myLocationPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = true;
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((res){
      latitude = res.latitude.toString();
      longitude = res.longitude.toString();
      altitude=res.altitude.toString();
      this.islocLoading = false;
    });

  }


  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading ,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _myLocationPageGlobalKey,
        appBar: NewGradientAppBar(
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: "Contact Us" ,
            subtitle: '',
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Employee Attendance ",
                    style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                Text(
                  "Design and Develop by ",
                  style: Theme.of(context).textTheme.body2.copyWith(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.normal,
                      fontSize: 16
                  ),
                ),
                new Image.asset(
                  'assets/images/board.jpg',
                  width: 200,
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "All rights reserved  ",
                    style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "http://softaidcomputers.com/",
                    style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "0257-2236620 ",
                    style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "If any issue contact on,   ",
                    style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                        fontSize: 16
                    ),
                  ),
                ),  Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "0257-2241223 ",
                    style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "0257-2240347 ",
                    style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ),


              ],
            ),
          ),
        )/*Column(
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
                                  *//* Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),*//*
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
                                  *//* Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),*//*
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                        top: 10.0,
                      ),
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
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                 "Address - ${address}" ,
                                  style:
                                  Theme.of(context).textTheme.body2.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                    *//*welcomeTextRow(),
                    StepOneTextRow(),
                    StepOneTextDesc(),*//*

                  ],
                ),
              ),
            ),

          ],
        )*/,
      ),
    );
  }

}
