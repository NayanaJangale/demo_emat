import 'dart:convert';

import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_data_not_found.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/http_status_codes.dart';
import 'package:digitalgeolocater/constants/message_types.dart';
import 'package:digitalgeolocater/constants/project_settings.dart';
import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/network_handler.dart';
import 'package:digitalgeolocater/models/calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DatePickerPage extends StatefulWidget {
  @override
  _DatePickerPageState createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> {
  double cHeight;
  bool isLoading;
  String loadingText, _month, _year;
  List<Calender> calender = [];
  GlobalKey<ScaffoldState> _datePickerGlobalKey;
  DateTime currentDate = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime dt = DateTime.now();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _datePickerGlobalKey = GlobalKey<ScaffoldState>();
    _month = dt.month.toString();
    _year = dt.year.toString();
    fetchCalender(_month, _year).then((result) {
      setState(() {
        this.calender = result;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    cHeight = MediaQuery.of(context).size.height;
    CalendarCarousel calendarCarousel = CalendarCarousel<Event>(
      height: cHeight * 0.65,
      iconColor: Theme.of(context).primaryColor,
      headerMargin: EdgeInsets.all(0),
      headerTextStyle: Theme.of(context).textTheme.body1.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
      selectedDateTime: currentDate,
      todayButtonColor: Colors.amber,
      todayTextStyle: Theme.of(context).textTheme.body1.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
      selectedDayTextStyle: TextStyle(
        color: Colors.yellow,
      ),
      onDayPressed: (DateTime date, List<Event> events) {
        setState(() {
          currentDate = date;
        });
      },
      selectedDayBorderColor: Colors.green,
      selectedDayButtonColor: Colors.green,
      weekDayBackgroundColor: Theme.of(context).primaryColor,
      weekdayTextStyle: Theme.of(context).textTheme.body2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
      weekDayPadding: EdgeInsets.only(top: 10, bottom: 10),
      weekDayMargin: EdgeInsets.only(
        top: 1,
        left: 1,
        right: 1,
        bottom: 5,
      ),
      weekDayFormat: WeekdayFormat.short,
      customDayBuilder: (
        /// you can provide your own build function to make custom day containers
        bool isSelectable,
        int index,
        bool isSelectedDay,
        bool isToday,
        bool isPrevMonthDay,
        TextStyle textStyle,
        bool isNextMonthDay,
        bool isThisMonthDay,
        DateTime day,
      ) {
        if (calender.length > 0 &&
            isThisMonthDay &&
            day.day <= calender[calender.length - 1].eDate.day) {
          Calender cal =
              calender.where((item) => item.eDate.day == day.day).elementAt(0);

          Color bgColour, textColour;
          textColour = Colors.white;
          switch (cal.h_Status) {
            case 'H':
              bgColour = Colors.red;
              break;
            default:
              bgColour = Colors.grey[300];
              textColour = Colors.grey[700];
              break;
          }
          if (day.weekday == DateTime.sunday) {
            bgColour = Colors.red;
            textColour = Colors.white;
          }
          return CircleAvatar(
            backgroundColor: bgColour,
            child: Center(
              child: Text(
                day.day.toString(),
                style: Theme.of(context).textTheme.body2.copyWith(
                      color: textColour,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          );
        } else {
          return Center(
            child: Text(
              day.day.toString(),
              style: Theme.of(context).textTheme.body2.copyWith(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          );
        }
      },
      onCalendarChanged: (DateTime date) {
        _month = date.month.toString();
        _year = date.year.toString();
        fetchCalender(_month, _year).then((result) {
          setState(() {
            this.calender = result;
          });
        });
      },
      markedDateIconBuilder: (event) {
        return event.icon;
      },
      todayBorderColor: Colors.green,
    );
    return WillPopScope(
      onWillPop: (){
        String selectedDate = currentDate != null ?
        DateFormat('yyyy-MM-dd')
            .format(currentDate):DateFormat('yyyy-MM-dd')
            .format(DateTime.now());
        Navigator.pop(context, selectedDate);
      },
      child: CustomProgressHandler(
        isLoading: this.isLoading,
        loadingText: this.loadingText,
        child: Scaffold(
          key: _datePickerGlobalKey,
          appBar: NewGradientAppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            gradient: LinearGradient(
                colors: [Colors.green[500], Colors.lightBlueAccent]
            ),
            title: CustomAppBar(
              title: "Select Date For Leave",
              subtitle: "Let\' Select Date for Leave..",
            ),
          ),
          body:  calender != null && calender.length != 0 ? Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 1.0,
                  right: 1.0,
                ),
                child: calendarCarousel,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: RawMaterialButton(
                      onPressed: (){
                        String selectedDate = currentDate != null ?
                        DateFormat('yyyy-MM-dd')
                            .format(currentDate):DateFormat('yyyy-MM-dd')
                            .format(DateTime.now());
                        Navigator.pop(context, selectedDate);
                      },
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(5.0), // optional, in order to add additional space around text if needed
                      child: Text(
                        "Ok",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                            fontSize: 18),
                      )
                  ),
                ),
              )

            ],
          ):Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: "Calender Not Available.",
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Calender>> fetchCalender(String month, String year) async {
    List<Calender> _calender;
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "Year": year,
          "Month": month,
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                CalenderUrls.GET_CALENDER,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          UserMessageHandler.showMessage(
            _datePickerGlobalKey,
            response.body,
            MessageTypes.error,
          );

          _calender = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            _calender =
                responseData.map((item) => Calender.fromJson(item)).toList();
          });
        }
      } else {
        UserMessageHandler.showMessage(
          _datePickerGlobalKey,
          "Please check your wifi or mobile data is active.",
          MessageTypes.warning,
        );

        _calender = null;
      }
    } catch (e) {
      UserMessageHandler.showMessage(
        _datePickerGlobalKey,
        "Not able to fetch data, please contact Software Provider!",
        MessageTypes.warning,
      );

      _calender = null;
    }
    setState(() {
      isLoading = false;
    });
    return _calender;
  }
}
