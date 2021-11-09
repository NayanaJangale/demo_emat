import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action_message.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/constants/menu_constants.dart';
import 'package:digitalgeolocater/page/custom_cupertino_icon_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MenuHelpPage extends StatefulWidget {
  String menuName;

  MenuHelpPage(this.menuName);

  @override
  _MenuHelpPageState createState() => _MenuHelpPageState();
}

class _MenuHelpPageState extends State<MenuHelpPage> {
  bool isLoading = false;
  String loadingText = 'Loading..';
  final GlobalKey<ScaffoldState> _menuHelpKey = new GlobalKey<ScaffoldState>();
  //PDFDocument doc;
  String lang;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lang = AppData.current.preferences.getString('localeLang') ?? 'en';

  }
  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child:Scaffold(
        key: _menuHelpKey,
        appBar: NewGradientAppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.language),
              onPressed: () {
                showLocaleList();

              },
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          gradient: LinearGradient(
              colors: [Colors.green[500], Colors.lightBlueAccent]),
          title: CustomAppBar(
            title: widget.menuName + "  Help ",
            subtitle: "",

          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(3.0),
          child: widget.menuName == MenuNameConst.UpdateLocation ?_loadUpdateLocationHelp():
          widget.menuName == MenuNameConst.Attendance ?  _loadAttendanceHelp() : _loadVisitHelp()
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
  Widget _loadUpdateLocationHelp() {
    return lang =='en'
      ? Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
              child: SfPdfViewer.asset(
                  'assets/images/updateLocHelp.pdf'))
      ) :
      Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
              child: SfPdfViewer.asset(
                  'assets/images/updateLocHelpMarathi.pdf'))
      );
    }
  Widget _loadVisitHelp() {
    return lang =='en'
        ?Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
            child: SfPdfViewer.asset(
                'assets/images/addvisitHelp.pdf'))
    ) :
    Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
            child: SfPdfViewer.asset(
                'assets/images/addvisitHelpMarathi.pdf'))
    );
  }
  Widget _loadAttendanceHelp()  {
    return lang =='en'
        ?Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
            child: SfPdfViewer.asset(
                'assets/images/attendanceHelp.pdf'))
    ) :
    Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
            child: SfPdfViewer.asset(
                'assets/images/attendanceHelp.pdf'))
    );
  }
  void showLocaleList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) =>
          CupertinoActionSheet(
            message: CustomCupertinoActionMessage(
              message: "Select Language",
            ),
            actions: List<Widget>.generate(
              projectLocales.length,
                  (index) =>
                  CustomCupertinoIconAction(
                    isImage: true,
                    imagePath: projectLocales[index].image,
                    actionText: projectLocales[index].title,
                    actionIndex: index,
                    onActionPressed: () {
                      setState(() async {
                        AppData.current.preferences
                            .setString('localeLang', projectLocales[index].lanaguageCode);
                        Navigator.pop(context);

                        if(widget.menuName == MenuNameConst.UpdateLocation){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuHelpPage(widget.menuName)),
                          );
                        }else if (widget.menuName == MenuNameConst.Attendance){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuHelpPage(widget.menuName)),
                          );
                        }else{
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuHelpPage(widget.menuName)),
                          );
                        }
                      });
                    },
                  ),
            ),
          ),
    );
  }
}

class ProjectLocale {
  final String lanaguageCode, title, image;
  ProjectLocale({this.title, this.lanaguageCode, this.image});
}

List<ProjectLocale> projectLocales = [
  new ProjectLocale(
      title: 'English', lanaguageCode: 'en', image: 'assets/images/us.jpg'),
  new ProjectLocale(
      title: 'मराठी', lanaguageCode: 'mr', image: 'assets/images/india.png'),
];
