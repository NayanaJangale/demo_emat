import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:flutter/material.dart';


class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData icon;
  double _width;
  double _pixelRatio;
  bool large;
  bool medium;
  bool enable;
  bool autofoucus;
  final int maxLength;
  final Function onFieldSubmitted;
  final FocusNode focusNode;
  final Function validation;

  CustomTextField(
    {this.hint,
      this.textEditingController,
      this.keyboardType,
      this.icon,
      this.autofoucus,
      this.validation,
      this.focusNode,
      this.onFieldSubmitted,
      this.obscureText= false,
      this.enable,
      this.maxLength,
     });

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    large =  ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    medium=  ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: large? 12 : (medium? 10 : 8),
      child: TextFormField(
        maxLength: maxLength,
        focusNode: focusNode,
        autofocus: autofoucus,
        enabled: enable,
        onFieldSubmitted: onFieldSubmitted,
        controller: textEditingController,
        validator: validation,
        keyboardType: keyboardType,
        cursorColor: Colors.lightBlue[200],
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.lightBlue[200], size: 20),
          hintText: hint,
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
      ),
    );
  }
}
