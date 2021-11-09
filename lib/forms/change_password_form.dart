import 'package:digitalgeolocater/components/custom_gradient_button.dart';
import 'package:digitalgeolocater/components/custom_password.dart';
import 'package:digitalgeolocater/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class ChangePasswordForm extends StatelessWidget {
  final String oldPasswordCaption,
      passwordCaption,
      confirmPasswordCaption,
      changeButtonCaption,
      cancelButtonCaption,
      userIDCaption,
      TransactionType;

  final TextInputAction oldPasswordInputAction,
      passwordInputAction,
      confirmPasswordInputAction,
      userIDInputAction;

  final FocusNode oldPasswordFocusNode,
      passwordFocusNode,
      confirmPasswordFocusNode,
      userIDFocusNode;

  final TextEditingController oldPasswordController,
      passwordController,
      confirmPasswordController,
      userIDController;

  final Function onChangeButtonPressed,
      onPasswordSubmitted,
      onOldPasswordSubmitted,
      onCancelButtonPressed,
      onuserIDSubmitted;

  ChangePasswordForm({
    this.oldPasswordCaption,
    this.passwordCaption,
    this.confirmPasswordCaption,
    this.changeButtonCaption,
    this.cancelButtonCaption,
    this.oldPasswordInputAction,
    this.passwordInputAction,
    this.confirmPasswordInputAction,
    this.oldPasswordFocusNode,
    this.passwordFocusNode,
    this.confirmPasswordFocusNode,
    this.oldPasswordController,
    this.passwordController,
    this.confirmPasswordController,
    this.onChangeButtonPressed,
    this.onPasswordSubmitted,
    this.onOldPasswordSubmitted,
    this.onCancelButtonPressed,
    this.userIDCaption,
    this.onuserIDSubmitted,
    this.userIDController,
    this.userIDFocusNode,
    this.userIDInputAction,
    this.TransactionType
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Visibility(
                visible: TransactionType == 'Registration',
                child: CustomTextField(
                    focusNode: this.userIDFocusNode,
                    autofoucus: false,
                    keyboardType: TextInputType.text,
                    textEditingController: this.userIDController,
                    icon: Icons.supervised_user_circle,
                    hint: this.userIDCaption,
                    onFieldSubmitted:  this.onuserIDSubmitted
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              CustomPasswordField(
                  focusNode: this.passwordFocusNode,
                  keyboardType: TextInputType.text,
                  textEditingController: this.passwordController,
                  icon: Icons.lock_outline,
                  hint: this.passwordCaption,
                  onFieldSubmitted:  this.onPasswordSubmitted
              ),
              SizedBox(
                height: 10.0,
              ),
              CustomPasswordField(
                focusNode: this.confirmPasswordFocusNode,
                keyboardType: TextInputType.text,
                textEditingController: this.confirmPasswordController,
                icon: Icons.lock_outline,
                hint: this.confirmPasswordCaption,

              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomGradientButton(
                        caption: changeButtonCaption,
                        onPressed: onChangeButtonPressed
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: CustomGradientButton(
                        caption: cancelButtonCaption,
                        onPressed: onCancelButtonPressed
                    ),
                  ),
                ],

              )
            ],
          )
        ],
      ),
    );
  }

}
