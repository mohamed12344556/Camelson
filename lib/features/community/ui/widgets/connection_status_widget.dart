import 'package:flutter/material.dart';

import '../logic/chat_bloc/chat_event.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ConnectionStatus status;
  final bool isReconnecting;

  const ConnectionStatusWidget({
    super.key,
    required this.status,
    required this.isReconnecting,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ConnectionStatus.connected && !isReconnecting) {
      return const SizedBox();
    }

    Color backgroundColor;
    String text;
    IconData icon;

    if (isReconnecting) {
      backgroundColor = Colors.orange;
      text = 'إعادة الاتصال...';
      icon = Icons.refresh;
    } else {
      switch (status) {
        case ConnectionStatus.connecting:
          backgroundColor = Colors.blue;
          text = 'جاري الاتصال...';
          icon = Icons.sync;
          break;
        case ConnectionStatus.disconnected:
          backgroundColor = Colors.red;
          text = 'غير متصل';
          icon = Icons.wifi_off;
          break;
        case ConnectionStatus.error:
          backgroundColor = Colors.red;
          text = 'خطأ في الاتصال';
          icon = Icons.error_outline;
          break;
        default:
          return const SizedBox();
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
