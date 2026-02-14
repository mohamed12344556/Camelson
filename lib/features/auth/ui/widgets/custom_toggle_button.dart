import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  final bool isFirstOptionSelected;
  final String firstOption;
  final String secondOption;
  final Function(bool) onToggle;

  const CustomToggleButton({
    super.key,
    required this.isFirstOptionSelected,
    required this.firstOption,
    required this.secondOption,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isFirstOptionSelected ? Colors.blue : Colors.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Text(
                  firstOption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isFirstOptionSelected ? Colors.white : Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isFirstOptionSelected ? Colors.blue : Colors.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Text(
                  secondOption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !isFirstOptionSelected ? Colors.white : Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
