import 'package:flutter/material.dart';

import 'option_tile.dart';

/// Custom Widget for OptionTile
class ContactOptionTile extends StatelessWidget {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final String selectedOption;
  final Function(String, String?) onOptionSelected;

  const ContactOptionTile({
    super.key,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OptionTile(
      value: value,
      title: title,
      subtitle: subtitle,
      icon: icon,
      selectedOption: selectedOption,
      onOptionSelected: onOptionSelected,
    );
  }
}