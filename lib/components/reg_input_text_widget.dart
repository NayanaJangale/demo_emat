import 'package:flutter/material.dart';

class RegTextField extends StatelessWidget {
  final TextInputAction inputAction;
  final TextInputType inputType;
  final TextEditingController controller;
  final FocusNode focus;
  final Function validation, submit;
  final int length;
  final bool isPassword;

  RegTextField({
    this.controller,
    this.focus,
    this.validation,
    this.submit,
    this.length,
    this.inputAction,
    this.inputType,
    this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        validator: validation,
        keyboardType: inputType,
        controller: controller,
        focusNode: focus,
        onFieldSubmitted: submit,
        textInputAction: inputAction,
        maxLength: length,
        cursorColor: Colors.black26,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 0.0),
          counterText: '',
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black26,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black26,
            ),
          ),
        ),
        obscureText: isPassword != null ? isPassword : false,
      ),
    );
  }
}
