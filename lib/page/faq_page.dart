import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:digitalgeolocater/components/custom_cupertino_action_message.dart';
import 'package:digitalgeolocater/components/custom_progress_handler.dart';
import 'package:digitalgeolocater/page/custom_cupertino_icon_action.dart';
import 'package:digitalgeolocater/page/menu_help_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FAQPage extends StatefulWidget {

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  bool isLoading = false;
  String loadingText = 'Loading..';
  final GlobalKey<ScaffoldState> _faqHomeKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    _loadFromAssets();

  }
  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child:Scaffold(
        key: _faqHomeKey,
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
            title:  "Frequently Asked Questions",
            subtitle: "",
          ),
        ),
        body: AppData.current.preferences.getString('localeLang')=='en'? Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
              child: SfPdfViewer.asset(
                  'assets/images/faq.pdf'))
        ):Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
                child: SfPdfViewer.asset(
                    'assets/images/faqMarathi.pdf'))
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
  void _loadFromAssets() async {
    setState(() {
      isLoading = true;
    });

    String  lang = AppData.current.preferences.getString('localeLang') ?? 'en';
    try {
      if (lang =='en'){
            //doc = await PDFDocument.fromAsset('assets/images/faq.pdf');
          }else{
           // doc = await PDFDocument.fromAsset('assets/images/faqMarathi.pdf');
          }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FAQPage()),
                        );
                      });
                    },
                  ),
            ),
          ),
    );
  }
}
