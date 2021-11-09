import 'package:digitalgeolocater/components/responsive_ui.dart';
import 'package:flutter/material.dart';


class CustomPasswordField extends StatefulWidget {
  final String hint;
  final int maxlength;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData icon;
  final Function validation;
  final Function onFieldSubmitted;
  final FocusNode focusNode;

  CustomPasswordField(
    {this.hint,
      this.maxlength,
      this.textEditingController,
      this.keyboardType,
      this.icon,
      this.validation,
      this.focusNode,
      this.onFieldSubmitted,
      this.obscureText= false,
     });

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _visible = true;
  double _width;

  double _pixelRatio;

  bool large;

  bool medium;

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
        maxLength: widget.maxlength,
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onFieldSubmitted,
        controller: widget.textEditingController,
        validator: widget.validation,
        keyboardType: widget.keyboardType,
        cursorColor: Colors.lightBlue[200],

        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.lightBlue[200], size: 20),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _visible = !_visible;
              });
            },
            child: new Icon(
              _visible ? Icons.visibility : Icons.visibility_off,
              color: Colors.lightBlue[200],
            ),
          ),
          hintText: widget.hint,
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
        obscureText: _visible,
      ),
    );
  }
}
