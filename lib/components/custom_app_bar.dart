
import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title, subtitle;

  const CustomAppBar({
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          StringHandlers.capitalizeWords(this.title),
          style: TextStyle(color: Colors.white,fontSize: 18,fontWeight:FontWeight.w500),
        ),
        Text(
          StringHandlers.capitalizeWords(this.subtitle),
          style: TextStyle(color: Colors.white,fontSize: 16,fontWeight:FontWeight.w400),
        ),

      ],
    );
  }
}
