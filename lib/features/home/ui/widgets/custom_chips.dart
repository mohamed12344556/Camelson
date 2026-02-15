import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class CustomChips extends StatefulWidget {
  final List<String> labels;
  final double spacing;
  final int? initialSelectedIndex;
  final ValueChanged<int>? onSelected;

  const CustomChips({
    super.key,
    required this.labels,
    this.spacing = 13.0,
    this.initialSelectedIndex,
    this.onSelected,
  });

  @override
  State<CustomChips> createState() => _CustomChipsState();
}

class _CustomChipsState extends State<CustomChips> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.labels.length,
        separatorBuilder: (context, index) => SizedBox(width: widget.spacing),
        itemBuilder: (context, index) {
          final bool isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              if (widget.onSelected != null) {
                widget.onSelected!(index);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: isSelected
                    ? AppColors.primary
                    : AppColors.secondary,
              ),
              child: Text(
                widget.labels[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppColors.background
                      : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
