import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final GestureRecognizer? recognizer;
  final String firstText;
  final String secondText;
  const CustomRichText({
    super.key,
    this.recognizer,
    required this.firstText,
    required this.secondText,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: firstText,
            style: const TextStyle(color: Colors.grey),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: secondText,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            recognizer: recognizer,
          ),
        ],
      ),
    );
  }
}
