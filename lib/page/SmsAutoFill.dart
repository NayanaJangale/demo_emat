import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
export 'package:pin_input_text_field/pin_input_text_field.dart';

class SmsAutoFill {
  static SmsAutoFill _singleton;
  static const MethodChannel _channel = const MethodChannel('sms_autofill');
  final StreamController<String> _code = StreamController.broadcast();

  factory SmsAutoFill() => _singleton ??= SmsAutoFill._();

  SmsAutoFill._() {
    _channel.setMethodCallHandler((method) {
      if (method.method == 'smscode') {
        _code.add(method.arguments);
      }
      return null;
    });
  }

  Stream<String> get code => _code.stream;

  Future<String> get hint async {
    final String version = await _channel.invokeMethod('requestPhoneHint');
    return version;
  }

  Future<void> get listenForCode async {
    await _channel.invokeMethod('listenForCode');
  }

  Future<void> unregisterListener() async {
    await _channel.invokeMethod('unregisterListener');
  }

  Future<String> get getAppSignature async {
    final String appSignature = await _channel.invokeMethod('getAppSignature');
    return appSignature;
  }
}

class PinFieldAutoFill extends StatefulWidget {
  final int codeLength;
  final bool autofocus;
  final String currentCode;
  final Function(String) onCodeSubmitted;
  final Function(String) onCodeChanged;
  final PinDecoration decoration;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextEditingController otpController;

  const PinFieldAutoFill({
    Key key,
    this.keyboardType = const TextInputType.numberWithOptions(),
    this.focusNode,
    this.decoration ,
    this.onCodeSubmitted,
    this.onCodeChanged,
    this.currentCode,
    this.autofocus = false,
    this.codeLength = 6,
    this.otpController
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PinFieldAutoFillState();
  }
}

class _PinFieldAutoFillState extends State<PinFieldAutoFill> with CodeAutoFill {


  @override
  Widget build(BuildContext context) {
    return PinInputTextField(
      pinLength: widget.codeLength,
      decoration: widget.decoration,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      autoFocus: widget.autofocus,
      controller: widget.otpController,
      onSubmit: widget.onCodeSubmitted,
    );
  }

  @override
  void initState() {
   //otpController = TextEditingController(text: '');
    code = widget.currentCode;
    codeUpdated();
    widget.otpController.addListener(() {
      code = widget.otpController.text;
      if (widget.onCodeChanged != null) {
        widget.onCodeChanged(code);
      }
    });
    super.listenForCode();
    super.initState();
  }

  @override
  void didUpdateWidget(PinFieldAutoFill oldWidget) {
    if (widget.currentCode != oldWidget.currentCode || widget.currentCode != code) {
      code = widget.currentCode;
      codeUpdated();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void codeUpdated() {
    widget.otpController.value = TextEditingValue(text: code ?? '');
    if (widget.onCodeChanged != null) {
      widget.onCodeChanged(code ?? '');
    }
  }

  @override
  void dispose() {
    cancel();
    widget.otpController.dispose();
    super.dispose();
  }
}

class PhoneFieldHint extends StatefulWidget {
  final bool autofocus;
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextField child;
  final Color color;

  const PhoneFieldHint({
    Key key,
    this.child,
    this.controller,
    this.autofocus = false,
    this.focusNode,
    this.color
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhoneFieldHintState();
  }
}

class _PhoneFieldHintState extends State<PhoneFieldHint> {
  final SmsAutoFill _autoFill = SmsAutoFill();
  TextEditingController _controller;
  FocusNode _focusNode;
  bool _hintShown = false;

  @override
  void initState() {
    _controller = widget.controller ?? widget.child?.controller ?? TextEditingController(text: '');
    _focusNode = widget.focusNode ?? widget.child?.focusNode ?? FocusNode();
    _focusNode.addListener(() async {
      if (_focusNode.hasFocus && !_hintShown) {
        _hintShown = true;
        scheduleMicrotask(() {
          _askPhoneHint();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ??
        TextField(
          autofocus: widget.autofocus,
          focusNode: _focusNode,
          decoration: InputDecoration(
           icon: IconButton(
             icon: Icon(Icons.phonelink_setup),
             onPressed: () async {
               await _askPhoneHint();
             },
           )
          ),
          controller: _controller,
          keyboardType: TextInputType.phone,
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _askPhoneHint() async {
    String hint = await _autoFill.hint;
    _controller.value = TextEditingValue(text: hint ?? '');
  }
}

class TextFieldPinAutoFill extends StatefulWidget {
  final int codeLength;
  final bool autofocus;
  final FocusNode focusNode;
  final String currentCode;
  final Function(String) onCodeSubmitted;
  final Function(String) onCodeChanged;
  final InputDecoration decoration;
  final bool obscureText;
  final TextStyle style;

  const TextFieldPinAutoFill({
    Key key,
    this.focusNode,
    this.obscureText = false,
    this.onCodeSubmitted,
    this.style,
    this.onCodeChanged,
    this.decoration = const InputDecoration(),
    this.currentCode,
    this.autofocus = false,
    this.codeLength = 6,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TextFieldPinAutoFillState();
  }
}

mixin CodeAutoFill {
  final SmsAutoFill _autoFill = SmsAutoFill();
  String code="";
  StreamSubscription _subscription;

  void listenForCode() {
    _subscription = _autoFill.code.listen((code) {
      this.code = code;
      codeUpdated();
    });
    _autoFill.listenForCode;
  }

  void cancel() {
    _subscription?.cancel();
  }

  void codeUpdated();
}

class _TextFieldPinAutoFillState extends State<TextFieldPinAutoFill> with CodeAutoFill {
  final TextEditingController _textController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      maxLength: widget.codeLength,
      decoration: widget.decoration,
      style: widget.style,
      onSubmitted: widget.onCodeSubmitted,
      onChanged: widget.onCodeChanged,
      keyboardType: TextInputType.numberWithOptions(),
      controller: _textController,
      obscureText: widget.obscureText,
    );
  }

  @override
  void initState() {
    code = widget.currentCode;
    codeUpdated();
    super.listenForCode();
    super.initState();
  }

  @override
  void codeUpdated() {
    _textController.value = TextEditingValue(text: code ?? '');
    if (widget.onCodeChanged != null) {
      widget.onCodeChanged(code ?? '');
    }
  }

  @override
  void didUpdateWidget(TextFieldPinAutoFill oldWidget) {
    if (widget.currentCode != oldWidget.currentCode || widget.currentCode != _getCode()) {
      code = widget.currentCode;
      codeUpdated();
    }
    super.didUpdateWidget(oldWidget);
  }

  String _getCode() {
    return _textController.value.text;
  }

  @override
  void dispose() {
    cancel();
    _textController.dispose();
    super.dispose();
  }
}
