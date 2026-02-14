import 'package:flutter/material.dart';

import 'otp_digit_field.dart';

class OTPFields extends StatefulWidget {
  final int length;
  final Function(String) onOTPComplete;

  const OTPFields({
    super.key,
    required this.length,
    required this.onOTPComplete,
  });

  @override
  State<OTPFields> createState() => _OTPFieldsState();
}

class _OTPFieldsState extends State<OTPFields> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late String otp;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
    otp = '';
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return OTPDigitField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          onChanged: (value) {
            if (value.length == 1 && index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            }
            setState(() {
              otp = _controllers.map((c) => c.text).join();
              widget.onOTPComplete(otp);
            });
          },
        );
      }),
    );
  }
}