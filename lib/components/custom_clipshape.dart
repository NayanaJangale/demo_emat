import 'package:digitalgeolocater/components/custom_shape.dart';
import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class CustomClipShape extends StatelessWidget {
  double height;
  double width;
  double pixelRatio;
  bool large;
  bool medium;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    large = ResponsiveWidget.isScreenLarge(width, pixelRatio);
    medium = ResponsiveWidget.isScreenMedium(width, pixelRatio);
    return Container(
     // height: 150,
      color: Colors.white,
      child: Expanded(
        flex: 1,
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.75,
              child: ClipPath(
                clipper: CustomShapeClipper(),
                child: Container(
                  height:large? height/4 : (medium? height/3.75 : height/3.5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[500], Colors.lightBlueAccent],
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: 0.5,
              child: ClipPath(
                clipper: CustomShapeClipper2(),
                child: Container(
                  height: large? height/4.5 : (medium? height/4.25 : height/4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[500], Colors.lightBlueAccent],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
