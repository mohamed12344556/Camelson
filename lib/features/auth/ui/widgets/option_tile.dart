import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class OptionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String value;
  final String selectedOption;
  final Function(String, String?) onOptionSelected;

  const OptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool showTextField = false;
  String? inputValue;
  late String? currentSubtitle;

  @override
  void initState() {
    super.initState();
    currentSubtitle = widget.subtitle; // Initialize with the initial subtitle
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.selectedOption == widget.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          showTextField = true;
        });
        widget.onOptionSelected(widget.value, inputValue ?? widget.subtitle);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentSubtitle ?? 'Enter your Email',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio(
                  value: widget.value,
                  groupValue: widget.selectedOption,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        showTextField = true; // Show TextField on selection
                      });
                      widget.onOptionSelected(widget.value, inputValue);
                    }
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
          if (isSelected && showTextField)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CustomTextFormField(
                label: 'Enter your value',
                icon: widget.icon ?? Icons.email_outlined,
                onFieldSubmitted: (value) {
                  setState(() {
                    inputValue = value;
                    currentSubtitle = value; // Update subtitle
                    showTextField =
                        false; // Hide TextFormField after submission
                  });
                  // Update parent widget with new inputValue
                  widget.onOptionSelected(widget.value, inputValue);
                },
                onChanged: (value) {
                  setState(() {
                    inputValue = value; // Update inputValue dynamically
                  });
                  // Send updated value to parent
                  widget.onOptionSelected(widget.value, value);
                },
              ),
            ),
        ],
      ),
    );
  }
}
