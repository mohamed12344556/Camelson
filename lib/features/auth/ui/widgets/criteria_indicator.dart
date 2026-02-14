import 'package:flutter/material.dart';

class CriteriaIndicator extends StatelessWidget {
  final bool criterion;
  final String text;
  final IconData icon;

  const CriteriaIndicator({
    super.key,
    required this.criterion,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            criterion ? Colors.green.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: criterion ? Colors.green : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: criterion ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: criterion ? Colors.green : Colors.grey[600],
              fontWeight: criterion ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
