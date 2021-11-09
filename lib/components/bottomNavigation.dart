import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/page/dashboard_page.dart';
import 'package:digitalgeolocater/page/home_page.dart';
import 'package:digitalgeolocater/page/report_page.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarApp extends StatelessWidget {
  final int bottomNavigationBarIndex;
  final BuildContext context;
  final isVisible = false;
  //  ndkVersion "21.0.6113669"

  const BottomNavigationBarApp(this.context, this.bottomNavigationBarIndex);

  void onTabTapped(int index) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<Null>(builder: (BuildContext context) {
        // return (index == 1) ? Container() : Container();
        return (index == 0) ? DashboardPage() : (index == 1) ? HomePage() : ReportPage(); // Home();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: bottomNavigationBarIndex,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      selectedLabelStyle: TextStyle(color: Colors.green[700]),
      selectedItemColor: Colors.green[700],
      unselectedFontSize: 10,
      items: bottomlist(),
      onTap: onTabTapped,
    );
  }

  List<BottomNavigationBarItem> bottomlist() {
    List<BottomNavigationBarItem> list = [];
    list.add(new BottomNavigationBarItem(
      icon: Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Icon(
            Icons. dashboard,
            color: (bottomNavigationBarIndex == 0)
                ? Colors.green[700]
                : Colors.grey,
          )),
      label:"Dashboard",
    ));
    list.add(new BottomNavigationBarItem(
      icon: Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Icon(
            Icons.home,
            color: (bottomNavigationBarIndex == 1)
                ? Colors.green[700]
                : Colors.grey,
          )),
      label: "Home",
    ));
    list.add(new BottomNavigationBarItem(
      icon: Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Icon(
            Icons.view_list,
            color: (bottomNavigationBarIndex == 2)
                ? Colors.green[700]
                : Colors.grey,
          ) /*Image.asset(
              'assets/images/home.png',
              color: (bottomNavigationBarIndex == 0)
                  ? Colors.green[700]
                  : Colors.grey,
            ),*/
      ),
      label: "Report",
    ));
    return list;
  }
}
