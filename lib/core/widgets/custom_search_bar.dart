import 'package:flutter/material.dart';

import '../core.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required TextEditingController searchController,
    this.onChanged,
    this.onClearPressed,
    this.hintText,
    this.isPaddingZero = false,
  }) : _searchController = searchController;

  final TextEditingController _searchController;
  final void Function(String)? onChanged;
  final void Function()? onClearPressed;
  final String? hintText;
  final bool isPaddingZero;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isPaddingZero ? EdgeInsets.zero : const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search subjects',
          hintStyle: TextStyle(color: AppColors.text.withValues(alpha: 0.5), fontSize: 16),
          prefixIcon: Icon(Icons.search, color: AppColors.text.withValues(alpha: 0.5)),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.text.withValues(alpha: 0.5)),
                    onPressed:
                        onClearPressed ??
                        () {
                          _searchController.clear();
                        },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.lightSecondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.lightSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          fillColor: AppColors.lightWhite,
          filled: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
