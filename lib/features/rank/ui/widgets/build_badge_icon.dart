import 'package:flutter/material.dart';

class BuildBadgeIcon extends StatelessWidget {
  final String badgeType;
  const BuildBadgeIcon({super.key, required this.badgeType});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (badgeType) {
      case 'gold':
        iconData = Icons.emoji_events;
        color = Colors.yellow[800]!;
        break;
      case 'silver':
        iconData = Icons.shield;
        color = Colors.blue[800]!;
        break;
      case 'bronze':
        iconData = Icons.stars;
        color = Colors.orange[800]!;
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}
